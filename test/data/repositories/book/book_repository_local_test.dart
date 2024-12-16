import 'dart:convert';

import 'package:flutter_oficial_architecture/data/repositories/book/book_repository_local.dart';
import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late MockLocalStorage mockLocalStorage;
  late BookRepositoryLocal bookRepositoryLocal;
  final mockedBook = Book(
    id: '1',
    title: 'Test Book',
    createdAt: DateTime.now().toIso8601String(),
    image: '',
    resume: '',
    slug: '',
  );
  const label = 'books';

  setUp(() {
    mockLocalStorage = MockLocalStorage();
    bookRepositoryLocal = BookRepositoryLocal(mockLocalStorage);
  });

  group('BookRepositoryLocal', () {
    test('should add a book and save it to LocalStorage', () async {
      when(() => mockLocalStorage.read(label))
          .thenAnswer((_) async => jsonEncode([]));
      when(() => mockLocalStorage.save(label, any())).thenAnswer((_) async {});

      await bookRepositoryLocal.addBook(mockedBook);

      verify(() => mockLocalStorage.save(label, any())).called(1);
    });

    test('should delete a book by ID', () async {
      final booksList = [
        {'id': '1', 'title': 'Test Book', 'author': 'Test Author'}
      ];
      when(() => mockLocalStorage.read(label))
          .thenAnswer((_) async => jsonEncode(booksList));
      when(() => mockLocalStorage.save(label, any())).thenAnswer((_) async {});

      await bookRepositoryLocal.deleteBook('1');

      verify(() => mockLocalStorage.save(label, any())).called(1);
    });

    test('should get a book by ID', () async {
      final booksList = [
        {'id': '1', 'title': 'Test Book', 'author': 'Test Author'}
      ];
      when(() => mockLocalStorage.read(label))
          .thenAnswer((_) async => jsonEncode(booksList));

      final book = await bookRepositoryLocal.getBook('1');

      expect(book.id, '1');
      expect(book.title, 'Test Book');
    });

    test('should return all books', () async {
      final booksList = [
        {'id': '1', 'title': 'Test Book 1', 'author': 'Author 1'},
        {'id': '2', 'title': 'Test Book 2', 'author': 'Author 2'},
      ];
      when(() => mockLocalStorage.read(label))
          .thenAnswer((_) async => jsonEncode(booksList));

      final books = await bookRepositoryLocal.getBooks();

      expect(books.length, 2);
      expect(books[0].id, '1');
      expect(books[1].id, '2');
    });

    test('should update a book by ID', () async {
      final booksList = [mockedBook.toJson()];
      final updatedBook = Book(
        id: '1',
        title: 'Updated Test Book',
        createdAt: DateTime.now().toIso8601String(),
        image: '',
        resume: '',
        slug: '',
      );
      when(() => mockLocalStorage.read(label))
          .thenAnswer((_) async => jsonEncode(booksList));
      when(() => mockLocalStorage.save(label, any())).thenAnswer((_) async {});

      await bookRepositoryLocal.updateBook(updatedBook);

      verify(() => mockLocalStorage.save(label, any())).called(1);
    });

    test('should handle null response gracefully', () async {
      when(() => mockLocalStorage.read(label)).thenAnswer((_) async => null);

      final books = await bookRepositoryLocal.getBooks();

      expect(books, isEmpty);
    });
  });
}
