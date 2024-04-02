import 'dart:typed_data';

import 'bytes.dart' as bytes;
import 'package:pointycastle/pointycastle.dart';


///
/// Creates SHA256 hash of the input.
///
Uint8List sha256(dynamic a) {
  a = bytes.toBuffer(a);
  Digest sha256 = new Digest("SHA-256");
  return sha256.process(a);
}