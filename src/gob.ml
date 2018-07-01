module Gob = struct
  type t =
    | Bool of bool
    | Uint of Int64.t
    | Int of Int64.t
    | Float of float
    | Byteslice of bytes
    | String of string
end

let decode_uint
  : Bitstring.bitstring -> (Int64.t * Bitstring.bitstring)
  = fun bits ->
  match%bitstring bits with
  | {| value_or_length : 8;
       rest : -1 : bitstring |} ->
    match (value_or_length < 128, value_or_length) with
    | (true, value) -> (Int64.of_int value), rest
    | (false, inverted_length) ->
      match%bitstring rest with
      | {| v : (256 - inverted_length) : bigendian;
           rest : -1 : bitstring |} -> v, rest

let decode_bool bits =
  let n, rest = decode_uint bits in
  Int64.(n = one), rest

let decode_int
  : Bitstring.bitstring -> (Int64.t * Bitstring.bitstring)
  = fun bits ->
  let go_uint, bits = decode_uint bits in
  let go_uint = match Int64.logand go_uint Int64.one with
    | n when n > Int64.zero -> Int64.lognot go_uint
    | _ -> go_uint
  in
  (Int64.shift_right_logical go_uint 1, bits)

let decode_byte_slice
  : Bitstring.bitstring -> (bytes * Bitstring.bitstring)
  = fun bits ->
  let length, bits = decode_uint bits in
  let length = Int64.to_int length in
  match%bitstring bits with
  | {| byte_slice : length * 8 : string;
       rest : -1 : bitstring |} ->
    (Bytes.of_string byte_slice, rest)

let decode_string bits =
  let slice, rest = decode_byte_slice bits in
  (Bytes.to_string slice, rest)

let read_segment
  : Bitstring.bitstring -> (Bitstring.bitstring * Bitstring.bitstring)
  = fun bits ->
  let length, buf = decode_uint bits in
  let length = Int64.to_int length in
  match%bitstring buf with
  | {| segment : length * 8 : bitstring;
       rest : -1 : bitstring |} -> (segment, rest)

let decode_value
  : int -> Bitstring.bitstring -> (Gob.t * Bitstring.bitstring)
  = fun type_id bits ->
  match type_id with
  | 1 ->
    let v, rest = decode_bool bits in
    (Gob.Bool v, rest)
  | 2 -> 
    let v, rest = decode_int bits in
    (Gob.Int v, rest)
  | 3 -> 
    let v, rest = decode_uint bits in
    (Gob.Uint v, rest)
  | 4 -> 
    failwith "Decoding floats unsupported"
  | 5 -> 
    let v, rest = decode_byte_slice bits in
    (Gob.Byteslice v, rest)
  | 6 -> 
    let v, rest = decode_string bits in
    (Gob.String v, rest)
  | _ -> failwith "Not implemented"

let load
  : string -> Gob.t
  = fun str ->
  let bits = Bitstring.bitstring_of_string str in
  let segment, _rest = read_segment bits in
  let type_id, segment = decode_int segment in
  let type_id = Int64.to_int type_id in
  let value, _rest = decode_value type_id segment in

  value

