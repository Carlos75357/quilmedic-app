import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quilmedic/ui/scanner/escaner_bloc.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

class ScannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool hayProductosPendientes;

  const ScannerAppBar({super.key, required this.hayProductosPendientes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: const Text(
        'Escáner de productos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 2,
      actions: [
        if (hayProductosPendientes)
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              BlocProvider.of<EscanerBloc>(
                context,
              ).add(SincronizarProductosPendientesEvent());
            },
            tooltip: 'Sincronizar productos pendientes',
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            BlocProvider.of<EscanerBloc>(context).add(LoadHospitales());

            final alarmUtils = AlarmUtils();
            alarmUtils.forceRefresh().then((_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alarmas actualizadas correctamente'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            });
          },
          tooltip: 'Recargar datos',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
