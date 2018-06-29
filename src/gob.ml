module Types = struct
  let bool = 1
  let int = 2
  let unit = 3
  let float = 4
  let byte_slice = 5
  let string = 6
  (* this is as far as we care to implement *)
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
    Bytes.of_string byte_slice, rest
