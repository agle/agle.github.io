---
title: how-to
template: post.html
---

How to guides for computing.


### Minimise the size of source programs that produce a compiler/analyser bug

```sh
c-reduce --not-c
```

and the rewrite [cvise](https://github.com/marxin/cvise/), available in repos.

[https://bernsteinbear.com/blog/creduce/](https://bernsteinbear.com/blog/creduce/)

### Figure out where approximately a program is stuck in an infinite loop

```sh
while true; do sleep 1 ; pstack $(pgrep $program) ; done
```

### Generate a diff between two git refs of a latex document

```sh
latexdiff-vc -pdf --math-markup=0 --flatten -r 'HEAD^' -r 'HEAD' main.tex
```

latexdiff-vc is often included with texlive.

### Create a gif from a sequence of images

With a delay of 10 centiseconds (100 ms) between each image

```sh
convert *.jpg output.gif -delay 10
```

At an fps

```sh
convert *.jpg output.gif -delay $(bc -e "scale = 3; 100 / $fps")
```

### Rotate an image 90 degrees right

```sh
convert input.gif output.gif -rotate 90
```

