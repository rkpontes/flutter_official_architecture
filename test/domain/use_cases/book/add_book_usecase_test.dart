import 'package:flutter_oficial_architecture/domain/use_cases/book/add_book_usecase.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockBookRepository;
  late AddBookUsecase addBookUsecase;

  final mockedBook = Book(
    id: '1',
    title: 'Test Book',
    createdAt: DateTime.now().toIso8601String(),
    image: '',
    resume: '',
    slug: '',
  );

  setUp(() {
    mockBookRepository = MockBookRepository();
    addBookUsecase = AddBookUsecase(mockBookRepository);
  });

  group('AddBookUsecase', () {
    test('should successfully add the book', () async {
      when(() => mockBookRepository.addBook(mockedBook))
          .thenAnswer((_) async => {});

      final result = await addBookUsecase.execute(mockedBook);

      expect(result is Ok<void>, true);
      verify(() => mockBookRepository.addBook(mockedBook)).called(1);
    });

    test('should return an error when an exception occurs', () async {
      when(() => mockBookRepository.addBook(mockedBook))
          .thenThrow(AppException('Error adding book'));

      final result = await addBookUsecase.execute(mockedBook);

      expect(result is Error<void>, true);
      verify(() => mockBookRepository.addBook(mockedBook)).called(1);
    });
  });
}
