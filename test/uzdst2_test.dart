import 'package:test/test.dart';
import 'package:uzdst2/src/digest/gost341194.dart';

void main() {
  // Access the Singleton instance
  var rustLib = Gost341194CryptoProParamSet();

  // Initialize the FFI functions (this should be done once)
  rustLib.initialize();
  test('check', () {
    expect(rustLib.hashString(""),
        "981e5f3ca30c841487830f84fb433e13ac1101569b9c13584ac483234cd656c0");
    expect(rustLib.hashString("This is message, length=32 bytes"),
        "2cefc2f7b7bdc514e18ea57fa74ff357e7fa17d652c75f69cb1be7893ede48eb");
    expect(
        rustLib
            .hashString("Suppose the original message has length = 50 bytes"),
        "c3730c5cbccacf915ac292676f21e8bd4ef75331d9405e5f1a61dc3130a65011");
    expect(
        rustLib.hashString(
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"),
        "73b70a39497de53a6e08c67b6d4db853540f03e9389299d9b0156ef7e85d0f61");
    expect(rustLib.hashFile("asset/100mb.txt"),
        "6fa869c4d4545d9acb443d41f5b87584cd99d2928118cb355e7c139622f8c267");
  });
}
