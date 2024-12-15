// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(
                  book.image ?? '',
                  height: 90,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      child: Text(
                        book.title ?? '',
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      child: Text(
                        resume,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                MenuAnchor(
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
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
