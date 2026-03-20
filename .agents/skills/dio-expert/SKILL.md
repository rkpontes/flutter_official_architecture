---
name: dio-expert
description: Expert guidance on Dio 5.9.x for Dart and Flutter. Covers singleton setup with BaseOptions, request methods, interceptors, QueuedInterceptor, timeout and cancellation, FormData uploads, adapters, certificate pinning, error handling with DioException, testing, and production integration in this repository. Use when working with Dio, HTTP clients, interceptors, request configuration, uploads, downloads, transport errors, or API service-layer code.
metadata:
  author: flutter-it
  version: "1.0"
---

# Dio Expert - HTTP Client & Transport Layer

**What**: Full-featured HTTP client for Dart and Flutter with interceptors, cancellation, uploads/downloads, adapters, and transport-level configuration. Use it in the service layer, not across the app.

## CRITICAL RULES

- Keep `Dio` usage inside API service implementations, not repositories, view models, or widgets
- Prefer a single injected `Dio` instance with centralized `BaseOptions`
- Add interceptors once during setup, not per request
- `LogInterceptor` must be the last interceptor added
- Treat `DioException` as transport-layer detail; map it to project-level failures before returning upward
- Create a fresh `FormData` and `MultipartFile` for each request; do not reuse them across repeated calls
- Use `CancelToken` when requests may outlive the caller
- Prefer `QueuedInterceptor` when request interception depends on async shared state such as token refresh
- Keep base URL, headers, timeouts, and adapter configuration in DI or client bootstrap code

## Setup

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
    responseType: ResponseType.json,
    headers: {
      'Accept': 'application/json',
    },
  ),
);
```

Use one configured instance per backend unless there is a real reason to split clients by concern.

## Core Requests

```dart
final response = await dio.get(
  '/users',
  queryParameters: {'page': 1},
);

final created = await dio.post(
  '/users',
  data: {'name': 'Raphael'},
);

final custom = await dio.request(
  '/users/42',
  options: Options(method: 'PATCH'),
  data: {'name': 'Updated'},
);
```

Prefer the typed verbs (`get`, `post`, `put`, `patch`, `delete`) unless you need a dynamic method.

## Interceptors

```dart
dio.interceptors.add(
  InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer token';
      handler.next(options);
    },
    onResponse: (response, handler) {
      handler.next(response);
    },
    onError: (error, handler) {
      handler.next(error);
    },
  ),
);
```

Use interceptors for:

- auth headers
- request/response logging
- retry or refresh-token orchestration
- consistent transport-level error normalization

Use `QueuedInterceptor` when requests must pass sequentially through async logic:

```dart
class AuthInterceptor extends QueuedInterceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await loadAccessToken();
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
```

## Error Handling

```dart
try {
  final response = await dio.get('/profile');
  return response.data;
} on DioException catch (e) {
  if (e.response != null) {
    throw ApiFailure.server(
      statusCode: e.response?.statusCode,
      message: e.response?.data.toString(),
    );
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      throw const ApiFailure.timeout();
    case DioExceptionType.cancel:
      throw const ApiFailure.cancelled();
    default:
      throw ApiFailure.network(e.message ?? 'Unknown network error');
  }
}
```

Do not leak raw `DioException` outside the transport boundary unless the layer above is explicitly transport-aware.

## Timeouts, Cancellation, and Concurrency

```dart
final cancelToken = CancelToken();

final response = await dio.get(
  '/search',
  cancelToken: cancelToken,
);

cancelToken.cancel('Disposed by caller');
```

```dart
final responses = await Future.wait([
  dio.get('/info'),
  dio.get('/token'),
]);
```

Use cancellation for search, screen disposal, and flows where stale requests should not complete into state updates.

## Uploads and FormData

```dart
Future<FormData> buildUploadForm() async {
  return FormData.fromMap({
    'name': 'avatar',
    'file': await MultipartFile.fromFile(
      '/tmp/avatar.png',
      filename: 'avatar.png',
    ),
  });
}

