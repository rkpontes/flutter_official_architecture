// Project imports:
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';

abstract class BookRepository {
  Future<List<Book>> getBooks();
  Future<Book> getBook(String id);
  Future<void> addBook(Book book);
  Future<void> updateBook(Book book);
  Future<void> deleteBook(String id);
}
