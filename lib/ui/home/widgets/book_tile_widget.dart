import 'package:flutter/material.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';

class BookTileWidget extends StatelessWidget {
  const BookTileWidget({
    super.key,
    required this.book,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Book book;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    String resume = (book.resume != null && (book.resume?.length ?? 0) > 100
            ? "${book.resume!.substring(0, 100)}..."
            : book.resume) ??
        '';
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Image.network(book.image ?? ''),
          title: Text(
            book.title ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(resume),
          trailing: MenuAnchor(
            menuChildren: <Widget>[
              MenuItemButton(
                child: const Text('Edit'),
                onPressed: () {
                  debugPrint('Edit: ${book.id}');
                  if (onEdit != null) {
                    onEdit!();
                  }
                },
              ),
              MenuItemButton(
                child: const Text('Delete'),
                onPressed: () {
                  debugPrint('Delete ${book.id}');
                  if (onDelete != null) {
                    onDelete!();
                  }
                },
              ),
            ],
            builder: (_, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert),
              );
            },
          ),
        ),
        const Divider(),
      ],
    );
  }
}
