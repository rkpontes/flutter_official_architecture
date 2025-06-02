import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

extension ResponseX on Response {
  bool get isSuccessful => (statusCode ?? 0) >= 200 && (statusCode ?? 0) < 300;

  Map<String, dynamic> get jsonBody {
    try {
      return data is String
          ? jsonDecode(data) as Map<String, dynamic>
          : data as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  T? tryParseBody<T>(T Function(Map<String, dynamic> json) parser) {
    try {
      final json = jsonBody;
      return json.isNotEmpty ? parser(json) : null;
    } catch (_) {
      return null;
    }
  }

  String get errorMessage {
    try {
      final body = data is String ? jsonDecode(data) : data;
      if (body is Map<String, dynamic>) {
        return body['message'] ?? body['error'] ?? 'Something went wrong';
      }
      return 'Something went wrong';
    } catch (_) {
      return 'Unexpected error occurred';
    }
  }
}

extension StringValidators on String {
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(this);
  bool get isValidPassword => length >= 8;

  bool get isValidURL =>
      RegExp(r'^(http|https)://[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}(/\S*)?$')
          .hasMatch(this);

  bool get isEmptyOrNull => isEmpty;

  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  String get initials {
    if (isEmpty) return '';
    final parts = trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
}

extension GoRouterX on BuildContext {
  void go(String path, {Object? extra}) {
    GoRouter.of(this).go(path, extra: extra);
  }

  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    GoRouter.of(this).goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void replace(String path, {Object? extra}) {
    GoRouter.of(this).replace(path, extra: extra);
  }

  void push(String path, {Object? extra}) {
    GoRouter.of(this).push(path, extra: extra);
  }

  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    GoRouter.of(this).pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void pop<T extends Object?>([T? result]) {
    GoRouter.of(this).pop(result);
  }

  bool get canPop => GoRouter.of(this).canPop();
}

extension MediaQueryX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  double get bottomInset => viewInsets.bottom;

  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isDarkMode =>
      MediaQuery.of(this).platformBrightness == Brightness.dark;

  // Métodos úteis para responsividade
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  bool get isLargeScreen => screenWidth >= 1200;

  // Método para obter proporções da tela
  double percentOfWidth(double percent) => screenWidth * (percent / 100);
  double percentOfHeight(double percent) => screenHeight * (percent / 100);
}

extension GlobalX on BuildContext {
  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textColor != null
              ? const TextTheme().bodyMedium?.copyWith(color: textColor)
              : null,
        ),
        duration: duration,
        backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
        action: action,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colorScheme.errorContainer,
      textColor: colorScheme.onErrorContainer,
    );
  }

  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green.shade700,
      textColor: Colors.white,
    );
  }

  Future<T?> showModal<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (_) => dialog,
    );
  }

  Future<T?> showBottomSheet<T>(
    Widget child, {
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      builder: (_) => child,
    );
  }
}

extension LocalizedDate on DateTime {
  String formatToBR([String pattern = 'dd/MMM/yyyy']) {
    return DateFormat(pattern, 'pt_BR').format(this);
  }

  String formatToUS([String pattern = 'MM/dd/yyyy']) {
    return DateFormat(pattern, 'en_US').format(this);
  }

  String format(String pattern, [String? locale]) {
    return DateFormat(pattern, locale).format(this);
  }

  String get timeAgo {
    final duration = DateTime.now().difference(this);

    if (duration.inDays > 365) {
      final years = (duration.inDays / 365).floor();
      return '${years}y ago';
    }
    if (duration.inDays > 30) {
      final months = (duration.inDays / 30).floor();
      return '${months}mo ago';
    }
    if (duration.inDays > 0) {
      return '${duration.inDays}d ago';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ago';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ago';
    }
    if (duration.inSeconds > 0) {
      return '${duration.inSeconds}s ago';
    }
    return 'now';
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}
