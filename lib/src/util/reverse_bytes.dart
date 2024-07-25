String reverseBytes(String hexString) {
  // Ensure the length of the string is even
  if (hexString.length % 2 != 0) {
    throw ArgumentError('Invalid hex string length');
  }

  // Split the string into chunks of two characters
  List<String> byteChunks = [];
  for (int i = 0; i < hexString.length; i += 2) {
    byteChunks.add(hexString.substring(i, i + 2));
  }

  // Reverse the order of the chunks
  List<String> reversedChunks = byteChunks.reversed.toList();

  // Join the reversed chunks back into a single string
  String reversedHexString = reversedChunks.join('');
  return reversedHexString;
}

// print(reverseUint8List(Uint8List.fromList(hex.decode(
//       'a7714d2bea23f82cf6fe1e8a92d0f952493230cc5bc6412d1c8f49fb7b7f393b'))));
//   print(Uint8List.fromList(hex.decode(
//       '3b397f7bfb498f1c2d41c65bcc30324952f9d0928a1efef62cf823ea2b4d71a7')));
//       Uint8List reverseUint8List(Uint8List list) {
//   return Uint8List.fromList(list.reversed.toList());
// }

// a7714d2bea23f82cf6fe1e8a92d0f952493230cc5bc6412d1c8f49fb7b7f393b
// 3b397f7bfb498f1c2d41c65bcc30324952f9d0928a1efef62cf823ea2b4d71a7