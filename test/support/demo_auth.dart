import 'package:flutter/widgets.dart';
import 'package:flutter_vethome/auth/auth_session.dart';
import 'package:flutter_vethome/auth/authentication.dart';
import 'package:flutter_vethome/pages/login_page.dart';

Widget withDemoAuth(Widget child, {UserRole? role}) {
  final session = AuthSession(const DemoAuthentication());
  if (role != null) {
    session.start(AuthenticatedUser(id: 'teste', role: role));
  }
  return AuthScope(session: session, child: child);
}

Widget demoLogin() => withDemoAuth(const LoginPage());
