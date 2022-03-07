import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;

class NotifProvider with ChangeNotifier {
  Future<void> registerToken(String token, String ntcode) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://mpmed.ir/mp_app/v1/api.php?apicall=fcm_token_validator'));
    request.fields
        .addAll({'ntcode': ntcode, 'fcm_token': token, 'user_type': 'patient'});

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> sendNotificationToDoc(String r_token, String title, String body,
      String click_action, Map click_action_args) async {
    print('Send Notif to token=$r_token');
    var headers = {
      'Authorization':
          'key=AAAAgTqRGO8:APA91bGwe4iQ1R-SEAvgJZWeOIdy8e-c3a99cHnBkjUeCdOlWc91q4BAaAwEmsmnZxSdn-DICyi4ondr3j0WGN_fqWHnPT35vt7aIbpCQppV1BUK4w1pWtV56CytHMbBvx7a3Hd2BHn-',
      'Content-Type': 'application/json'
    };
    var request =
        http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
    request.body = json.encode({
      "to": r_token,
      "notification": {"title": title, "body": body, "sound": "default"},
      "data": {"click_action": click_action, "arguments": click_action_args}
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}
