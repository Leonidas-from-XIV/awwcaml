package main

import (
	"bytes"
	"encoding/gob"
	"io/ioutil"
	"log"
)

func main() {
	var buf bytes.Buffer
	enc := gob.NewEncoder(&buf)

	err := enc.Encode(true)
	if err != nil {
		log.Fatal("encode error:", err)
	}

	err = ioutil.WriteFile("bool.gob", buf.Bytes(), 0644)
	if err != nil {
		log.Fatal("write error:", err)
	}

	buf.Reset()
	enc = gob.NewEncoder(&buf)
	var ui uint = 23
	err = enc.Encode(ui)
	if err != nil {
		log.Fatal("encode error:", err)
	}

	err = ioutil.WriteFile("uint.gob", buf.Bytes(), 0644)
	if err != nil {
		log.Fatal("write error:", err)
	}

	buf.Reset()
	enc = gob.NewEncoder(&buf)
	var i int = -42
	err = enc.Encode(i)
	if err != nil {
		log.Fatal("encode error:", err)
	}

	err = ioutil.WriteFile("int.gob", buf.Bytes(), 0644)
	if err != nil {
		log.Fatal("write error:", err)
	}

	buf.Reset()
	enc = gob.NewEncoder(&buf)
	err = enc.Encode("Hello Caml!")
	if err != nil {
		log.Fatal("encode error:", err)
	}

	err = ioutil.WriteFile("string.gob", buf.Bytes(), 0644)
	if err != nil {
		log.Fatal("write error:", err)
	}

	buf.Reset()
	enc = gob.NewEncoder(&buf)
	ba := []byte{24, 42, 13, 37}
	err = enc.Encode(ba)
	if err != nil {
		log.Fatal("encode error:", err)
	}

	err = ioutil.WriteFile("bytearray.gob", buf.Bytes(), 0644)
	if err != nil {
		log.Fatal("write error:", err)
	}
}
