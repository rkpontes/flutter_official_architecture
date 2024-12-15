// Project imports:
import 'package:flutter_oficial_architecture/data/repositories/book/book_repository.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';

class DeleteBookUsecase {
  DeleteBookUsecase(this._bookRepository);

  final BookRepository _bookRepository;

  Future<Result<void>> execute(String id) async {
    try {
      await _bookRepository.deleteBook(id);
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
