import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/services/initialization_service.dart';
import 'package:quilmedic/ui/list/lista_productos_bloc.dart';
import 'package:quilmedic/ui/scanner/escaner_page.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/ui/product/producto_detalle_bloc.dart';
import 'package:quilmedic/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await InitializationService.initialize();
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => EscanerBloc()),
        BlocProvider(create: (context) => ListaProductosBloc()),
        BlocProvider(create: (context) => ProductoDetalleBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const EscanerPage(),
        title: 'QuilMedic',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}