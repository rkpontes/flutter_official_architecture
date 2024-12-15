// Project imports:
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';

class GetBookUsecase {
  GetBookUsecase(this._bookRepository);
  final BookRepository _bookRepository;

  Future<Result<Book>> execute(String id) async {
    try {
      final book = await _bookRepository.getBook(id);
      return Result.ok(book);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
