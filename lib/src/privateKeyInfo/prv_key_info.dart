import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

getKeyInfoFromFile(String path) async {
  File file = File(path);
  Uint8List f = await file.readAsBytes();
  return f;
}

void main(List<String> args) async {
  final fileInfo = await getKeyInfoFromFile('/Users/ishifr/Downloads/test-root-uzdst2.prk');
  var a = PrivateKeyInfo.fromASN1(fileInfo);
  var ecDomainParameters = ECDomainParameters('GostR3410-2001-CryptoPro-A');
  var q = ecDomainParameters.curve.decodePoint(a.publicKey!.codeUnits);
  print(q);
}

class PrivateKeyInfo {
  var publicKey;
  String? privateKey;
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
        print("privateKey: $privateKey");
      }
      if (seq.elements?[2] != null &&
          seq.elements![2].tag! >= 0xA0 &&
          seq.elements![2].tag! <= 0xBF) {
        var csc = ASN1Parser(seq.elements![2].valueBytes).nextObject();
        ASN1ObjectIdentifier ecOID = csc as ASN1ObjectIdentifier;
        print(ecOID.readableName);
        ECDomainParameters('GostR3410-2001-CryptoPro-A');
        print(ecOID.objectIdentifierAsString);
      }
      var obj = seq.elements?[3];
      if (obj != null && obj.tag! >= 0xA0 && obj.tag! <= 0xBF) {
        var csc = ASN1Parser(obj.valueBytes).nextObject();
        if (csc.tag == ASN1Tags.BIT_STRING) {
          var i = csc as ASN1BitString;
          publicKey = hex.encode(Uint8List.fromList(i.stringValues!));
          print("Publickey: ${hex.encode(Uint8List.fromList(i.stringValues!))}");
        }
      }
    } else {
      throw ArgumentError('Something wrong with sequence');
    }
  }
}
// 0440a7714d2bea23f82cf6fe1e8a92d0f952493230cc5bc6412d1c8f49fb7b7f393b9c7260773ec6ecc7674799561566eb62daa7d99d674f0d0f68991ade7b4d664b
// b6bd2faeb862252c6a7681c88fb7fe4c7dad39220ff3a68d3dd8b63945ed5c09