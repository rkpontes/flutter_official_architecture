// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:logging/logging.dart';

// Project imports:
import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/add_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/delete_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/edit_book_usecase.dart';
import 'package:flutter_oficial_architecture/domain/use_cases/book/list_books_usecase.dart';
import 'package:flutter_oficial_architecture/utils/command.dart';
import 'package:flutter_oficial_architecture/utils/result.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(
    this._listBooksUsecase,
    this._addBookUsecase,
    this._editBookUsecase,
    this._deleteBookUsecase,
  ) {
    loadingBooksCommand = Command0(_load)..execute();
    addingBooksCommand = Command1(_add);
    editingBooksCommand = Command1(_edit);
    deletingBooksCommand = Command1(_delete);
  }

  final ListBooksUsecase _listBooksUsecase;
  final AddBookUsecase _addBookUsecase;
  final EditBookUsecase _editBookUsecase;
  final DeleteBookUsecase _deleteBookUsecase;

  final _log = Logger('HomeViewModel');

  late Command0 loadingBooksCommand;
  late Command1<void, Book> addingBooksCommand;
  late Command1<void, Book> editingBooksCommand;
  late Command1<void, String> deletingBooksCommand;

  List<Book> _books = [];
  List<Book> get books => _books;

  Future<Result> _load() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final result = await _listBooksUsecase.execute();
      switch (result) {
        case Ok<List<Book>>():
          _books = result.value;
          _log.fine('Loaded bookings');
        case Error<List<Book>>():
          _log.warning('Failed to load bookings', result);
      }

      return result;
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _add(Book book) async {
    try {
      final result = await _addBookUsecase.execute(book);
      switch (result) {
        case Ok<void>():
          _log.fine('Added booking');
        case Error<void>():
          _log.warning('Failed to add booking', result);
      }

      return result;
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _edit(Book book) async {
    try {
      final result = await _editBookUsecase.execute(book);
      switch (result) {
        case Ok<void>():
          _log.fine('Edited booking');
        case Error<void>():
          _log.warning('Failed to edit booking', result);
      }

      return result;
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _delete(String id) async {
    try {
      final result = await _deleteBookUsecase.execute(id);
      switch (result) {
        case Ok<void>():
          _log.fine('Deleted booking');
        case Error<void>():
          _log.warning('Failed to delete booking', result);
      }

      return result;
    } finally {
      notifyListeners();
    }
  }
}
