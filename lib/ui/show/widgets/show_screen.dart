import 'package:flutter/material.dart';

import '../../../domain/models/book/book.dart';

class ShowScreen extends StatefulWidget {
  const ShowScreen({super.key, this.book});

  final Book? book;

  @override
  State<ShowScreen> createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book?.title ?? ''),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.book != null && widget.book?.image != null)
                    Image.network(
                      widget.book!.image!,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 16),
                  Text(widget.book?.title ?? 'No title',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(widget.book?.resume ?? 'No resume',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  Text(widget.book?.slug ?? 'No slug',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
