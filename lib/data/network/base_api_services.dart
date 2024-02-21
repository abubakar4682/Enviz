abstract class  BaseApiServices {
  Future<dynamic> getApi(String url);
  Future<dynamic> postApi(Map<String, dynamic> data, String url);

}
