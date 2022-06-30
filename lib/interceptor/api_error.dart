class ApiError implements Exception {
  int? code;
  String? message;
  String? apiUri;

  ///相对路径
  ApiError({this.apiUri, this.code, this.message});
}
