// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';

class BookRepositoryLocal extends BookRepository {
  BookRepositoryLocal(this._storage);

  final LocalStorage _storage;
  final label = 'books';

  Future<List<Map<String, dynamic>>> _getBooksList() async {
    final books = await _storage.read(label);
    if (books == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(jsonDecode(books));
  }

  @override
  Future<void> addBook(Book book) async {
    try {
      final booksList = await _getBooksList();
      book.id ??= (booksList.length + 1).toString();
      booksList.add(book.toJson());
      await _storage.save(label, jsonEncode(booksList));
    } on LocalStorageException {
      rethrow;
    } catch (e) {
      throw AppException('Error adding book: $e');
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      final booksList = await _getBooksList();
      booksList.removeWhere((element) => element['id'] == id);
      await _storage.save(label, jsonEncode(booksList));
    } on LocalStorageException {
      rethrow;
    } catch (e) {
      throw AppException('Error deleting book: $e');
    }
  }

  @override
  Future<Book> getBook(String id) async {
    try {
      final booksList = await _getBooksList();
      final book = booksList.firstWhere((element) => element['id'] == id);
      return Book.fromJson(book);
    } on LocalStorageException {
      rethrow;
    } catch (e) {
      throw AppException('Error getting book: $e');
    }
  }

  @override
  Future<List<Book>> getBooks() async {
    try {
      final booksList = await _getBooksList();
      return booksList.map((e) => Book.fromJson(e)).toList();
    } on LocalStorageException {
      rethrow;
    } catch (e) {
      throw AppException('Error getting books: $e');
    }
  }

  @override
  Future<void> updateBook(Book book) async {
    try {
      final booksList = await _getBooksList();
      final index = booksList.indexWhere((element) => element['id'] == book.id);
      booksList[index] = book.toJson();
      await _storage.save(label, jsonEncode(booksList));
    } on LocalStorageException {
      rethrow;
    } catch (e) {
      throw AppException('Error updating book: $e');
    }
  }
}
