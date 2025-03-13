import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/ui/scanner/escaner_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EscanerBloc(),
        ),
      ],
      child: MaterialApp(
        // debugShowCheckedModeBanner: false,
        home: const EscanerPage(),
      ),
    );
  }
}
