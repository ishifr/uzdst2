import 'dart:typed_data';

import 'package:uzdst2/src/privateKeyInfo/prv_key_info.dart';
import 'package:uzdst2/uzdst2.dart';

class SignWithPrvKey {
  late final algo = Uzdst2();

  /// provide with private key info bytes
  Signature sign(Uint8List bytes, String message) {
    late final a = PrivateKeyInfo.fromASN1(bytes);
    Signature s = algo.sign(BigInt.parse('${a.privateKey}', radix: 16), a.curve,
        message: 'Hello Ecdsa!');
    // print("${s.r}\n${s.s}");

    return s;
  }
}
