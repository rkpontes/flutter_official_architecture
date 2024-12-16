import 'package:dio/dio.dart';
import 'package:flutter_oficial_architecture/data/services/api_client/api_client.dart';
import 'package:flutter_oficial_architecture/data/services/api_client/api_client_impl.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ApiClient apiClient;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClientImpl(mockDio);
  });

  group('ApiClientImpl', () {
    const testPath = 'test-path';
    const testHeaders = {'Authorization': 'Bearer test-token'};
    const testBody = {'key': 'value'};
    final testResponse = {'data': 'response'};

    setUpAll(() {
      registerFallbackValue(RequestOptions(path: ''));
    });

    test('get should call Dio.get and return data', () async {
      when(() => mockDio.get(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: testResponse,
            requestOptions: RequestOptions(path: testPath),
          ));

      final result = await apiClient.get(testPath, headers: testHeaders);

      expect(result, testResponse);
      verify(() => mockDio.get(
            testPath,
            options: any(named: 'options'),
          )).called(1);
    });

    test('post should call Dio.post and return data', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: testResponse,
            requestOptions: RequestOptions(path: testPath),
          ));

      final result =
          await apiClient.post(testPath, headers: testHeaders, body: testBody);

      expect(result, testResponse);
      verify(() => mockDio.post(
            testPath,
            data: testBody,
            options: any(named: 'options'),
          )).called(1);
    });

    test('put should call Dio.put and return data', () async {
      when(() => mockDio.put(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: testResponse,
            requestOptions: RequestOptions(path: testPath),
          ));

      final result =
          await apiClient.put(testPath, headers: testHeaders, body: testBody);

      expect(result, testResponse);
      verify(() => mockDio.put(
            testPath,
            data: testBody,
            options: any(named: 'options'),
          )).called(1);
    });

    test('patch should call Dio.patch and return data', () async {
      when(() => mockDio.patch(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: testResponse,
            requestOptions: RequestOptions(path: testPath),
          ));

      final result =
          await apiClient.patch(testPath, headers: testHeaders, body: testBody);

      expect(result, testResponse);
      verify(() => mockDio.patch(
            testPath,
            data: testBody,
            options: any(named: 'options'),
          )).called(1);
    });

    test('delete should call Dio.delete and return data', () async {
      when(() => mockDio.delete(
            any(),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            data: testResponse,
            requestOptions: RequestOptions(path: testPath),
          ));

      final result = await apiClient.delete(testPath, headers: testHeaders);

      expect(result, testResponse);
      verify(() => mockDio.delete(
            testPath,
            options: any(named: 'options'),
          )).called(1);
    });

    test('should throw ApiClientException on Dio error', () async {
      when(() => mockDio.get(any(), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: testPath),
        error: 'DioError',
      ));

      expect(
        () => apiClient.get(testPath, headers: testHeaders),
        throwsA(isA<ApiClientException>()),
      );
    });
  });
}
