import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/book/book.dart';

class AddUpdateScreen extends StatefulWidget {
  const AddUpdateScreen({super.key, this.book});

  final Book? book;

  @override
  State<AddUpdateScreen> createState() => _AddUpdateScreenState();
}

class _AddUpdateScreenState extends State<AddUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _resumeController = TextEditingController();
  final _slugController = TextEditingController();

  @override
  void initState() {
    if (widget.book != null) {
      _titleController.text = widget.book!.title ?? '';
      _resumeController.text = widget.book!.resume ?? '';
      _slugController.text = widget.book!.slug ?? '';
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _resumeController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book == null ? 'Add Book' : 'Update Book'),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _resumeController,
                  decoration: const InputDecoration(labelText: 'Resume'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a resume';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(labelText: 'Slug'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a slug';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    context.pop(Book(
                      id: widget.book?.id,
                      title: _titleController.text,
                      resume: _resumeController.text,
                      slug: _slugController.text,
                      image: "https://loremflickr.com/640/480/abstract",
                      createdAt: DateTime.now().toIso8601String(),
                    ));
                  },
                  child: Text(widget.book == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
