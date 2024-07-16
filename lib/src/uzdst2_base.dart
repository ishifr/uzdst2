library uzdst2;

import 'dart:math';

import 'package:uzdst2/src/curve.dart';
import 'package:uzdst2/src/digest/gost341194.dart';
import 'package:uzdst2/src/ec_point.dart';

class KeyPair {
  final BigInt privateKey;
  final ECPoint publicKey;

  KeyPair(this.privateKey, this.publicKey);
}

class Signature {
  final BigInt r;
  final BigInt s;

  Signature(this.r, this.s);
}

class Uzdst2 {
  // Access the Singleton instance
  var rustLib = Gost341194CryptoProParamSet.instance;

  KeyPair generateKeyPair(Curve curve) {
    final random = Random.secure();
    final privateKey = BigInt.parse(
      List<int>.generate(32, (_) => random.nextInt(256))
          .map((i) => i.toRadixString(16).padLeft(2, '0'))
          .join(),
      radix: 16,
    );

    final publicKey = ECPoint(curve, curve.gX, curve.gY) * privateKey;

    return KeyPair(privateKey, publicKey);
  }

  Signature sign(
      String? message, String? filePath, BigInt privateKey, Curve curve) {
    if (message == null && filePath == null) {
      Exception('message and filePath are null');
    }
    var hashedMessage = message != null
        ? rustLib.hashString(message)
        : rustLib.hashFile(filePath!);
    final z = BigInt.parse(
        hashedMessage.codeUnits
            .map((i) => i.toRadixString(16).padLeft(2, '0'))
            .join(),
        radix: 16);
    final random = Random.secure();
    BigInt k;
    ECPoint R;
    BigInt r;
    BigInt s;

    do {
      k = BigInt.parse(
        List<int>.generate(32, (_) => random.nextInt(256))
            .map((i) => i.toRadixString(16).padLeft(2, '0'))
            .join(),
        radix: 16,
      );
      R = ECPoint(curve, curve.gX, curve.gY) * k;
      r = R.x % curve.n;
      s = (z + r * privateKey) * k.modInverse(curve.n) % curve.n;
    } while (r == BigInt.zero || s == BigInt.zero);

    return Signature(r, s);
  }

  bool verify(String? message, String? filePath, Signature signature,
      ECPoint publicKey, Curve curve) {
    if (message == null && filePath == null) {
      Exception('message and filePath are null');
    }
    var hashedMessage = message != null
        ? rustLib.hashString(message)
        : rustLib.hashFile(filePath!);
    final z = BigInt.parse(
        hashedMessage.codeUnits
            .map((i) => i.toRadixString(16).padLeft(2, '0'))
            .join(),
        radix: 16);
    final w = signature.s.modInverse(curve.n);
    final u1 = z * w % curve.n;
    final u2 = signature.r * w % curve.n;
    final point = (ECPoint(curve, curve.gX, curve.gY) * u1) + (publicKey * u2);

    return point.x % curve.n == signature.r;
  }
}
