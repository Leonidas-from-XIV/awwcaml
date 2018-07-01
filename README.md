awwcaml
=======

A library to wrap your OCaml code to work on AWS Lambda.

How it works
------------

It implements the necessary bits to pretend your binary is a Go binary, thus
speaking `net/rpc` and communicating via the `Gobs` serialization format.
