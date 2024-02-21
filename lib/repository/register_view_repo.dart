import '../data/network/api_services.dart';
import '../data/respnse/app_urls.dart';

class RegisterRepository {
  final _apiServices = ApiServices();

  Future<dynamic> registerApi(String username, String password) async {
    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
    };

    final response = await _apiServices.postApi(data, _buildRegisterUrl(username, password));
    return response;
  }

  Future<dynamic> loginApi(String username, String password) async {
    final Map<String, dynamic> data = {
      "username": username,
      "password": password,
    };

    final response = await _apiServices.postApi(data, _buildLoginUrl(username, password));
    return response;
  }

  Future<Map<String, dynamic>?> fetchDataApi({
    required String username,
    required String mode,
    required String start,
    required String end,
  }) async {
    final apiUrl = 'http://203.135.63.22:8000/data?username=$username&mode=$mode&start=$start&end=$end';

    try {
      final response = await _apiServices.getApi(apiUrl);

      if (response != null) {
        // Check if the response contains the expected data
        if (response.containsKey('statusCode') && response.containsKey('data')) {
          return response;
        } else {
          // Handle unexpected response format
          print('Unexpected response format: $response');
          return null;
        }
      } else {
        // Handle unexpected null response
        print('Unexpected null response');
        return null;
      }
    } catch (error) {
      // Handle API request error
      print('Error fetching data: $error');
      return null;
    }
  }

  String _buildRegisterUrl(String username, String password) {
    final String baseUrl = AppUrl.base;
    final String urlWithParams = '$baseUrl?username=$username&password=$password';
    return urlWithParams;
  }

  String _buildLoginUrl(String username, String password) {
    final String baseUrl = AppUrl.base;
    final String urlWithParams = '$baseUrl?username=$username&password=$password';
    return urlWithParams;
  }
}
