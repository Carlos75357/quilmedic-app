import 'package:flutter/material.dart';

class EmptyProductsMessage extends StatelessWidget {
  const EmptyProductsMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No hay productos para mostrar',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
