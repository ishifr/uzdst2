import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Define the C function signature
// ignore: camel_case_types
typedef hash_gost94_func = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8> data, ffi.IntPtr length);

// Define the C function signatures
typedef HashGost94Native = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8> data, ffi.IntPtr length);
typedef HashGost94Dart = ffi.Pointer<Utf8> Function(
    ffi.Pointer<ffi.Uint8> data, int length);
typedef FreeRustStringNative = ffi.Void Function(ffi.Pointer<Utf8>);
typedef FreeRustStringDart = void Function(ffi.Pointer<Utf8>);

class Gost341194CryptoProParamSet {
  // Private constructor
  Gost341194CryptoProParamSet._internal() {
    initialize();
  }
  static Gost341194CryptoProParamSet get instance => _instance;

  // The static instance of the Singleton
  static final Gost341194CryptoProParamSet _instance =
      Gost341194CryptoProParamSet._internal();

  // A factory constructor that returns the same instance
  factory Gost341194CryptoProParamSet() {
    return _instance;
  }

  // Path to the shared library
  late final ffi.DynamicLibrary _dylib;

  // Function pointers
  late final ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>) _hashString;
  late final ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>) _hashFile;
  late final HashGost94Dart _hashByteArray;
  late final void Function(ffi.Pointer<Utf8>) _freeRustString;
  late final FreeRustStringDart freeRustByteArray;

  // Initialization of the FFI functions
  void initialize() {
    // Define the path to the shared library
    final path = Platform.isLinux
        ? 'path/to/your/library.so'
        : Platform.isMacOS
            ? 'my_rust_library/target/release/libmy_rust_library.dylib'
            : 'path/to/your/library.dll';

    // Open the dynamic library
    _dylib = ffi.DynamicLibrary.open(path);
    // Look up the function
    _hashString = _dylib.lookupFunction<
        ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>),
        ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>)>("hash_gost94");

    // Look up the functions
    _hashByteArray = _dylib.lookupFunction<HashGost94Native, HashGost94Dart>(
        'hash_gost94ByteArray');
    freeRustByteArray =
        _dylib.lookupFunction<FreeRustStringNative, FreeRustStringDart>(
            'free_rust_string');

    // Look up the functions
    _hashFile = _dylib.lookupFunction<
        ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>),
        ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>)>("hash_gost94_file");

    _freeRustString = _dylib.lookupFunction<
        ffi.Void Function(ffi.Pointer<Utf8>),
        void Function(ffi.Pointer<Utf8>)>("free_rust_string");
  }

  // Method to call the hash function
  String hashFile(String filePath) {
    // Call the Rust function
    final resultPtr = _hashFile(filePath.toNativeUtf8());
    final result = resultPtr.toDartString();

    // Free the string allocated by Rust
    _freeRustString(resultPtr);

    return result;
  }

  String hashString(String text) {
    // Call the Rust function
    final resultPtr = _hashString(text.toNativeUtf8());
    final result = resultPtr.toDartString();

    // Free the string allocated by Rust
    _freeRustString(resultPtr);
    // _freeRustString(resultPtr);

    return result;
  }

  String hashByteArray(Uint8List data) {
    // Allocate memory for the Uint8List
    final ffi.Pointer<ffi.Uint8> dataPtr =
        malloc.allocate<ffi.Uint8>(data.length);
    ffi.Pointer<ffi.Uint8> dataStart = dataPtr.cast<ffi.Uint8>();
    // Copy data to the allocated memory
    for (int i = 0; i < data.length; i++) {
      dataStart[i] = data[i];
    }
    // Call the Rust function
    final ffi.Pointer<Utf8> resultPtr = _hashByteArray(dataStart, data.length);

    // Convert the result to a Dart string
    final String result = resultPtr.toDartString();

    // Free the allocated memory
    malloc.free(dataPtr);
    freeRustByteArray(resultPtr);

    return result;
  }
}

void main(List<String> args) {
  var rustLib = Gost341194CryptoProParamSet();
  print(rustLib.hashString(
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'));
  print(rustLib.hashByteArray(Uint8List.fromList(
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
          .codeUnits)));
}
