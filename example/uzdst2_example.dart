import 'package:uzdst2/src/curve.dart';
import 'package:uzdst2/uzdst2.dart';

void main() {
  var algo = Uzdst2();
  var curve = Curve.cryptoProCParamSet;
  var keyPair = algo.generateKeyPair(curve);
  Signature s = algo.sign('Hello Ecdsa!', null, keyPair.privateKey, curve);
  print("${s.r}\n${keyPair.privateKey}");
  print(algo.verify('Hello Ecdsa!', null, s, keyPair.publicKey, curve));
}
