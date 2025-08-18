---
title: Website builders
date: 2025-06-27
template : layout.html
---

Static site generators are a fun easy project to lose time in but an 
annoying time-sink when you do just want a website.

This time we restrict the scope to just "build _this_ website" rather than provide general
website building techniques and it goes okay. I've landed on a $\approx 300$ 
line OCaml script using `cmarkit`, and `hilite` for markdown 
rendering, and standard library regex for templating.

I usually make a point of avoiding client-side Javascript, but I think
I can live with $\KaTeX$ if needed. In theory it is straightforward to bundle
katex with QuickJS to run it server side (like the katex Rust crate),
but FFI is a bit too much work for me to bother immediately.
