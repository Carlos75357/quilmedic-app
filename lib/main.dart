import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/services/auth_service.dart';
import 'package:quilmedic/services/initialization_service.dart';
import 'package:quilmedic/services/navigation_service.dart';
import 'package:quilmedic/ui/auth/auth_bloc.dart';
import 'package:quilmedic/ui/auth/auth_event.dart';
import 'package:quilmedic/ui/auth/auth_state.dart';
import 'package:quilmedic/ui/auth/auth_wrapper.dart';
import 'package:quilmedic/ui/auth/login_page.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/ui/scanner/escaner_page.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/ui/product/producto_detalle_bloc.dart';
import 'package:quilmedic/ui/update/update_dialog.dart';
import 'package:quilmedic/utils/theme.dart';

/// Punto de entrada principal de la aplicación.
/// Inicializa los servicios necesarios y lanza la aplicación.
void main() async {
  // Asegura que Flutter esté inicializado correctamente
  WidgetsFlutterBinding.ensureInitialized();

  // Crea una instancia del servicio de autenticación
  final authService = AuthService();
  
  // Inicializa servicios necesarios antes de lanzar la aplicación
  await InitializationService.initialize();
  
  // Lanza la aplicación principal con el servicio de autenticación
  runApp(MainApp(authService: authService));
}

/// Widget principal de la aplicación.
/// Configura los proveedores de BLoC, temas y navegación.
class MainApp extends StatelessWidget {
  /// Servicio de autenticación utilizado en toda la aplicación
  final AuthService authService;
  
  const MainApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Configura los proveedores de BLoC para la gestión de estado
      providers: [
        // BLoC de autenticación que verifica el estado inicial al iniciar
        BlocProvider(create: (context) => AuthBloc(authService: authService)..add(CheckAuthStatus())),
        // BLoC para la funcionalidad de escaneo de productos
        BlocProvider(create: (context) => EscanerBloc()),
        // BLoC para gestionar la lista de productos
        BlocProvider(create: (context) => ListaProductosBloc()),
        // BLoC para la pantalla de detalle de producto
        BlocProvider(create: (context) => ProductoDetalleBloc()),
      ],
      child: MaterialApp(
        // Configura la clave del navegador para acceso global
        navigatorKey: NavigationService.navigatorKey,
        // Oculta el banner de depuración
        debugShowCheckedModeBanner: false,
        // Configura la pantalla inicial con el wrapper de autenticación
        home: AuthWrapper(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              // Mostrar diálogo de actualización si hay una nueva versión disponible
              if (state is AuthenticatedWithUpdate) {
                // Usar Future.microtask para mostrar el diálogo después de que se complete la construcción
                Future.microtask(() {
                  showDialog(
                    context: context,
                    barrierDismissible: !state.forceUpdate,
                    builder: (context) => UpdateDialog(
                      currentVersion: state.currentVersion,
                      latestVersion: state.latestVersion,
                      filePath: state.filePath,
                      releaseNotes: state.releaseNotes,
                      forceUpdate: state.forceUpdate,
                    ),
                  );
                });
              }
            },
            builder: (context, state) {
              // Muestra la página de escaneo si el usuario está autenticado
              if (state is Authenticated) {
                return const EscanerPage();
              }
              // Muestra la página de login si no está autenticado
              return const LoginPage();
            },
          ),
        ),
        title: 'QuilMedic',
        // Configuración de temas claro y oscuro
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        // Utiliza el tema del sistema por defecto
        themeMode: ThemeMode.system,
      ),
    );
  }
}