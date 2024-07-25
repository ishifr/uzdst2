// ignore_for_file: dangling_library_doc_comments

import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/asn1.dart';
import 'package:uzdst2/src/curve.dart';
import 'package:uzdst2/uzdst2.dart';

///```
/// CertificationRequest ::= SEQUENCE {
///   certificationRequestInfo CertificationRequestInfo,
///   signatureAlgorithm AlgorithmIdentifier{{ SignatureAlgorithms }},
///   signature          BIT STRING   Signature s + r as byte array
/// }
///```
///```
/// CertificationRequestInfo ::= SEQUENCE {
///   version       INTEGER { v1(0) } (v1,...),
///   subject       Name,
///   subjectPKInfo SubjectPublicKeyInfo{{ PKInfoAlgorithms }},
///   attributes    [0] Attributes{{ CRIAttributes }}   --> we dont need attributes this time.
/// }
///```
///```
/// SubjectPublicKeyInfo { ALGORITHM : IOSet} ::= SEQUENCE {
///   algorithm        AlgorithmIdentifier {{IOSet}},
///   subjectPublicKey BIT STRING
/// }
///```

ASN1SubjectPublicKeyInfo makeSubjectPublicKeyInfo() {
  var subjectPKInfo = ASN1SubjectPublicKeyInfo(
      ASN1AlgorithmIdentifier(
          ASN1ObjectIdentifier([1, 2, 860, 3, 15, 1, 1, 2, 1]),
          parameters: ASN1Sequence(elements: [
            ASN1ObjectIdentifier([1, 2, 860, 3, 15, 1, 1, 2, 1, 1])
          ])),
      ASN1BitString(
        stringValues: hex.decode(
            '04407f37e4913225e79b5388ee7a9d964142af3872128d7857c1ab70e716ea00c241c930498379634a8fc00562e0f5f32662bb577f5101db486bbfaa6a9c1ac49318'),
      ));
  return subjectPKInfo;
}

ASN1Object makeCertificationRequestInfo() {
  var certificationRequestInfo = ASN1CertificationRequestInfo(
      ASN1Integer(BigInt.zero),
      ASN1Name([
        ASN1RDN(
          ASN1Set(elements: [
            ASN1Sequence(elements: [
              ASN1ObjectIdentifier([2, 5, 4, 3]),
              ASN1PrintableString(
                  stringValue: "YANGI TEXNOLOGIYALAR ILMIY-AXBOROT MARKAZI DUK")
            ])
          ]),
        ),
        ASN1RDN(
          ASN1Set(elements: [
            ASN1Sequence(elements: [
              ASN1ObjectIdentifier([2, 5, 4, 6]),
              ASN1PrintableString(stringValue: 'UZ')
            ])
          ]),
        ),
      ]),
      makeSubjectPublicKeyInfo());

  print(base64.encode(certificationRequestInfo.encode()));

  return certificationRequestInfo;
}

makePkcs10() {
  var cri = makeCertificationRequestInfo();
  var algo = Uzdst2();
  var curve = Curve.cryptoProAParamSet;
  var keyPair = algo.generateKeyPair(curve);
  Signature s = algo.sign(keyPair.privateKey, curve, byteArray: cri.encode());
  print("sr:${s.r.toRadixString(16)}\nss:${s.s.toRadixString(16)}\n${s}");
  var certificationRequest = ASN1CertificationRequest(
    cri,
    ASN1AlgorithmIdentifier(
        ASN1ObjectIdentifier.fromIdentifierString('1.2.860.3.15.1.1.2.2.2.2')),
    ASN1BitString(stringValues: [
      ...hex.decode(s.s.toRadixString(16)),
      ...hex.decode(s.r.toRadixString(16))
    ]),
  );
  print(base64.encode(certificationRequest.encode()));
}

void main(List<String> args) {
  // var temp = ASN1SubjectPublicKeyInfo.fromSequence(makeSubjectPublicKeyInfo());
  // print(temp.algorithm.algorithm.dump());
  // print(hex.encode(temp.subjectPublicKey.stringValues!));

  // makeCertificationRequestInfo();
  makePkcs10();
}
