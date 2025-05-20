import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

/// Widget que muestra una lista de productos escaneados
/// Permite eliminar productos mediante deslizamiento o botón de eliminación,
/// ofrece la opción de deshacer la eliminación y muestra paginación cuando
/// hay más de 5 productos

class ProductosList extends StatefulWidget {
  /// Lista de productos escaneados para mostrar
  final List<ProductoEscaneado> productos;
  /// Función que se ejecuta cuando se elimina un producto
  final Function(ProductoEscaneado) onRemove;
  /// Función que se ejecuta cuando se deshace la eliminación de un producto
  /// Recibe el producto y su posición original en la lista
  final Function(ProductoEscaneado, int) onUndoRemove;

  /// Constructor del widget ProductosList
  /// @param productos Lista de productos escaneados
  /// @param onRemove Función que se ejecuta al eliminar un producto
  /// @param onUndoRemove Función que se ejecuta al deshacer la eliminación
  const ProductosList({
    super.key,
    required this.productos,
    required this.onRemove,
    required this.onUndoRemove,
  });

  /// Crea el estado mutable para este widget
  @override
  State<ProductosList> createState() => _ProductosListState();
}

/// Estado interno del widget ProductosList
class _ProductosListState extends State<ProductosList> {
  /// Número de productos por página
  static const int _itemsPerPage = 5;
  
  /// Página actual
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _currentPage = 0;
  }
  
  @override
  void didUpdateWidget(ProductosList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productos.length != widget.productos.length) {
      final maxPage = (widget.productos.length / _itemsPerPage).ceil() - 1;
      if (_currentPage > maxPage && maxPage >= 0) {
        setState(() {
          _currentPage = maxPage;
        });
      }
    }
  }
  
  /// Construye la interfaz de la lista de productos
  /// Adapta el tamaño de los elementos según el tamaño de la pantalla
  /// e implementa paginación cuando hay más de 5 productos
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;
    
    final int totalPages = (widget.productos.length / _itemsPerPage).ceil();
    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage > widget.productos.length) 
        ? widget.productos.length 
        : startIndex + _itemsPerPage;
    
    final List<ProductoEscaneado> productosPaginados = 
        widget.productos.isEmpty ? [] : widget.productos.sublist(startIndex, endIndex);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            itemCount: productosPaginados.length,
            separatorBuilder:
                (context, index) => Divider(color: Colors.grey.shade300, height: 1),
            itemBuilder: (context, index) {
              final int realIndex = startIndex + index;
              final producto = widget.productos[realIndex];
              
              return Dismissible(
                key: Key(producto.serialnumber.toString()),
                background: Container(
                  color: Colors.red.shade100,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  widget.onRemove(producto);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Producto "${producto.serialnumber}" eliminado'),
                      action: SnackBarAction(
                        label: 'Deshacer',
                        onPressed: () {
                          widget.onUndoRemove(producto, realIndex);
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 16,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Serie: ${producto.serialnumber}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: isSmallScreen ? 12 : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, size: isSmallScreen ? 20 : 24),
                    color: Colors.red.shade400,
                    onPressed: () => widget.onRemove(producto),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: isSmallScreen ? 32 : 40,
                      minHeight: isSmallScreen ? 32 : 40,
                    ),
                  ),
                ),
              );
            },
          ),
          
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: _currentPage > 0
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                    color: Theme.of(context).primaryColor,
                    disabledColor: Colors.grey.shade400,
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '${_currentPage + 1} / $totalPages',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  
                  // Botón para ir a la página siguiente
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: _currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                    color: Theme.of(context).primaryColor,
                    disabledColor: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
