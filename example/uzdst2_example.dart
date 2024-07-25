import 'package:uzdst2/src/curve.dart';
import 'package:uzdst2/src/ec_point.dart';
import 'package:uzdst2/src/privateKeyInfo/prv_key_info.dart';
import 'package:uzdst2/src/privateKeyInfo/sign_with_prv_key_info.dart';
import 'package:uzdst2/uzdst2.dart';

void main() async {
  var algo = Uzdst2();
  var curve = Curve.cryptoProAParamSet;
  final fileInfo =
      await getKeyInfoFromFile('/Users/ishifr/Downloads/test-root-uzdst2.prk');
  final a = SignWithPrvKey().sign(fileInfo, '');

  // print(algo.verify(a, publicKey, curve));
}
// 0440
// a7714d2bea23f82cf6fe1e8a92d0f952493230cc5bc6412d1c8f49fb7b7f393b
// 9c7260773ec6ecc7674799561566eb62daa7d99d674f0d0f68991ade7b4d664b

// a7714d2bea23f82cf6fe1e8a92d0f952493230cc5bc6412d1c8f49fb7b7f393b
// 3b397f7bfb498f1c2d41c65bcc30324952f9d0928a1efef62cf823ea2b4d71a7

// 9c7260773ec6ecc7674799561566eb62daa7d99d674f0d0f68991ade7b4d664b

