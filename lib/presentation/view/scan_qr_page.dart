import 'dart:io';

import 'package:larba_00/common/common_package.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../common/const/utils/languageHelper.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({Key? key}) : super(key: key);

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            formatsAllowed: const [BarcodeFormat.qrcode],
            overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderWidth: 10.0,
                borderRadius: 10.0),
          ),
          Positioned(
            top: 48.0,
            right: 0,
            left: 0,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        controller?.dispose();
                        Navigator.pop(context, '');
                      },
                      icon: SvgPicture.asset(
                        'assets/svg/arrow_left.svg',
                        height: 18,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      TR(context, 'QR 코드 스캔'),
                      style: typo18semibold.copyWith(color: WHITE),
                    ),
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      if (result != null) {
        this.controller!.dispose();
        print(result!.code!);
        Navigator.pop(context, result!.code!);
      }
    });
  }
}
