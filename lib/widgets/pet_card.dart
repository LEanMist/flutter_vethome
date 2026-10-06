import 'package:flutter/material.dart';
import 'package:flutter_vethome/models/pet.dart';

class PetCard extends StatelessWidget {
  const PetCard({
    super.key,
    required this.pet,
    required this.onDetails,
  });

  final Pet pet;
  final VoidCallback onDetails;

  String get imageAsset => pet.tipo == PetType.cachorro
      ? 'assets/imagens/cachorro.png'
      : 'assets/imagens/gato.png';

  String get animalLabel => pet.tipo == PetType.cachorro ? 'Cachorro' : 'Gato';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, object, stackTrace) =>
                    const Icon(Icons.pets),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$animalLabel · ${pet.raca}'),
                  Text('Peso: ${pet.peso.toStringAsFixed(1)} kg'),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextButton(
                      onPressed: onDetails,
                      child: const Text('Ver detalhes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
