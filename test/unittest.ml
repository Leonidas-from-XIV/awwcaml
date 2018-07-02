let decode_bool () =
  Alcotest.(check bool) "same bool" true true

let test_gobs = [
  ("Decode bool", `Slow, decode_bool);
]

let () =
  Alcotest.run "Awwcaml unit tests" [
    ("Gob decoding", test_gobs);
  ]
