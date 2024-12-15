// Project imports:
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';

class AddBookUsecase {
  AddBookUsecase(this._bookRepository);

  final BookRepository _bookRepository;

  Future<Result<void>> execute(Book book) async {
    try {
      await _bookRepository.addBook(book);
      return const Result.ok(null);
    } on AppException catch (e) {
      return Result.error(e);
    }
  }
}
