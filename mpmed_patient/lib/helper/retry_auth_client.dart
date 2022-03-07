import 'package:http/retry.dart';
import 'package:http/http.dart' as http;

class RetryAuthentication{
  
  RetryClient retryAuth() {
    return RetryClient(
  http.Client(),
  retries: 1,
  when: (response) {
    return response.statusCode == 401 ? true : false;
  },
  onRetry: (req, res, retryCount) async {
    if (retryCount == 0 && res?.statusCode == 401) {
      var headers = {
        'Authorization':
            'Basic OGFiMTdiOTAtZmMzYy00ZjYyLTljYzMtMzlkZGEzZjNkMTM0OmRlZGQ3Nzg2ODkyZTc5ZmJjMmY5ODQ1ZThiYTdiODQ1ZWI0ZjIwMzVjN2VlOTJiNzhiZmYwNTMxNTM5MTViM2I=',
        'Content-Type': 'application/x-www-form-urlencoded'
      };
      var request = http.Request(
          'POST',
          Uri.parse(
              'https://api.mpmed.ir/public/index.php/authorization/token'));
      request.bodyFields = {
        'grant_type': 'refresh_token',
        'refresh_token':
            '2aff058f29fa56bad091-e005523880345f2087293ec97783bb2ea239bcc5e3d93b4b-f00bae886f'
      };
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
      } else {
        print(response.reasonPhrase);
      }
    }
  },
);
  }
}