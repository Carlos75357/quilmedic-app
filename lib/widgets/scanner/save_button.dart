import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool hayConexion;
  
  const SaveButton({
    super.key,
    required this.onPressed,
    this.hayConexion = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton.icon(
        icon: Icon(hayConexion ? Icons.save : Icons.save_outlined),
        label: Text(hayConexion ? 'GUARDAR PRODUCTOS' : 'GUARDAR LOCALMENTE'),
        style: ElevatedButton.styleFrom(
          backgroundColor: hayConexion ? theme.colorScheme.primary : Colors.amber,
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
