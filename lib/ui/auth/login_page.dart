import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/ui/auth/auth_bloc.dart';
import 'package:quilmedic/ui/auth/auth_event.dart';
import 'package:quilmedic/ui/auth/auth_state.dart';
import 'package:quilmedic/ui/scanner/escaner_page.dart';

/// Pantalla de inicio de sesión de la aplicación.
/// Permite al usuario autenticarse mediante un nombre de usuario y contraseña.
/// Utiliza el AuthBloc para gestionar el estado de autenticación.
class LoginPage extends StatefulWidget {
  /// Constructor de LoginPage
  /// @param key Clave del widget
  const LoginPage({super.key});

  /// Crea el estado mutable para este widget
  /// @return Una instancia de _LoginPageState
  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Estado mutable para la pantalla de inicio de sesión.
/// Gestiona los controladores de texto, validación del formulario y estado de carga.
class _LoginPageState extends State<LoginPage> {
  /// Clave global para identificar y validar el formulario
  final _formKey = GlobalKey<FormState>();
  /// Controlador para el campo de texto del nombre de usuario
  final _usernameController = TextEditingController();
  /// Controlador para el campo de texto de la contraseña
  final _passwordController = TextEditingController();
  /// Controla la visibilidad de la contraseña
  bool _obscurePassword = true;
  /// Indica si se está procesando la solicitud de inicio de sesión
  bool _isLoading = false;

  /// Inicializa el estado del widget
  /// Se llama cuando este objeto se inserta en el árbol
  @override
  void initState() {
    super.initState();
  }

  /// Libera los recursos utilizados por este objeto
  /// Limpia los controladores de texto cuando el widget se elimina del árbol
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Construye la interfaz de usuario de la pantalla de inicio de sesión
  /// Utiliza BlocConsumer para escuchar y construir la UI basada en el estado de autenticación
  /// @param context Contexto de construcción
  /// @return Widget con el formulario de inicio de sesión
  @override
  Widget build(BuildContext context) {
    // Usar el BlocConsumer directamente sin crear un nuevo BlocProvider
    // ya que el AuthBloc ya está disponible desde el contexto principal
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const EscanerPage(),
              settings: const RouteSettings(name: '/scanner'),
            ),
          );
        } else if (state is AuthError) {
          // Evitar mostrar mensajes de error duplicados
          if (!state.message.contains('Sesión expirada')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        
        setState(() {
          _isLoading = state is AuthLoading;
        });
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Campo de título
                      const Text(
                        'Control Almacén',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      
                      // Campo de usuario
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su usuario';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      
                      // Campo de contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword 
                                  ? Icons.visibility_off 
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su contraseña';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        LoginRequested(
                                          username: _usernameController.text,
                                          password: _passwordController.text,
                                        ),
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
