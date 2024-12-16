import 'package:flutter_oficial_architecture/domain/use_cases/book/edit_book_usecase.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockBookRepository;
  late EditBookUsecase editBookUsecase;

  final book = Book(
    id: '1',
    title: 'Updated Test Book',
    createdAt: DateTime.now().toIso8601String(),
    image: '',
    resume: '',
    slug: '',
  );

  setUp(() {
    mockBookRepository = MockBookRepository();
    editBookUsecase = EditBookUsecase(mockBookRepository);
  });

  group('EditBookUsecase', () {
    test('should successfully update the book', () async {
      when(() => mockBookRepository.updateBook(book))
          .thenAnswer((_) async => {});

      final result = await editBookUsecase.execute(book);

      expect(result is Ok<void>, true);
      verify(() => mockBookRepository.updateBook(book)).called(1);
    });

    test('should return an error when an exception occurs', () async {
      when(() => mockBookRepository.updateBook(book))
          .thenThrow(Exception('Error updating book'));

      final result = await editBookUsecase.execute(book);

      expect(result is Error<void>, true);
      verify(() => mockBookRepository.updateBook(book)).called(1);
    });
  });
}
