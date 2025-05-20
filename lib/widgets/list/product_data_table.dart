import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto.dart';
import 'package:quilmedic/utils/alarm_utils.dart';
import 'package:quilmedic/utils/services.dart';
import 'package:quilmedic/widgets/list/compact_list.dart';
import 'package:quilmedic/widgets/list/product_expiry_badge.dart';
import 'package:quilmedic/widgets/list/product_stock_badge.dart';

/// Widget que muestra una tabla de datos de productos con información detallada
/// Se adapta a diferentes tamaños de pantalla y muestra indicadores visuales
/// para fechas de caducidad y niveles de stock basados en las alarmas configuradas.
/// Incluye paginación para mejorar el rendimiento con grandes conjuntos de datos.
class ProductDataTable extends StatefulWidget {
  /// Lista de productos a mostrar en la tabla
  final List<Producto> productos;

  /// Color para el encabezado de la tabla
  final Color headerColor;

  /// Color para las filas de la tabla
  final Color rowColor;

  /// Función que se ejecuta cuando se toca un producto en la tabla
  final Function(Producto) onProductTap;

  /// Función opcional que se ejecuta cuando se presiona el botón de traslado
  /// Si es null, no se muestra el botón de traslado
  final Function(Producto)? onTransferTap;

  /// Lista de colores para las alarmas de los productos
  final List<Color> alarmColors;

  /// ID de la ubicación seleccionada actualmente (para evaluar alarmas de stock)
  final int selectedLocationId;

  /// Constructor del widget ProductDataTable
  const ProductDataTable({
    super.key,
    required this.productos,
    required this.headerColor,
    required this.rowColor,
    required this.onProductTap,
    this.onTransferTap,
    required this.alarmColors,
    required this.selectedLocationId,
  });

  @override
  State<ProductDataTable> createState() => _ProductDataTableState();
}

/// Estado del widget ProductDataTable que maneja la paginación
class _ProductDataTableState extends State<ProductDataTable> {
  /// Número de productos por página
  int _rowsPerPage = 10;
  
  /// Página actual (0-indexed)
  int _currentPage = 0;
  
  /// Total de páginas disponibles
  int _totalPages = 1;
  
  @override
  void initState() {
    super.initState();
    // Calcular el número total de páginas
    _calculateTotalPages();
  }
  
  @override
  void didUpdateWidget(ProductDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalcular páginas si cambia la lista de productos
    if (oldWidget.productos.length != widget.productos.length) {
      _calculateTotalPages();
      // Asegurarse de que la página actual sea válida
      if (_currentPage >= _totalPages) {
        _currentPage = _totalPages > 0 ? _totalPages - 1 : 0;
      }
    }
  }
  
  /// Calcula el número total de páginas basado en la cantidad de productos
  void _calculateTotalPages() {
    _totalPages = (widget.productos.length / _rowsPerPage).ceil();
    _totalPages = _totalPages > 0 ? _totalPages : 1; // Mínimo 1 página
  }
  
  /// Obtiene los productos para la página actual
  List<Producto> _getProductosForCurrentPage() {
    if (widget.productos.isEmpty) return [];
    
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage <= widget.productos.length) 
        ? startIndex + _rowsPerPage 
        : widget.productos.length;
    
