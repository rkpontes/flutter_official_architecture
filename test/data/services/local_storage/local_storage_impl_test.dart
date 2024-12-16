import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage.dart';
import 'package:flutter_oficial_architecture/data/services/local_storage/local_storage_impl.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late LocalStorage localStorage;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    localStorage = LocalStorageImpl(mockSharedPreferences);
  });

  group('LocalStorageImpl', () {
    const testKey = 'test-key';
    const testValue = 'test-value';

    test('save should call setString and save the value', () async {
      when(() => mockSharedPreferences.setString(testKey, testValue))
          .thenAnswer((_) async => true);

      await localStorage.save(testKey, testValue);

      verify(() => mockSharedPreferences.setString(testKey, testValue))
          .called(1);
    });

    test('read should return the correct value', () async {
      when(() => mockSharedPreferences.getString(testKey))
          .thenReturn(testValue);

      final result = await localStorage.read(testKey);

      expect(result, testValue);
      verify(() => mockSharedPreferences.getString(testKey)).called(1);
    });

    test('delete should call remove and delete the value', () async {
      when(() => mockSharedPreferences.remove(testKey))
          .thenAnswer((_) async => true);

      await localStorage.delete(testKey);

      verify(() => mockSharedPreferences.remove(testKey)).called(1);
    });

    test('clear should call clear and remove all keys', () async {
      when(() => mockSharedPreferences.clear()).thenAnswer((_) async => true);

      await localStorage.clear();

      verify(() => mockSharedPreferences.clear()).called(1);
    });

    test('should throw LocalStorageException on save error', () async {
      when(() => mockSharedPreferences.setString(testKey, testValue))
          .thenThrow(Exception());

      expect(
        () => localStorage.save(testKey, testValue),
        throwsA(isA<LocalStorageException>()),
      );
    });

    test('should throw LocalStorageException on read error', () async {
      when(() => mockSharedPreferences.getString(testKey))
          .thenThrow(Exception());

      expect(
        () => localStorage.read(testKey),
        throwsA(isA<LocalStorageException>()),
      );
    });

    test('should throw LocalStorageException on delete error', () async {
      when(() => mockSharedPreferences.remove(testKey)).thenThrow(Exception());

      expect(
        () => localStorage.delete(testKey),
        throwsA(isA<LocalStorageException>()),
      );
    });

    test('should throw LocalStorageException on clear error', () async {
      when(() => mockSharedPreferences.clear()).thenThrow(Exception());

      expect(
        () => localStorage.clear(),
        throwsA(isA<LocalStorageException>()),
      );
    });
  });
}
