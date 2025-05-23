import 'dart:io' show exit, Platform;
import 'package:flutter/material.dart';
import 'package:quilmedic/services/app_version_service.dart';

/// Widget que muestra un diálogo de actualización disponible.
/// Permite al usuario descargar e instalar la actualización.
class UpdateDialog extends StatefulWidget {
  /// Versión actual de la aplicación
  final String currentVersion;
  /// Última versión disponible
  final String latestVersion;
  /// Ruta al archivo APK descargado
  final String filePath;
  /// Notas de la versión
  final String releaseNotes;
  /// Indica si la actualización es obligatoria
  final bool forceUpdate;
  
  /// Constructor del diálogo de actualización
  /// @param [currentVersion] Versión actual de la aplicación
  /// @param [latestVersion] Última versión disponible
  /// @param [filePath] Ruta al archivo APK descargado
  /// @param [releaseNotes] Notas de la versión
  /// @param [forceUpdate] Indica si la actualización es obligatoria
  const UpdateDialog({
    Key? key,
    required this.currentVersion,
    required this.latestVersion,
    required this.filePath,
    required this.releaseNotes,
    required this.forceUpdate,
  }) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isInstalling = false;
  String? _errorMessage;
  
  final AppVersionService _appVersionService = AppVersionService();
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nueva versión disponible: ${widget.latestVersion}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tu versión actual: ${widget.currentVersion}'),
            const SizedBox(height: 16),
            if (widget.releaseNotes.isNotEmpty) ...[
              const Text('Notas de la versión:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.releaseNotes),
              const SizedBox(height: 16),
            ],
            if (_isInstalling) ...[
              const Text('Iniciando instalación...'),
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
            if (_errorMessage != null) ...[
              Text('Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isInstalling ? null : _installUpdate,
          child: const Text('Instalar'),
        ),
      ],
    );
  }
  
  /// Instala la actualización descargada
  Future<void> _installUpdate() async {
    setState(() {
      _isInstalling = true;
      _errorMessage = null;
    });
    
    try {
      final success = await _appVersionService.installApk(widget.filePath);
      
      if (success) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Instalación iniciada'),
            content: const Text(
              'La instalación de la actualización ha comenzado. '
              'La aplicación se cerrará para completar el proceso.\n\n'
              'Por favor, vuelve a abrir la aplicación después de que la instalación haya finalizado.'
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Cerrar el diálogo y la aplicación
                  Navigator.of(context).pop();
                  // Cerrar la aplicación
                  _closeApp();
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _isInstalling = false;
          _errorMessage = 'No se pudo iniciar la instalación';
        });
      }
    } catch (e) {
      setState(() {
        _isInstalling = false;
        _errorMessage = 'Error al instalar la actualización: ${e.toString()}';
      });
    }
  }
  
  /// Cierra la aplicación
  void _closeApp() {
    // En Flutter no hay una forma directa de cerrar la aplicación
    // que funcione en todas las plataformas, pero podemos usar
    // dart:io para Android e iOS
    if (Platform.isAndroid || Platform.isIOS) {
      exit(0); // Cierra la aplicación con código de salida 0 (éxito)
    } else {
      // En otras plataformas, simplemente cerramos el diálogo
      Navigator.of(context).pop();
    }
  }
}
