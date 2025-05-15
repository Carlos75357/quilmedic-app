import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/ui/auth/auth_bloc.dart';
import 'package:quilmedic/ui/auth/auth_state.dart';
import 'package:quilmedic/ui/auth/login_page.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is Unauthenticated || 
               (current is AuthError && 
                (current.message.contains('expirada') || 
                 current.message.contains('sesión') || 
                 current.message.contains('autenticación')));
      },
      listener: (context, state) {
        if (state is Unauthenticated || 
            (state is AuthError && 
             (state.message.contains('expirada') || 
              state.message.contains('sesión') || 
              state.message.contains('autenticación')))) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is AuthError ? state.message : 'Sesión expirada. Por favor inicie sesión nuevamente.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          
          Future.delayed(const Duration(seconds: 1), () {
            if (context.mounted){
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
            }
          });
        }
      },
      child: child,
    );
  }
}
