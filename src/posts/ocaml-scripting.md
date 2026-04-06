---
title: OCaml for Scripting (simply)
date: 2026-03-20
template: post.html
---

A brief note on setting up ocaml as a toplevel.

We want to set up an opam switch with some libraries we want for scripting:


```bash
opam switch create script 5.4.0
eval $(opam env --switch=script)
opam install ocamlfind containers utop iter
```

- `ocamlfind` is neccessary to load libraries into the toplevel
- the [containers](https://github.com/c-cube/ocaml-containers) package gives us
  a nice IO wrapper, sexpr parsing and cleans up the standard library a bit.
  [Iter](https://github.com/c-cube/iter) is a useful companion to containers. 
- [utop] gives us a better interactive repl


We define an init file like below, save it to `~/.ocaml_script_init`.

```ocaml
#use "topfind";;
Topfind.log:=ignore;;
#require "containers";;
#require "containers.unix";;
open Containers;;
open Fun;; (* I like to open fun to have access infix compose etc. *)
```

If saved instead in `~/.ocamlinit` it will be picked up by default by
`utop` and `ocaml` repls.

For script files we can write a wrapper script to invoke ocaml with our
default setup and save it somewhere in `$PATH`:

```bash
#!/usr/bin/env bash
E=$(mktemp --suffix=.ml)
# tail -n +2 to drop the shebang line
cat ~/.ocaml_script_init > $E 
tail -n +2 $@ >> $E
opam exec --switch script -- utop $E
rm $E 
# save to ~/.local/bin/ocamlscript
# chmod +x ~/.local/bin/ocamlscript
```

```ocaml
#!/usr/bin/env ocamlscript
let () = CCIO.read_lines_iter stdin 
  |> Iter.map (CCSexp.parse_string %> Result.get_exn) 
  |> Iter.to_list %> CCSexp.list 
  |> CCSexp.to_chan stdout 
```

```shell
$ chmod +x test.ml
$ printf "(hello)\n(world)" | ./test.ml 
((hello) (world))
```


This ended up less neat than I would like.

### Related work

These try and address the shortcomings of the naive piping to the repl
structure, such as by automatically fetching package dependencies and compiling
with `ocamlopt` rather than interpreting bytecode.

- OCamlScript : [github.com/ocaml-community/ocamlscript](https://github.com/ocaml-community/ocamlscript)
- b0caml: [erratique.ch/software/b0caml](https://erratique.ch/software/b0caml)
