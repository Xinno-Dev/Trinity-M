import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/data/repository/ecc_repository_impl.dart';
import 'package:larba_00/domain/repository/ecc_repository.dart';
import 'package:larba_00/domain/usecase/ecc_usecase.dart';
import 'package:larba_00/domain/usecase/ecc_usecase_impl.dart';
import 'package:go_router/go_router.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class SignGenerateScreen extends StatefulWidget {
  static String get routeName => 'signGenerate';

  final String? noti;

  const SignGenerateScreen({super.key, required this.noti});

  @override
  State<SignGenerateScreen> createState() => _SignGenerateScreenState();
}

class _SignGenerateScreenState extends State<SignGenerateScreen> {
  // var asd = ConvertHelper().stringToMap(widget.noti);
  late Map<String, dynamic> notiMap;

  @override
  void initState() {
    notiMap = ConvertHelper().stringToMap(widget.noti);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final EccRepository _repository = EccRepositoryImpl();
    final EccUseCase _usecase = EccUseCaseImpl(_repository);
    final String rn = notiMap['RN'];

    return Scaffold(
      appBar: AppBar(title: Text('Sign')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(child: Text(notiMap['Service'])),
            Container(child: Text(rn)),
            Container(child: Text(notiMap['body'])),
            ElevatedButton(
              onPressed: () async {
                String sign = await _usecase.authSign('', rn);
                String b = await UserHelper().get_publickey();
                print('RN : ${notiMap['RN']}');
                print('signData : $sign');
                print('publickey : $b');
                var returnVerify =
                    await _usecase.verify(b, notiMap['RN'], sign);
                print(returnVerify);

                var returnVerifys =
                    await _usecase.verify(b, notiMap['RN'], sign);
                print(returnVerifys);

                final http.Response response = await http.post(
                  Uri.parse('http://' + notiMap['API']),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(
                    {
                      "uid": notiMap['UID'],
                      "sign": sign,
                    },
                  ),
                );

                if (response.statusCode == 200) {
                  print(response.body.toString());
                  print('통신 성공');
                } else {
                  print(response.statusCode);
                  print('통신 안성공');
                }

                // _usecase.updateSign('UID');
                context.go('/firebaseSetup');
              },
              child: Text('Sign'),
            ),
            ElevatedButton(
              onPressed: () async {
                print('RN : ${notiMap['RN']}');

                var utf8List = utf8.encode(notiMap['RN']);
                print('Uint8List.fromList(utf8List)');
                print(Uint8List.fromList(utf8List));
                var shaConvert = sha256.convert(utf8List);
                print('shaConvert.toString()');
                print(shaConvert.toString());
                print('createUint8ListFromHexString(shaConvert.toString())');
                print(createUint8ListFromHexString(shaConvert.toString()));
              },
              child: Text('Test SHA256'),
            ),
            ElevatedButton(onPressed: () async {}, child: Text('Press Auth'))
          ],
        ),
      ),
    );
  }
}
