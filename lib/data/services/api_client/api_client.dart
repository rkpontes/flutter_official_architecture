abstract class ApiClient {
  Future get(String path, {Map<String, String>? headers});
  Future post(String path, {Map<String, String>? headers, dynamic body});
  Future put(String path, {Map<String, String>? headers, dynamic body});
  Future patch(String path, {Map<String, String>? headers, dynamic body});
  Future delete(String path, {Map<String, String>? headers});
}
