import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/asn1.dart';

import 'package:uzdst2/src/curve.dart';
import 'package:uzdst2/src/ec_point.dart';
import 'package:uzdst2/src/util/reverse_bytes.dart';

getKeyInfoFromFile(String path) async {
  File file = File(path);
  Uint8List f = await file.readAsBytes();
  return f;
}

void main(List<String> args) async {
  final fileInfo =
      await getKeyInfoFromFile('/Users/ishifr/Downloads/test-root-uzdst2.prk');
  var a = PrivateKeyInfo.fromASN1(fileInfo);
}

class PrivateKeyInfo {
  ECPoint? publicKey;
  ECPoint? reversedPublicKey;
  String? privateKey;
  late Curve curve;
  PrivateKeyInfo.fromASN1(Uint8List bytes) {
    var parser = ASN1Parser(bytes);
    var seq = parser.nextObject() as ASN1Sequence;
    if (seq.elements == null || (seq.elements?.length ?? 0) < 2) {
      throw ArgumentError('Something wrong with sequence');
    }
    if (seq.elements?[2].tag == ASN1Tags.OCTET_STRING) {
      parser = ASN1Parser(seq.elements?[2].valueBytes);
      seq = parser.nextObject() as ASN1Sequence;
      if (seq.elements == null || (seq.elements?.length ?? 0) < 2) {
        throw ArgumentError('Something wrong with inner sequence');
      }
      if (seq.elements?[1].tag == ASN1Tags.OCTET_STRING) {
        var temp = seq.elements?[1];
        privateKey = hex.encode(temp?.valueBytes ?? []);
      }
      if (seq.elements?[2] != null &&
          seq.elements![2].tag! >= 0xA0 &&
          seq.elements![2].tag! <= 0xBF) {
        var csc = ASN1Parser(seq.elements![2].valueBytes).nextObject();
        ASN1ObjectIdentifier ecOID = csc as ASN1ObjectIdentifier;
        if (ecOID.readableName ==
            'UZDST 1092:2009 II signature parameters, UNICON.UZ paramset A') {
          curve = Curve.cryptoProAParamSet;
        } else {
          curve = Curve.cryptoProCParamSet;
        }
        publicKey = ECPoint(curve, curve.gX, curve.gY) *
            BigInt.parse(privateKey!, radix: 16);
        print("x: ${publicKey!.x.toRadixString(16)}");
        print("y: ${publicKey!.y.toRadixString(16)}");
        reversedPublicKey = ECPoint(
            curve,
            BigInt.parse(reverseBytes(publicKey!.x.toRadixString(16)), radix: 16),
            BigInt.parse(reverseBytes(publicKey!.y.toRadixString(16)), radix: 16));

        print("r x: ${reversedPublicKey!.x.toRadixString(16)}");
        print("r y: ${reversedPublicKey!.y.toRadixString(16)}");
      }
    } else {
      throw ArgumentError('Something wrong with sequence');
    }
  }
}
// 0440
// a7714d2bea23f82cf6fe1e8a92d0f952493230cc5bc6412d1c8f49fb7b7f393b
// 9c7260773ec6ecc7674799561566eb62daa7d99d674f0d0f68991ade7b4d664b