await dio.post(
  '/upload',
  data: await buildUploadForm(),
);
```

For multiple files:

```dart
final formData = FormData();
formData.files.addAll([
  MapEntry(
    'files',
    MultipartFile.fromFileSync('/tmp/a.txt', filename: 'a.txt'),
  ),
  MapEntry(
    'files',
    MultipartFile.fromFileSync('/tmp/b.txt', filename: 'b.txt'),
  ),
]);
```

## Downloading and Response Types

```dart
await dio.download(
  'https://example.com/file.pdf',
  '/tmp/file.pdf',
);

final bytes = await dio.get<List<int>>(
  '/image',
  options: Options(responseType: ResponseType.bytes),
);

final stream = await dio.get(
  '/video',
  options: Options(responseType: ResponseType.stream),
);
```

## Adapters and Platform Notes

```dart
import 'package:dio/io.dart';

dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () {
    final client = HttpClient();
    return client;
  },
);
```

- Native platforms use `IOHttpClientAdapter`
- Web uses `BrowserHttpClientAdapter`
- Proxy and certificate customization are native-platform concerns
- Web cannot set proxy the same way as `dart:io`

Certificate pinning belongs in adapter configuration, not in repositories or request call sites.

## Logging

```dart
dio.interceptors.add(
  LogInterceptor(
    responseBody: false,
    requestBody: false,
  ),
);
```

In Flutter, prefer `debugPrint` via `logPrint` for long lines. Do not enable verbose logging in production by default.

## Testing

Test the API client abstraction, not `Dio` itself.

```dart
test('maps 404 to not found failure', () async {
  when(() => dio.get('/users/1')).thenThrow(
    DioException(
      requestOptions: RequestOptions(path: '/users/1'),
      response: Response(
        requestOptions: RequestOptions(path: '/users/1'),
        statusCode: 404,
      ),
      type: DioExceptionType.badResponse,
    ),
  );

  expect(
    () => apiClient.getUser('1'),
    throwsA(isA<NotFoundFailure>()),
  );
});
```

Mock or fake the client boundary your service owns. Verify mapping, headers, parameters, and cancellation behavior that matters to the app.

## Project Workflow

1. Inspect `lib/data/services/api_client/api_client.dart` for the service contract
2. Implement transport details in `lib/data/services/api_client/api_client_impl.dart`
3. Keep DTO parsing and request construction in the API client
4. Return repository or project failure types instead of raw transport exceptions
5. Update tests in `test/data/services/api_client/`
6. Touch `lib/injector.dart` only when client wiring, interceptors, or async setup changes

## Project-Specific Notes

- `Dio` should remain registered through dependency injection
- The selected base URL depends on app flavor/configuration
- Repositories may compose local and remote sources, but HTTP concerns stay in the remote service path
- If startup requires async transport setup, make readiness explicit before `runApp()`

## Anti-Patterns

```dart
// ❌ Creating a new client per request
Future<Response> loadUser() {
  final dio = Dio();
  return dio.get('/user');
}

// ✅ Reuse injected client
class ApiClientImpl {
  ApiClientImpl(this._dio);

  final Dio _dio;
}
```

```dart
// ❌ Reusing FormData across requests
final form = FormData.fromMap({...});
await dio.post('/upload', data: form);
await dio.post('/upload', data: form); // Can fail

// ✅ Build a fresh FormData each time
await dio.post('/upload', data: await createFormData());
```

```dart
// ❌ Leaking DioException from repository-facing API
Future<User> getUser() async => (await dio.get('/user')).data;

// ✅ Map transport failures at the boundary
Future<User> getUser() async {
  try {
    return mapper.fromJson((await dio.get('/user')).data);
  } on DioException catch (e) {
    throw mapDioException(e);
  }
}
```
