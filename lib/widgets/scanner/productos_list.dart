import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

/// Widget que muestra una lista de productos escaneados
/// Permite eliminar productos mediante deslizamiento o botón de eliminación
/// y ofrece la opción de deshacer la eliminación

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
  /// Construye la interfaz de la lista de productos
  /// Adapta el tamaño de los elementos según el tamaño de la pantalla
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
        itemCount: widget.productos.length,
        separatorBuilder:
            (context, index) => Divider(color: Colors.grey.shade300, height: 1),
        itemBuilder: (context, index) {
          final producto = widget.productos[index];
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
                      widget.onUndoRemove(producto, index);
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
    );
  }
}
