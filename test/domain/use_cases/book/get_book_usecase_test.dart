import 'package:flutter_oficial_architecture/domain/use_cases/book/get_book_usecase.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockBookRepository;
  late GetBookUsecase getBookUsecase;

  final book = Book(
    id: '1',
    title: 'Test Book',
    createdAt: DateTime.now().toIso8601String(),
    image: '',
    resume: '',
    slug: '',
  );

  setUp(() {
    mockBookRepository = MockBookRepository();
    getBookUsecase = GetBookUsecase(mockBookRepository);
  });

  group('GetBookUsecase', () {
    test('should successfully return the book', () async {
      when(() => mockBookRepository.getBook('1')).thenAnswer((_) async => book);

      final result = await getBookUsecase.execute('1');

      expect(result is Ok<Book>, true);
      expect((result as Ok<Book>).value, equals(book));
      verify(() => mockBookRepository.getBook('1')).called(1);
    });

    test('should return an error when an exception occurs', () async {
      when(() => mockBookRepository.getBook('1'))
          .thenThrow(Exception('Error fetching book'));

      final result = await getBookUsecase.execute('1');

      expect(result is Error<Book>, true);
      verify(() => mockBookRepository.getBook('1')).called(1);
    });
  });
}
