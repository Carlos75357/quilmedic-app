import 'package:flutter/material.dart';
import 'package:quilmedic/utils/alarm_utils.dart';

class ProductStockBadge extends StatefulWidget {
  final int stock;
  final bool isSmallScreen;
  final AlarmUtils alarmUtils;
  final int productId;
  final int locationId;
  
  const ProductStockBadge({
    super.key,
    required this.stock,
    this.isSmallScreen = false,
    required this.alarmUtils,
    required this.productId,
    required this.locationId,
  });

  @override
  State<ProductStockBadge> createState() => _ProductStockBadgeState();
}

class _ProductStockBadgeState extends State<ProductStockBadge> {
  int? stockMinimo;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadStockMinimo();
  }
  
  Future<void> _loadStockMinimo() async {
    try {
      // Verificar si hay alarmas específicas para este producto
      final hasSpecific = await widget.alarmUtils.hasSpecificAlarms(widget.productId);
      
      if (hasSpecific) {
        // Obtener las alarmas específicas para este producto
        final alarms = await widget.alarmUtils.getSpecificAlarmsForProduct(widget.productId);
        
        // Buscar una alarma de tipo 'stock' para este producto y esta ubicación
        for (var alarm in alarms) {
          if (alarm.type?.toLowerCase() == 'stock' && 
              (alarm.locationId == null || alarm.locationId == widget.locationId)) {
            final condition = alarm.condition;
            if (condition != null && condition.isNotEmpty) {
              final RegExp regExp = RegExp(r'(\D*)(\d+)');
              final Match? match = regExp.firstMatch(condition);

              if (match != null) {
                final value = int.parse(match.group(2)!);
                if (mounted) {
                  setState(() {
                    stockMinimo = value;
                    isLoading = false;
                  });
                }
                return;
              }
            }
          }
        }
      }
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isSmallScreen ? 4 : 8, 
        vertical: widget.isSmallScreen ? 2 : 4
      ),
      alignment: Alignment.center,
      child: isLoading
        ? const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(
            stockMinimo != null ? '${widget.stock}/$stockMinimo' : '${widget.stock}',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: widget.isSmallScreen ? 11 : null,
            ),
            textAlign: TextAlign.center,
          ),
    );
  }
}
