// Project imports:
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/data/services/api_client/api_client.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';

class BookRepositoryRemote extends BookRepository {
  BookRepositoryRemote(this._api);

  final ApiClient _api;
  final label = 'books';

  @override
  Future<void> addBook(Book book) async {
    try {
      await _api.post('books', body: book.toJson());
    } on ApiClientException {
      rethrow;
    } catch (e) {
      throw AppException('Error adding book: $e');
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      await _api.delete('books/$id');
    } on ApiClientException {
      rethrow;
    } catch (e) {
      throw AppException('Error deleting book: $e');
    }
  }

  @override
  Future<Book> getBook(String id) async {
    try {
      final book = Map<String, dynamic>.from(await _api.get('books/$id'));
      return Book.fromJson(book);
    } on ApiClientException {
      rethrow;
    } catch (e) {
      throw AppException('Error getting book: $e');
    }
  }

  @override
  Future<List<Book>> getBooks() async {
    try {
      final books = List<Map<String, dynamic>>.from(await _api.get('books'));
      return books.map((e) => Book.fromJson(e)).toList();
    } on ApiClientException {
      rethrow;
    } catch (e) {
      throw AppException('Error getting books: $e');
    }
  }

  @override
  Future<void> updateBook(Book book) async {
    try {
      await _api.put('books/${book.id}', body: book.toJson());
    } on ApiClientException {
      rethrow;
    } catch (e) {
      throw AppException('Error updating book: $e');
    }
  }
}
