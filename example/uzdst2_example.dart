import 'package:uzdst2/src/curve.dart';
import 'package:uzdst2/src/ec_point.dart';
import 'package:uzdst2/src/privateKeyInfo/prv_key_info.dart';
import 'package:uzdst2/uzdst2.dart';

void main() async {
  var algo = Uzdst2();
  var curve = Curve.cryptoProCParamSet;
  final fileInfo =
      await getKeyInfoFromFile('/Users/ishifr/Downloads/test-root-uzdst2.prk');
  var a = PrivateKeyInfo.fromASN1(fileInfo);
  // var keyPair = algo.generateKeyPair(curve);
  Signature s = algo.sign(
      'Hello Ecdsa!', null, BigInt.parse('${a.privateKey}', radix: 16), curve);
  print("${s.r}\n${s.s}");
  ECPoint publicKey = ECPoint(curve, curve.gX, curve.gY) *
      BigInt.parse(a.privateKey!, radix: 16);
  print(algo.verify('Hello Ecdsa!', null, s, publicKey, curve));
}
