import 'package:flutter_oficial_architecture/domain/use_cases/book/list_books_usecase.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  late MockBookRepository mockBookRepository;
  late ListBooksUsecase listBooksUsecase;

  final booksList = [
    Book(
      id: '1',
      title: 'Test Book 1',
      createdAt: DateTime.now().toIso8601String(),
      image: '',
      resume: '',
      slug: '',
    ),
    Book(
      id: '2',
      title: 'Test Book 2',
      createdAt: DateTime.now().toIso8601String(),
      image: '',
      resume: '',
      slug: '',
    ),
  ];

  setUp(() {
    mockBookRepository = MockBookRepository();
    listBooksUsecase = ListBooksUsecase(mockBookRepository);
  });

  group('ListBooksUsecase', () {
    test('should successfully return a list of books', () async {
      when(() => mockBookRepository.getBooks())
          .thenAnswer((_) async => booksList);

      final result = await listBooksUsecase.execute();

      expect(result is Ok<List<Book>>, true);
      expect((result as Ok<List<Book>>).value, equals(booksList));
      verify(() => mockBookRepository.getBooks()).called(1);
    });

    test('should return an error when an exception occurs', () async {
      when(() => mockBookRepository.getBooks())
          .thenThrow(AppException('Error fetching books'));

      final result = await listBooksUsecase.execute();

      expect(result is Error<List<Book>>, true);
      verify(() => mockBookRepository.getBooks()).called(1);
    });
  });
}
