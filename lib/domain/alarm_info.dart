import 'dart:ui';

/// Clase que representa la información de una alarma procesada para su uso en la interfaz.
/// A diferencia de la clase Alarm, esta contiene el color ya convertido a un objeto Color
/// para facilitar su uso en los widgets de la interfaz de usuario.
class AlarmInfo {
  /// ID del producto asociado a la alarma
  int? productId;
  /// Condición de la alarma (<=1, <30, <180, <365, >365, etc.)
  String? condition;
  /// Color de la alarma como objeto Color para usar en la UI
  Color? color;
  /// ID de la ubicación asociada a la alarma (opcional)
  int? locationId;

  /// Constructor de la clase AlarmInfo
  /// @param productId ID del producto asociado a la alarma
  /// @param condition Condición de la alarma
  /// @param color Color de la alarma como objeto Color
  /// @param locationId ID de la ubicación asociada (opcional)
  AlarmInfo({
    this.productId,
    this.condition,
    this.color,
    this.locationId,
  });
}