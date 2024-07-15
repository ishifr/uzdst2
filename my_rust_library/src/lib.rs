use std::ffi::{CStr, CString};
use std::fs::File;
use std::io::{self, BufReader, Read};
use std::os::raw::c_char;

use gost94::Digest;

const CHUNK_SIZE: usize = 1024 * 1024; // 1MB chunk size

#[no_mangle]
pub extern "C" fn hash_gost94(input: *const c_char) -> *mut c_char {
    let c_str = unsafe {
        assert!(!input.is_null());
        CStr::from_ptr(input)
    };

    let r_str = c_str.to_str().unwrap();
    let mut hasher = gost94::Gost94CryptoPro::new();
    hasher.update(r_str.as_bytes());
    let result = hasher.finalize();
    
    let hex_result = result.iter()
        .map(|byte| format!("{:02x}", byte))
        .collect::<String>();

    CString::new(hex_result).unwrap().into_raw()
}


#[no_mangle]
pub extern "C" fn hash_gost94_file(file_path: *const c_char) -> *mut c_char {
    let c_str = unsafe {
        assert!(!file_path.is_null());
        CStr::from_ptr(file_path)
    };

    let path_str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => return CString::new("Error: Invalid file path").unwrap().into_raw(),
    };

    match hash_file(path_str) {
        Ok(hash) => CString::new(hash).unwrap().into_raw(),
        Err(e) => CString::new(format!("Error: {}", e)).unwrap().into_raw(),
    }
}

pub fn hash_file(path_str: &str) -> Result<String, io::Error> {
    let file = File::open(path_str)?;
    let mut reader = BufReader::new(file);
    let mut hasher =gost94::Gost94CryptoPro::new();
    let mut buffer = vec![0; CHUNK_SIZE];

    loop {
        match reader.read(&mut buffer) {
            Ok(0) => break, // EOF reached
            Ok(n) => hasher.update(&buffer[..n]),
            Err(e) => return Err(e),
        }
    }

    let result = hasher.finalize();
    let hex_result = result.iter()
        .map(|byte| format!("{:02x}", byte))
        .collect::<String>();


    Ok(hex_result)
}

#[no_mangle]
pub extern "C" fn free_rust_string(s: *mut c_char) {
    if s.is_null() { return }
    unsafe {
        let _ = CString::from_raw(s);
    };
}
