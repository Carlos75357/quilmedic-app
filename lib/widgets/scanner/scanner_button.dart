import 'package:flutter/material.dart';

class ScannerButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const ScannerButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear Código QR'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
