import 'package:uzdst2/src/curve.dart';
import 'package:uzdst2/src/ec_point.dart';

// m=H(M);
// e=m(mod t)

final privateKey = BigInt.parse(
    '7A929ADE789BB9BE10ED359DD39A72C11B60961F49397EEE1D19CE9891EC3B28',
    radix: 16);
// 3221B4FBBF6D101074EC14AFAC2D4F7EFAC4CF9FEC1ED11BAE336D27D527665 2
// 5358F8FFB38F7C09ABC782A2DF2A3927DA4077D07205F763682F3A76C9019B4F 1
final z = BigInt.parse(
    '5358F8FFB38F7C09ABC782A2DF2A3927DA4077D07205F763682F3A76C9019B4F',
    radix: 16);
//   77105C9B20BCD3122823C8CF6FCC7B956DE33814E95B7FE64FED924594DCEAB3
BigInt k = BigInt.parse(
    '77105C9B20BCD3122823C8CF6FCC7B956DE33814E95B7FE64FED924594DCEAB3',
    radix: 16);

BigInt e = BigInt.parse(
    '2DFBC1B372D89A1188C09C52E0EEC61FCE52032AB1022E8E67ECE6672B043EE5',
    radix: 16);

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

class Uzdst2BaseTest {
  KeyPair generateKeyPair(Curve curve) {
    final publicKey = ECPoint(curve, curve.gX, curve.gY) * privateKey;

    return KeyPair(privateKey, publicKey);
  }

  Signature sign(BigInt privateKey, Curve curve) {
    ECPoint R;
    BigInt r;
    BigInt s;

    do {
      R = ECPoint(curve, curve.gX, curve.gY) * k;
      r = R.x % curve.n;
      // e = z % curve.n;
      // s = (z + r * privateKey) * k.modInverse(curve.n) % curve.n;
      //s ≡ (rd+ke) (mod t)
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
  bool verify(Signature signature, ECPoint publicKey, Curve curve) {
    // step 1. 0<r<t, 0<s<t
    if (!(BigInt.zero < signature.r && signature.r < curve.n) ||
        !(BigInt.zero < signature.s && signature.s < curve.n)) {
      print("from first condition");
      return false;
    }
    // step 4.
    BigInt v = e.modInverse(curve.n);
    print(
        "v: ${v.toRadixString(16).toUpperCase() == '271A4EE429F84EBC423E388964555BB29D3BA53C7BF945E5FAC8F381706354C2'}");
    // step 5.
    BigInt z1 = (signature.s * v) % curve.n;
    print(
        "z1: ${z1.toRadixString(16).toUpperCase() == '5358F8FFB38F7C09ABC782A2DF2A3927DA4077D07205F763682F3A76C9019B4F'}");
    BigInt z2 = -(signature.r * v) % curve.n;
    print(
        "z2: ${z2.toRadixString(16).toUpperCase() == '3221B4FBBF6D101074EC14AFAC2D4F7EFAC4CF9FEC1ED11BAE336D27D527665'}");

    ECPoint c = ECPoint(curve, curve.gX, curve.gY) * z1 + publicKey * z2;

    print(
        "x_c: ${c.x.toRadixString(16).toUpperCase() == '41AA28D2F1AB148280CD9ED56FEDA41974053554A42767B83AD043FD39DC0493'}");
    print(
        "y_c: ${c.y.toRadixString(16).toUpperCase() == '489C375A9941A3049E33B34361DD204172AD98C3E5916DE27695D22A61FAE46E'}");

    return c.x % curve.n == signature.r;
  }
}

void main() {
  var algo = Uzdst2BaseTest();
  var curve = Curve.algo2Test;
  var keyPair = algo.generateKeyPair(curve);
  Signature s = algo.sign(keyPair.privateKey, curve);
  print("${s.r}\n${s.s}");
  print(algo.verify(s, keyPair.publicKey, curve));
}
// 29700980915817952874371204983938256990422752107994319651632687982059210933395
// 574973400270084654178925310019147038455227042649098563933718999175515839552

String intToHex(int number) {
  return number.toRadixString(16);
}

int hexToInt(String hexString) {
  return int.parse(hexString, radix: 16);
}
