// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/routing/routes.dart';

// Project imports:
import 'package:flutter_oficial_architecture/ui/home/view_models/home_view_model.dart';
import 'package:flutter_oficial_architecture/ui/home/widgets/book_tile_widget.dart';
import 'package:flutter_oficial_architecture/utils/config.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  final HomeViewModel viewModel;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final config = GetIt.I<Config>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addingBooksCommand.addListener(_onResult);
    widget.viewModel.editingBooksCommand.addListener(_onResult);
    widget.viewModel.deletingBooksCommand.addListener(_onResult);
    widget.viewModel.deletingBooksCommand.addListener(_onDeleteResult);
  }

  @override
  void dispose() {
    widget.viewModel.addingBooksCommand.removeListener(_onResult);
    widget.viewModel.editingBooksCommand.removeListener(_onResult);
    widget.viewModel.deletingBooksCommand.removeListener(_onResult);
    widget.viewModel.deletingBooksCommand.removeListener(_onDeleteResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          if (config.isDevelopment)
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              onPressed: () {
                GetIt.I<LocalStorage>().clear();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.viewModel.loadingBooksCommand.execute();
            },
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: ListenableBuilder(
          listenable: widget.viewModel.loadingBooksCommand,
          builder: (context, child) {
            final handler = widget.viewModel.loadingBooksCommand;

            if (handler.running) {
              return const Center(child: CircularProgressIndicator());
            }

            if (handler.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load books'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.viewModel.loadingBooksCommand.execute();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (widget.viewModel.books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No books found'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.viewModel.loadingBooksCommand.execute();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: widget.viewModel.books.length,
              itemBuilder: (context, index) {
                final book = widget.viewModel.books[index];
                return BookTileWidget(
                  book: book,
                  onTap: () => context.push(Routes.show, extra: book),
                  onEdit: () async {
                    var res = await context.push(Routes.addUpdate, extra: book);
                    if (res != null && res is Book) {
                      widget.viewModel.editingBooksCommand.execute(res);
                    }
                  },
                  onDelete: () => _onDelete(book),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditBook(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onResult() {
    widget.viewModel.loadingBooksCommand.execute();
  }

  void _onDeleteResult() {
    if (widget.viewModel.deletingBooksCommand.completed) {
      widget.viewModel.deletingBooksCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Book deleted"),
        ),
      );
    }

    if (widget.viewModel.deletingBooksCommand.error) {
      widget.viewModel.deletingBooksCommand.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to delete book"),
        ),
      );
    }
  }

  Future<void> _addOrEditBook(Book? book) async {
    var res = await context.push(Routes.addUpdate, extra: book);
    if (res != null && res is Book) {
      if (res.id == null) {
        widget.viewModel.addingBooksCommand.execute(res);
        return;
      }

      widget.viewModel.editingBooksCommand.execute(res);
    }
  }

  void _onDelete(Book book) {
    if (book.id == null) return;

    // open dialog with yes or no
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete book'),
          content: const Text('Are you sure you want to delete this book?'),
          actions: [
            TextButton(
              onPressed: context.pop,
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                widget.viewModel.deletingBooksCommand.execute(book.id!);
                context.pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
