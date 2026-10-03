import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vethome/data/vet_repository.dart';
import 'package:flutter_vethome/pages/perfil_page.dart';
import 'package:flutter_vethome/pages/login_page.dart';
import 'package:flutter_vethome/widgets/vet_header.dart';

void main() {
  test(
    'Decoração do Login cabe na largura e não cresce além do estilo original',
    () {
      for (final width in [320.0, 390.0, 500.0, 1000.0]) {
        for (final preferred in [0.65, 1.1]) {
          final scale = loginPawScaleForWidth(preferred, width);
          expect(scale, lessThanOrEqualTo(preferred));
          expect(scale, greaterThan(0));
          expect(540 * scale, lessThanOrEqualTo(width - 36 + 0.001));
        }
      }
      expect(loginPawScaleForWidth(0.65, 20), 0);
    },
  );
  const photoAsset = 'assets/imagens/figma/frame-53-3.png';
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final savedPath = VetRepository.clientPhotoPath;
  final savedBytes = VetRepository.clientPhotoBytes;

  setUp(() {
    VetRepository.clientPhotoPath = null;
    VetRepository.clientPhotoBytes = null;
  });
  tearDown(() {
    VetRepository.clientPhotoPath = savedPath;
    VetRepository.clientPhotoBytes = savedBytes;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      null,
    );
  });

  testWidgets('VetHeader mostra títulos completos e preserva os botões', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [320.0, 390.0]) {
      tester.view.physicalSize = Size(width, 844);
      for (final title in [
        'Novo agendamento',
        'Detalhes',
        'Editar pet',
        'Saúde',
        'Vacinação',
        'Agenda',
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: VetHeader(title: title)),
          ),
        );
        final text = tester.widget<Text>(find.text(title));
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(title),
        );
        expect(text.overflow, isNot(TextOverflow.ellipsis));
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byTooltip('Telas de teste'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('Perfil sem foto preserva o avatar padrão', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == photoAsset,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Perfil Web restaura bytes e nunca usa FileImage', (
    tester,
  ) async {
    final photo = await rootBundle.load(photoAsset);
    VetRepository.clientPhotoBytes = photo.buffer.asUint8List(
      photo.offsetInBytes,
      photo.lengthInBytes,
    );
    VetRepository.clientPhotoPath = 'blob:foto-da-sessao';
    for (var reopening = 0; reopening < 2; reopening++) {
      await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(
        find
            .descendant(
              of: find.byType(PerfilPage),
              matching: find.byType(Image),
            )
            .first,
      );
      final provider = (image.image as ResizeImage).imageProvider;
      expect(provider, isA<MemoryImage>());
      expect(provider, isNot(isA<FileImage>()));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  }, skip: !kIsWeb);

  testWidgets('Perfil nativo mantém FileImage para o caminho existente', (
    tester,
  ) async {
    VetRepository.clientPhotoPath = File(photoAsset).absolute.path;
    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();
    final image = tester.widget<Image>(
      find
          .descendant(of: find.byType(PerfilPage), matching: find.byType(Image))
          .first,
    );
    expect((image.image as ResizeImage).imageProvider, isA<FileImage>());
    expect(tester.takeException(), isNull);
  }, skip: kIsWeb);

  testWidgets('Selecionar foto nativa mantém o picker e o caminho', (
    tester,
  ) async {
    final path = File(photoAsset).absolute.path;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/image_picker'),
      (call) async {
        expect(call.method, 'pickImage');
        expect((call.arguments as Map)['source'], 1);
        return path;
      },
    );
    await tester.pumpWidget(const MaterialApp(home: PerfilPage()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Mudar Foto de Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mudar Foto de Perfil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher da galeria'));
    await tester.pumpAndSettle();
    expect(VetRepository.clientPhotoPath, path);
    expect(tester.takeException(), isNull);
  }, skip: kIsWeb);
}
