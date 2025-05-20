/// Formatea una fecha en formato dd/mm/yyyy
/// 
/// @param [date] Fecha a formatear
/// @return [String] Cadena de texto con la fecha formateada
String formatDate(DateTime date) {
  String day = date.day.toString().padLeft(2, '0');
  String month = date.month.toString().padLeft(2, '0');
  String year = date.year.toString();
  return '$day/$month/$year';
}
