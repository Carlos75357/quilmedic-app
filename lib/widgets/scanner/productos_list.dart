import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductosList extends StatefulWidget {
  final List<ProductoEscaneado> productos;
  final Function(ProductoEscaneado) onRemove;
  final Function(ProductoEscaneado, int) onUndoRemove;

  const ProductosList({
    super.key,
    required this.productos,
    required this.onRemove,
    required this.onUndoRemove,
  });

  @override
  State<ProductosList> createState() => _ProductosListState();
}

class _ProductosListState extends State<ProductosList> {
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
            key: Key(producto.id.toString() + producto.serie.toString()),
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
                  content: Text('Producto "${producto.serie}" eliminado'),
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
              title: Text(
                producto.serie.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.numbers,
                        size: isSmallScreen ? 14 : 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'ID: ${producto.id}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
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
                          'Serie: ${producto.serie}',
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
