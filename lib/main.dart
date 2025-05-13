import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
import 'package:quilmedic/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Obtener y mostrar el ID de Android
  final deviceInfo = DeviceInfoPlugin();
  try {
    final androidInfo = await deviceInfo.androidInfo;
    final androidId = androidInfo.id;
    // Imprimir el ID para que sea visible en la consola
    debugPrint('=========================================');
    debugPrint('ANDROID ID: $androidId');
    debugPrint('=========================================');
  } catch (e) {
    debugPrint('Error al obtener Android ID: $e');
  }
  
  // Crear el servicio de autenticación
  final authService = AuthService();
  
  // Iniciar la aplicación inmediatamente
  runApp(MainApp(authService: authService));
  
  // Inicializar los servicios en segundo plano para no bloquear la UI
  InitializationService.initialize();
}

class MainApp extends StatelessWidget {
  final AuthService authService;
  
  const MainApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authService: authService)..add(CheckAuthStatus())),
        BlocProvider(create: (context) => EscanerBloc()),
        BlocProvider(create: (context) => ListaProductosBloc()),
        BlocProvider(create: (context) => ProductoDetalleBloc()),
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return const EscanerPage();
              }
              return const LoginPage();
            },
          ),
        ),
        title: 'QuilMedic',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}