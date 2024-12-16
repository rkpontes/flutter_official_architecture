import 'package:flutter_oficial_architecture/domain/use_cases/book/delete_book_usecase.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockBookRepository;
  late DeleteBookUsecase deleteBookUsecase;

  const bookId = '1';

  setUp(() {
    mockBookRepository = MockBookRepository();
    deleteBookUsecase = DeleteBookUsecase(mockBookRepository);
  });

  group('DeleteBookUsecase', () {
    test('should successfully delete the book', () async {
      when(() => mockBookRepository.deleteBook(bookId))
          .thenAnswer((_) async => {});

      final result = await deleteBookUsecase.execute(bookId);

      expect(result is Ok<void>, true);
      verify(() => mockBookRepository.deleteBook(bookId)).called(1);
    });

    test('should return an error when an exception occurs', () async {
      when(() => mockBookRepository.deleteBook(bookId))
          .thenThrow(Exception('Error deleting book'));

      final result = await deleteBookUsecase.execute(bookId);

      expect(result is Error<void>, true);
      verify(() => mockBookRepository.deleteBook(bookId)).called(1);
    });
  });
}
