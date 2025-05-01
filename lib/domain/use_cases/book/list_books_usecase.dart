// Project imports:
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';

class ListBooksUsecase {
  ListBooksUsecase(this._bookRepository);

  final BookRepository _bookRepository;

  Future<Result<List<Book>>> execute() async {
    try {
      final books = await _bookRepository.getBooks();
      return Result.ok(books);
    } on AppGenericException catch (e) {
      return Result.error(e);
    }
  }
}
