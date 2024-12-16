import 'package:flutter_oficial_architecture/domain/models/book/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book', () {
    test('fromJson should correctly parse JSON into a Book object', () {
      // Arrange
      const json = {
        "id": "123",
        "createdAt": "2024-01-01T00:00:00Z",
        "title": "Flutter for Beginners",
        "resume": "A complete guide to Flutter development.",
        "slug": "flutter-for-beginners",
      };

      // Act
      final book = Book.fromJson(json);

      // Assert
      expect(book.id, "123");
      expect(book.createdAt, "2024-01-01T00:00:00Z");
      expect(book.title, "Flutter for Beginners");
      expect(book.image, "https://loremflickr.com/500/735");
      expect(book.resume, "A complete guide to Flutter development.");
      expect(book.slug, "flutter-for-beginners");
    });

    test('toJson should correctly convert a Book object to JSON', () {
      // Arrange
      final book = Book(
        id: "123",
        createdAt: "2024-01-01T00:00:00Z",
        title: "Flutter for Beginners",
        image: "https://loremflickr.com/500/735",
        resume: "A complete guide to Flutter development.",
        slug: "flutter-for-beginners",
      );

      // Act
      final json = book.toJson();

      // Assert
      expect(json["id"], "123");
      expect(json["createdAt"], "2024-01-01T00:00:00Z");
      expect(json["title"], "Flutter for Beginners");
      expect(json["image"], "https://loremflickr.com/500/735");
      expect(json["resume"], "A complete guide to Flutter development.");
      expect(json["slug"], "flutter-for-beginners");
    });

    test('fromJson should handle missing fields gracefully', () {
      // Arrange
      const json = {
        "title": "Flutter for Beginners",
      };

      // Act
      final book = Book.fromJson(json);

      // Assert
      expect(book.id, isNull);
      expect(book.createdAt, isNull);
      expect(book.title, "Flutter for Beginners");
      expect(book.image, "https://loremflickr.com/500/735");
      expect(book.resume, isNull);
      expect(book.slug, isNull);
    });

    test('toJson should handle null fields gracefully', () {
      // Arrange
      final book = Book();

      // Act
      final json = book.toJson();

      // Assert
      expect(json["id"], isNull);
      expect(json["createdAt"], isNull);
      expect(json["title"], isNull);
      expect(json["image"], "https://loremflickr.com/500/735");
      expect(json["resume"], isNull);
      expect(json["slug"], isNull);
    });
  });
}
