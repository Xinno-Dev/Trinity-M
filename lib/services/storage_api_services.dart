import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/domain/model/storage_model.dart';
import 'package:larba_00/services/http_error_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageAPIServices {
  Future<StorageModel> read(String uid) async {
    try {
      final http.Response response = await http.get(
        Uri.parse(API_HOST + '/api/v1/mauth-doc/$uid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(httpErrorHandler(response));
      }
      final result = json.decode(response.body);
      final storageModel = StorageModel.fromJson(result);
      return storageModel;
    } on SocketException catch (e) {
      throw Exception(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<StorageModel> create(
      String uid, String publicKey, String pushToken) async {
    try {
      final http.Response response = await http.post(
        Uri.parse(API_HOST + '/api/v1/mauth-doc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {
            "uid": uid,
            "publicKey": publicKey,
            "pushToken": pushToken,
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(httpErrorHandler(response));
      }
      final result = json.decode(response.body);
      final storageModel = StorageModel.fromJson(result);
      return storageModel;
    } catch (e) {
      rethrow;
    }
  }
}

final storageServiceProvider =
    Provider<StorageAPIServices>((ref) => StorageAPIServices());
