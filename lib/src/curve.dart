class Curve {
  final BigInt p; // The prime specifying the size of the finite field
  final BigInt a; // The coefficient a of the curve equation
  final BigInt b; // The coefficient b of the curve equation
  final BigInt n; // The order of the base point
  final BigInt gX; // x-coordinate of the base point G
  final BigInt gY; // y-coordinate of the base point G

  Curve(this.p, this.a, this.b, this.n, this.gX, this.gY);

  static final secp256k1 = Curve(
    BigInt.parse(
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
        radix: 16),
    BigInt.zero,
    BigInt.from(7),
    BigInt.parse(
        'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141',
        radix: 16),
    BigInt.parse(
        '79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798',
        radix: 16),
    BigInt.parse(
        '483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8',
        radix: 16),
  );
 
  static final algo2Test = Curve(
    BigInt.parse(
        '8000000000000000000000000000000000000000000000000000000000000431',
        radix: 16),
    BigInt.from(7),
    BigInt.parse(
        '5FBFF498AA938CE739B8E022FBAFEF40563F6E6A3472FC2A514C0CE9DAE23B7E',
        radix: 16),
    BigInt.parse(
        '8000000000000000000000000000000150FE8A1892976154C59CFC193ACCF5B3',
        radix: 16),
    BigInt.from(2),
    BigInt.parse(
        '08E2A8A0E65147D4BD6316030E16D19C85C97F0A9CA267122B96ABBCEA7E8FC8',
        radix: 16),
  );
  
  /// 1.2.860.3.15.1.1.2.1.1 
  static final cryptoProAParamSet = Curve(
    BigInt.parse(
        'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd97',
        radix: 16),
    BigInt.parse(
        'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffd94',
        radix: 16),
    BigInt.parse('a6', radix: 16),
    BigInt.parse(
        'ffffffffffffffffffffffffffffffff6c611070995ad10045841b09b761b893',
        radix: 16),
    BigInt.from(1),
    BigInt.parse(
        '8d91e471e0989cda27df505a453f2b7635294f2ddf23e3b122acc99c9e9f1e14',
        radix: 16),
  );
  
  /// 1.2.860.3.15.1.1.2.1.2
  static final cryptoProCParamSet = Curve(
    BigInt.parse(
        '9b9f605f5a858107ab1ec85e6b41c8aacf846e86789051d37998f7b9022d759b',
        radix: 16),
    BigInt.parse(
        '9b9f605f5a858107ab1ec85e6b41c8aacf846e86789051d37998f7b9022d7598',
        radix: 16),
    BigInt.parse('805a', radix: 16),
    BigInt.parse(
        '9b9f605f5a858107ab1ec85e6b41c8aa582ca3511eddfb74f02f3a6598980bb9',
        radix: 16),
    BigInt.from(0),
    BigInt.parse(
        '41ece55743711a8c3cbf3783cd08c0ee4d4dc440d4641a8f366e550dfdb3bb67',
        radix: 16),
  );
}
