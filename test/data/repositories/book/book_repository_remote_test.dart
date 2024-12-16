import 'package:flutter_oficial_architecture/data/repositories/book/book_repository_remote.dart';
import 'package:flutter_oficial_architecture/data/services/api_client/api_client.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late BookRepositoryRemote bookRepositoryRemote;

  final mockedBook = Book(
    id: '1',
    title: 'Test Book',
    createdAt: DateTime.now().toIso8601String(),
    image: '',
    resume: '',
    slug: '',
  );

  setUp(() {
    mockApiClient = MockApiClient();
    bookRepositoryRemote = BookRepositoryRemote(mockApiClient);
  });

  group('BookRepositoryRemote', () {
    const basePath = 'books';

    test('should add a book via API', () async {
      when(() => mockApiClient.post(basePath, body: mockedBook.toJson()))
          .thenAnswer((_) async => null);

      await bookRepositoryRemote.addBook(mockedBook);

      verify(() => mockApiClient.post(basePath, body: mockedBook.toJson()))
          .called(1);
    });

    test('should delete a book by ID via API', () async {
      const bookId = '1';
      when(() => mockApiClient.delete('$basePath/$bookId'))
          .thenAnswer((_) async => null);

      await bookRepositoryRemote.deleteBook(bookId);

      verify(() => mockApiClient.delete('$basePath/$bookId')).called(1);
    });

    test('should fetch a book by ID via API', () async {
      const bookId = '1';
      final bookJson = mockedBook.toJson();
      when(() => mockApiClient.get('$basePath/$bookId'))
          .thenAnswer((_) async => bookJson);

      final book = await bookRepositoryRemote.getBook(bookId);

      expect(book.id, bookJson['id']);
      expect(book.title, bookJson['title']);
      verify(() => mockApiClient.get('$basePath/$bookId')).called(1);
    });

    test('should fetch all books via API', () async {
      final booksJson = [
        {'id': '1', 'title': 'Book 1', 'author': 'Author 1'},
        {'id': '2', 'title': 'Book 2', 'author': 'Author 2'},
      ];
      when(() => mockApiClient.get(basePath))
          .thenAnswer((_) async => booksJson);

      final books = await bookRepositoryRemote.getBooks();

      expect(books.length, booksJson.length);
      expect(books[0].id, booksJson[0]['id']);
      expect(books[1].title, booksJson[1]['title']);
      verify(() => mockApiClient.get(basePath)).called(1);
    });

    test('should update a book by ID via API', () async {
      when(() => mockApiClient.put('$basePath/${mockedBook.id}',
          body: mockedBook.toJson())).thenAnswer((_) async => null);

      await bookRepositoryRemote.updateBook(mockedBook);

      verify(() => mockApiClient.put('$basePath/${mockedBook.id}',
          body: mockedBook.toJson())).called(1);
    });

    test('should handle API errors when adding a book', () async {
      when(() => mockApiClient.post(basePath, body: mockedBook.toJson()))
          .thenThrow(ApiClientException('Error adding book'));

      expect(
        () async => await bookRepositoryRemote.addBook(mockedBook),
        throwsA(isA<ApiClientException>()),
      );
    });
  });
}
