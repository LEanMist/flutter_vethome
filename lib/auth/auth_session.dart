import 'package:flutter/widgets.dart';

import 'authentication.dart';

class AuthSession {
  AuthSession(this.authentication);

  final Authentication? authentication;
  AuthenticatedUser? _user;

  AuthenticatedUser? get user => _user;
  bool get isDemo => authentication is DemoAuthentication;

  String? get homeRoute => switch (_user?.role) {
    UserRole.cliente => '/pets',
    UserRole.veterinaria => '/gabriela',
    null => null,
  };

  void start(AuthenticatedUser user) => _user = user;
  void end() => _user = null;
}

class AuthScope extends InheritedWidget {
  const AuthScope({super.key, required this.session, required super.child});

  final AuthSession session;

  static AuthSession? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.session;

  static void signOut(BuildContext context) {
    maybeOf(context)?.end();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  bool updateShouldNotify(AuthScope oldWidget) => session != oldWidget.session;
}
