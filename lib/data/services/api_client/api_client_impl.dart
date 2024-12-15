// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:flutter_oficial_architecture/data/services/api_client/api_client.dart';
import 'package:flutter_oficial_architecture/utils/exceptions.dart';

class ApiClientImpl implements ApiClient {
  ApiClientImpl(this._dio);

  final Dio _dio;

  @override
  Future delete(
    String path, {
    Map<String, String>? headers,
  }) {
    try {
      return _dio
          .delete(path, options: Options(headers: headers))
          .then((response) => response.data);
    } catch (e) {
      throw ApiClientException('Error deleting path: $path');
    }
  }

  @override
  Future get(
    String path, {
    Map<String, String>? headers,
  }) {
    try {
      return _dio
          .get(path, options: Options(headers: headers))
          .then((response) => response.data);
    } catch (e) {
      throw ApiClientException('Error getting path: $path');
    }
  }

  @override
  Future post(
    String path, {
    Map<String, String>? headers,
    body,
  }) {
    try {
      return _dio
          .post(path, data: body, options: Options(headers: headers))
          .then((response) => response.data);
    } catch (e) {
      throw ApiClientException('Error posting path: $path');
    }
  }

  @override
  Future put(
    String path, {
    Map<String, String>? headers,
    body,
  }) {
    try {
      return _dio
          .put(path, data: body, options: Options(headers: headers))
          .then((response) => response.data);
    } catch (e) {
      throw ApiClientException('Error putting path: $path');
    }
  }

  @override
  Future patch(
    String path, {
    Map<String, String>? headers,
    body,
  }) {
    try {
      return _dio
          .patch(path, data: body, options: Options(headers: headers))
          .then((response) => response.data);
    } catch (e) {
      throw ApiClientException('Error patching path: $path');
    }
  }
}
