import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/ui/auth/auth_bloc.dart';
import 'package:quilmedic/ui/auth/auth_state.dart';
import 'package:quilmedic/ui/auth/login_page.dart';

/// Widget que escucha los cambios de estado de autenticación y redirecciona
/// al usuario a la pantalla de login cuando sea necesario
class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Solo escuchar cambios relevantes para la autenticación
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
          
          // Mostrar un mensaje al usuario
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is AuthError ? state.message : 'Sesión expirada. Por favor inicie sesión nuevamente.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navegar a la pantalla de login después de un breve retraso
          // para que el usuario pueda ver el mensaje
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false, // Eliminar todas las rutas anteriores
            );
          });
        }
      },
      child: child,
    );
  }
}
