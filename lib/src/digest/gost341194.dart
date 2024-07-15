import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

class Gost341194CryptoProParamSet {
  // Private constructor
  Gost341194CryptoProParamSet._internal();

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
  late final void Function(ffi.Pointer<Utf8>) _freeRustString;

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

    return result;
  }
}
