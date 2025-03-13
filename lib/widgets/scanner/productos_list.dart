import 'package:flutter/material.dart';
import 'package:quilmedic/domain/producto_scaneado.dart';

class ProductosList extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: productos.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade300,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final producto = productos[index];
          return Dismissible(
            key: Key(producto.id.toString() + producto.serie.toString()),
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              onRemove(producto);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Producto "${producto.serie}" eliminado'),
                  action: SnackBarAction(
                    label: 'Deshacer',
                    onPressed: () {
                      onUndoRemove(producto, index);
                    },
                  ),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                producto.serie.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.numbers,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ID: ${producto.id}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Serie: ${producto.serie}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                onPressed: () => onRemove(producto),
              ),
            ),
          );
        },
      ),
    );
  }
}
