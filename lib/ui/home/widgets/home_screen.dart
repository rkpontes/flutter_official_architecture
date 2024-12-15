// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';

// Project imports:
import 'package:flutter_oficial_architecture/ui/home/view_models/home_view_model.dart';
import 'package:flutter_oficial_architecture/ui/home/widgets/book_tile_widget.dart';

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
                  onEdit: () {
                    // Here you can create a screen to edit a book and pass it to the function
                    book.title = 'Edited Book';
                    widget.viewModel.editingBooksCommand.execute(book);
                  },
                  onDelete: () {
                    if (book.id == null) return;
                    widget.viewModel.deletingBooksCommand.execute(book.id!);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Here you can create a screen to add a book and pass it to the function
          final Book mockedBook = Book(
            createdAt: DateTime.now().toIso8601String(),
            title: 'Mocked Book',
            image: 'https://loremflickr.com/640/480/abstract',
            resume: 'This is a mocked book',
            slug: 'mocked-book',
          );
          widget.viewModel.addingBooksCommand.execute(mockedBook);
        },
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
}
