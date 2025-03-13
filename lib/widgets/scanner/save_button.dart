import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const SaveButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text('GUARDAR PRODUCTOS'),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