    return widget.productos.sublist(startIndex, endIndex);
  }
  
  /// Ir a la página anterior
  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }
  
  /// Ir a la página siguiente
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  /// Construye la interfaz de la tabla de datos de productos
  /// Se adapta automáticamente al tamaño de la pantalla y muestra una vista compacta
  /// en dispositivos muy pequeños
  @override
  Widget build(BuildContext context) {
    final alarmUtils = AlarmUtils();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      alarmUtils.loadAlarmsFromCache();
    });
    
    // Obtener los productos para la página actual
    final productosToShow = _getProductosForCurrentPage();
    
    // Ordenar los productos por código
    productosToShow.sort((a, b) => a.productcode.compareTo(b.productcode));
    
    // Calcular el stock total por código de producto
    final Map<String, int> totalStockByCode = {};
    for (final producto in widget.productos) {
      totalStockByCode.update(
        producto.productcode, 
        (value) => value + producto.stock, 
        ifAbsent: () => producto.stock
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 360;
    final isExtremelySmallScreen = screenWidth < 320;
    final isWideScreen = screenWidth > 1200;

    if (isExtremelySmallScreen) {
      return CompactList(
        productos: widget.productos,
        onProductTap: widget.onProductTap,
        onTransferTap: widget.onTransferTap,
        alarmColors: widget.alarmColors,
        selectedLocationId: widget.selectedLocationId,
      );
    }

    if (widget.productos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No hay productos para mostrar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = screenWidth;
        final expiryWidth =
            isWideScreen
                ? (availableWidth * 0.2).toDouble()
                : (isVerySmallScreen ? 85.0 : (isSmallScreen ? 95.0 : 110.0));
        final stockWidth =
            isWideScreen
                ? (availableWidth * 0.15).toDouble()
                : (isVerySmallScreen ? 40.0 : (isSmallScreen ? 60.0 : 80.0));
        final codeWidth =
            isWideScreen
                ? (availableWidth * 0.15).toDouble()
                : (isVerySmallScreen ? 70.0 : (isSmallScreen ? 80.0 : 100.0));

        return Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(0), // Eliminar bordes redondeados
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: availableWidth, maxWidth: double.infinity),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.grey.shade300,
                          dataTableTheme: DataTableThemeData(
                            headingTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  isVerySmallScreen
                                      ? 12
                                      : (isSmallScreen ? 14 : 16),
                            ),
                            dataTextStyle: TextStyle(
                              fontSize:
                                  isVerySmallScreen
                                      ? 12
                                      : (isSmallScreen ? 14 : 16),
                            ),
                          ),
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith(
                            (states) => widget.headerColor,
                          ),
                          dataRowMinHeight: 64,
                          dataRowMaxHeight: 80,
                          columnSpacing: isVerySmallScreen ? 2 : (isSmallScreen ? 4 : 8), // Reducir espaciado entre columnas
                          horizontalMargin: 0, // Eliminar margen horizontal para que ocupe todo el ancho
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            verticalInside: BorderSide(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            // Añadir bordes externos para que se vea completo
                            top: BorderSide(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            bottom: BorderSide(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            left: BorderSide.none,
                            right: BorderSide.none,
                          ),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: codeWidth,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.code_outlined,
                                      size: isVerySmallScreen ? 14 : 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: isVerySmallScreen ? 2 : 4),
                                    Expanded(
                                      child: Center(
                                        child: const Text('Código'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: expiryWidth,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: isVerySmallScreen ? 14 : 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: isVerySmallScreen ? 2 : 4),
                                    Expanded(
                                      child: Center(
                                        child: const Text('Caducidad'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: stockWidth,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: isVerySmallScreen ? 14 : 16,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: isVerySmallScreen ? 2 : 4),
                                    Expanded(
                                      child: Center(
                                        child: const Text('Stock'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            productosToShow.length,
                            (index) {
                              final producto = productosToShow[index];
                              final totalStock = totalStockByCode[producto.productcode] ?? producto.stock;

                              return DataRow(
                                color: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                    if (states.contains(WidgetState.hovered)) {
                                      return Colors.grey.shade100;
                                    }
                                    return widget.rowColor;
                                  },
                                ),
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: codeWidth,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                producto.productcode,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize:
                                                      isVerySmallScreen ? 11 : null,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'monospace',
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Center(
                                              child: Text(
                                                producto.serialnumber,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: isVerySmallScreen ? 10 : 12,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: 'monospace',
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () => widget.onProductTap(producto),
                                  ),
                                  DataCell(
                                    SizedBox.expand(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: alarmUtils
                                              .getColorForExpiryFromCache(
                                                producto.id,
                                                producto.expirationdate,
                                              ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        width: expiryWidth,
                                        child: Center(
                                          child: ProductExpiryBadge(
                                            expiryDate: producto.expirationdate,
                                            formattedDate: formatDate(
                                              producto.expirationdate,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox.expand(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: alarmUtils.getColorForStockFromCache(
                                            totalStock,
                                            producto.id,
                                            widget.selectedLocationId,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 4,
                                        ),
                                        width: stockWidth,
                                        child: Center(
                                          child: ProductStockBadge(
                                            stock: totalStock,
                                            alarmUtils: alarmUtils,
                                            productId: producto.id,
                                            locationId: widget.selectedLocationId,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Controles de paginación
            if (widget.productos.length > _rowsPerPage)
              Container(
                width: double.infinity,
                color: Colors.grey.shade100,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mostrando ${_currentPage * _rowsPerPage + 1} - ${(_currentPage + 1) * _rowsPerPage > widget.productos.length ? widget.productos.length : (_currentPage + 1) * _rowsPerPage} de ${widget.productos.length}',
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 11 : 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          onPressed: _currentPage > 0 ? _previousPage : null,
                          color: _currentPage > 0 ? Colors.blue : Colors.grey.shade400,
                          tooltip: 'Página anterior',
                        ),
                        Text(
                          '${_currentPage + 1} / $_totalPages',
                          style: TextStyle(
                            fontSize: isVerySmallScreen ? 11 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: _currentPage < _totalPages - 1 ? _nextPage : null,
                          color: _currentPage < _totalPages - 1 ? Colors.blue : Colors.grey.shade400,
                          tooltip: 'Página siguiente',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
