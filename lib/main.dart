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
import 'package:quilmedic/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  final authService = AuthService();
  
  await InitializationService.initialize();
  
  runApp(MainApp(authService: authService));
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