import 'dart:typed_data';
import '../const/utils/convertHelper.dart';
import 'rlp.dart' as rlp;
import '../dartapi/lib/trx_pb.pb.dart';

Uint8List createMsg(String chainId, TrxProto trx, [bool isRlpEncode = true]) {
  var rlpEncodeData = rlpEncode(trx, isRlpEncode);
  var prefixByte = createPrefix(chainId, rlpEncodeData);

  // msg : prefix + rlpEncodeData
  Uint8List msg = Uint8List.fromList([...prefixByte, ...rlpEncodeData]);
  return msg;
}

Uint8List createPrefix(String chainId, Uint8List rlpEncodeData) {
  int len = rlpEncodeData.length;
  String prefixStr = "\x19RIGO($chainId) Signed Message:\n$len";
  Uint8List prefixByte = Uint8List.fromList(prefixStr.codeUnits);
  return prefixByte;
}

Uint8List rlpEncodeList(List t) {
  return rlp.encode(t);
}

Uint8List rlpEncode(TrxProto trx, [bool isRlpEncode = true]) {
  // Version uint64
  var version = BigInt.from(trx.version).toUnsigned(64);

  // Time uint64
  var time = BigInt.parse(trx.time.toString()).toUnsigned(64);

  // Nonce uint64
  var nonce = BigInt.parse(trx.nonce.toString()).toUnsigned(64);

  // From address
  var from = trx.from;

  // To address
  var to = trx.to;

  // Amount []byte
  var amount = trx.amount;

  // Gas uint64
  var gas = BigInt.parse(trx.gas.toString()).toUnsigned(64);

  // GasPrice []byte
  var gasPrice = trx.gasPrice;

  // Type uint64
  var type = BigInt.from(trx.type).toUnsigned(64);

  // Payload []byte
  var payload = trx.payload;
  if (isRlpEncode && trx.payload.isNotEmpty) {
    payload = rlp.encode(trx.payload);
  }

  // Sig []byte
  // LOG('--> payload : ${trx.payload} => ${payload}');

  return rlp.encode(
      [version, time, nonce, from, to, amount, gas, gasPrice, type, payload.length==0 ? "" : payload, ""]);
}
