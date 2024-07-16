import 'package:uzdst2/src/curve.dart';

class ECPoint {
  final Curve curve;
  final BigInt x;
  final BigInt y;
  final bool isInfinity;

  ECPoint(this.curve, this.x, this.y) : isInfinity = false;

  ECPoint.infinity(this.curve)
      : x = BigInt.zero,
        y = BigInt.zero,
        isInfinity = true;

  @override
  bool operator ==(Object other) =>
      other is ECPoint && x == other.x && y == other.y && isInfinity == other.isInfinity;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ isInfinity.hashCode;

  ECPoint operator +(ECPoint other) {
    if (isInfinity) return other;
    if (other.isInfinity) return this;

    if (x == other.x && y == (other.y * BigInt.from(-1) % curve.p)) {
      return ECPoint.infinity(curve); // Point at infinity
    }

    BigInt lambda;
    if (this == other) {
      // Point doubling
      lambda = (BigInt.from(3) * x * x + curve.a) *
          (BigInt.from(2) * y).modInverse(curve.p) %
          curve.p;
    } else {
      // Point addition
      lambda = (other.y - y) * (other.x - x).modInverse(curve.p) % curve.p;
    }

    final rx = (lambda * lambda - x - other.x) % curve.p;
    final ry = (lambda * (x - rx) - y) % curve.p;

    return ECPoint(curve, rx, ry);
  }

  ECPoint operator *(BigInt k) {
    if (k == BigInt.zero || isInfinity) {
      return ECPoint.infinity(curve);
    }
    var result = ECPoint.infinity(curve); // Point at infinity
    var addend = this;

    while (k > BigInt.zero) {
      if ((k & BigInt.one) != BigInt.zero) {
        result += addend;
      }
      addend = addend + addend; // Point doubling
      k >>= 1;
    }

    return result;
  }
}

