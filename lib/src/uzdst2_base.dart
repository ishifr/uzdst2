library uzdst2;

import 'dart:math';
import 'dart:typed_data';

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

  /// step 1. calculate the hash function of the message: m=H(M);
  /// step 2. calculate e ≡ m (mod t). If e=0, then set e=1; here t = curve.n
  /// step 3. generate a random integer k satisfying the inequality 0 < k < t;
  /// step 4. calculate the point on the elliptic curve C=[k]N and define r=x_c (mod t),
  /// where x_c is the x-coordinate of point C. If r=0, return to step 3;
  /// step 5. calculate the value s ≡ (rd+ke) (mod t). If s=0, return to step 3; (d is privateKey)
  Signature sign(
    BigInt privateKey,
    Curve curve, {
    String? message,
    String? filePath,
    Uint8List? byteArray,
  }) {
    BigInt k;
    ECPoint R;
    BigInt r;
    BigInt s;

    if (message == null && filePath == null && byteArray == null) {
      Exception('message, filePath and byteArray are null');
    }
    // step 1.
    String m = message != null
        ? rustLib.hashString(message)
        : filePath != null
            ? rustLib.hashFile(filePath)
            : rustLib.hashByteArray(byteArray!);

    //step 2.
    final z = BigInt.parse(
        m.codeUnits.map((i) => i.toRadixString(16).padLeft(2, '0')).join(),
        radix: 16);
    BigInt e = z % curve.n;
    e == BigInt.zero ? e = BigInt.one : "";
    final random = Random.secure();
    do {
      // step 3.
      k = BigInt.parse(
          List<int>.generate(32, (_) => random.nextInt(256))
              .map((i) => i.toRadixString(16).padLeft(2, '0'))
              .join(),
          radix: 16);
      //  step 4.
      R = ECPoint(curve, curve.gX, curve.gY) * k; // C=[k]N
      r = R.x % curve.n; // r=x_c (mod t)
      // step 5.
      s = (r * privateKey + k * e) % curve.n;
    } while (r == BigInt.zero || s == BigInt.zero);

    return Signature(r, s);
  }

  /// step 1. 0<r<t, 0<s<t is not valid
  /// step 2. m = H(M);
  /// step 3. e = m(mod t) If e=0, then set e=1
  /// step 4. v = e^(-1) (mod t)
  /// step 5. z1 = sv(mod t)  z2 = -rv (mod t)
  /// step 6. C = [z1]N“+”[z2]T, R = x_c (mod t)
  bool verify(
    Signature signature,
    ECPoint publicKey,
    Curve curve, {
    String? message,
    String? filePath,
    Uint8List? byteArray,
  }) {
    if (message == null && filePath == null && byteArray == null) {
      Exception('message, filePath and byteArray are null');
    }
    // step 1.
    if (!(BigInt.zero < signature.r && signature.r < curve.n) ||
        !(BigInt.zero < signature.s && signature.s < curve.n)) {
      return false;
    }
    // step 2.
    String m = message != null
        ? rustLib.hashString(message)
        : filePath != null
            ? rustLib.hashFile(filePath)
            : rustLib.hashByteArray(byteArray!);
    final z = BigInt.parse(
        m.codeUnits.map((i) => i.toRadixString(16).padLeft(2, '0')).join(),
        radix: 16);
    // step 3.
    BigInt e = z % curve.n;
    e == BigInt.zero ? e = BigInt.one : "";
    // step 4.
    BigInt v = e.modInverse(curve.n);
    // step 5.
    BigInt z1 = (signature.s * v) % curve.n;
    BigInt z2 = -(signature.r * v) % curve.n;
    // step 6.
    ECPoint c = ECPoint(curve, curve.gX, curve.gY) * z1 + publicKey * z2;

    return c.x % curve.n == signature.r;
  }
}
