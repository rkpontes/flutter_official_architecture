import 'package:flutter_oficial_architecture/ui/home/view_models/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/add_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/delete_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/edit_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/list_books_usecase.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';

class MockListBooksUsecase extends Mock implements ListBooksUsecase {}

class MockAddBookUsecase extends Mock implements AddBookUsecase {}

class MockEditBookUsecase extends Mock implements EditBookUsecase {}

class MockDeleteBookUsecase extends Mock implements DeleteBookUsecase {}

void main() {
  late HomeViewModel homeViewModel;
  late MockListBooksUsecase mockListBooksUsecase;
  late MockAddBookUsecase mockAddBookUsecase;
  late MockEditBookUsecase mockEditBookUsecase;
  late MockDeleteBookUsecase mockDeleteBookUsecase;

  setUp(() {
    mockListBooksUsecase = MockListBooksUsecase();
    mockAddBookUsecase = MockAddBookUsecase();
    mockEditBookUsecase = MockEditBookUsecase();
    mockDeleteBookUsecase = MockDeleteBookUsecase();
    homeViewModel = HomeViewModel(
      mockListBooksUsecase,
      mockAddBookUsecase,
      mockEditBookUsecase,
      mockDeleteBookUsecase,
    );
  });

  test('should load books successfully when execute loadingBooksCommand',
      () async {
    final books = [Book(id: '1', title: 'Test Book')];

    when(() => mockListBooksUsecase.execute())
        .thenAnswer((_) async => Result.ok(books));

    await homeViewModel.loadingBooksCommand.execute();
    expect(homeViewModel.loadingBooksCommand.completed, true);
  });

  test('should handle error when loading books fails', () async {
    when(() => mockListBooksUsecase.execute())
        .thenAnswer((_) async => Result.error(Exception()));

    await homeViewModel.loadingBooksCommand.execute();

    expect(homeViewModel.loadingBooksCommand.running, false);
    expect(homeViewModel.loadingBooksCommand.completed, false);
    expect(homeViewModel.loadingBooksCommand.error, true);
  });

  test('should add book successfully when execute addingBooksCommand',
      () async {
    final book = Book(id: '1', title: 'New Book');

    when(() => mockAddBookUsecase.execute(book))
        .thenAnswer((_) async => const Result.ok(null));

    await homeViewModel.addingBooksCommand.execute(book);

    expect(homeViewModel.addingBooksCommand.completed, true);
    expect(homeViewModel.addingBooksCommand.error, false);
    expect(homeViewModel.addingBooksCommand.running, false);
  });

  test('should handle error when adding book fails', () async {
    final book = Book(id: '1', title: 'New Book');

    when(() => mockAddBookUsecase.execute(book))
        .thenAnswer((_) async => Result.error(Exception()));

    await homeViewModel.addingBooksCommand.execute(book);

    expect(homeViewModel.addingBooksCommand.completed, false);
    expect(homeViewModel.addingBooksCommand.error, true);
    expect(homeViewModel.addingBooksCommand.running, false);
  });

  test('should edit book successfully when execute editingBooksCommand',
      () async {
    final book = Book(id: '1', title: 'Updated Book');

    when(() => mockEditBookUsecase.execute(book))
        .thenAnswer((_) async => const Result.ok(null));

    await homeViewModel.editingBooksCommand.execute(book);

    expect(homeViewModel.editingBooksCommand.completed, true);
    expect(homeViewModel.editingBooksCommand.error, false);
    expect(homeViewModel.editingBooksCommand.running, false);
  });

  test('should handle error when editing book fails', () async {
    final book = Book(id: '1', title: 'Updated Book');

    when(() => mockEditBookUsecase.execute(book))
        .thenAnswer((_) async => Result.error(Exception()));

    await homeViewModel.editingBooksCommand.execute(book);

    expect(homeViewModel.editingBooksCommand.completed, false);
    expect(homeViewModel.editingBooksCommand.error, true);
    expect(homeViewModel.editingBooksCommand.running, false);
  });

  test('should delete book successfully when execute deletingBooksCommand',
      () async {
    const bookId = '1';

    when(() => mockDeleteBookUsecase.execute(bookId))
        .thenAnswer((_) async => const Result.ok(null));

    await homeViewModel.deletingBooksCommand.execute(bookId);

    expect(homeViewModel.deletingBooksCommand.completed, true);
    expect(homeViewModel.deletingBooksCommand.error, false);
    expect(homeViewModel.deletingBooksCommand.running, false);
  });

  test('should handle error when deleting book fails', () async {
    const bookId = '1';

    when(() => mockDeleteBookUsecase.execute(bookId))
        .thenAnswer((_) async => Result.error(Exception()));

    await homeViewModel.deletingBooksCommand.execute(bookId);

    expect(homeViewModel.deletingBooksCommand.completed, false);
    expect(homeViewModel.deletingBooksCommand.error, true);
    expect(homeViewModel.deletingBooksCommand.running, false);
  });
}
