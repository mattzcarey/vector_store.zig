// WIP FFI bindings for Zig
import { dlopen, FFIType, ptr, suffix } from "bun:ffi";

const path = `./zig-out/lib/libvector_store.${suffix}`;

const lib = dlopen(path, {
  vector_store_init: {
    args: [FFIType.u64],
    returns: FFIType.ptr,
  },
  vector_store_deinit: {
    args: [FFIType.ptr],
    returns: FFIType.void,
  },
  vector_store_load_vector: {
    args: [FFIType.ptr, FFIType.ptr],
    returns: FFIType.cstring,
  },
  vector_store_search: {
    args: [FFIType.ptr, FFIType.f32, FFIType.u8],
    returns: FFIType.ptr,
  },
});

let store = lib.symbols.vector_store_init(3);
console.log(store);

const vectors = [
  [0.1, 0.2, 0.3],
  [0.4, 0.5, 0.6],
  [0.7, 0.8, 0.9],
];

const float32array = new Float32Array(vectors[0]);

const loadRes = lib.symbols.vector_store_load_vector(store, ptr(float32array));
console.log(loadRes);

const query = [0.35, 0.45, 0.55];
const queryF32 = new Float32Array(query);
const top_k = 2;
const result = lib.symbols.vector_store_search(store, queryF32, top_k);

console.log(result);
