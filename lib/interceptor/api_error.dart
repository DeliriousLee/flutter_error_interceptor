class ApiError implements Exception {
  int? code;
  String? message;

  ///相对路径
  String? apiUri;
  dynamic data;

  ApiError({this.apiUri, this.code, this.message, this.data});
}
