---
title: I wrote an ssg again
date: 2026-04-24
template: post.html
---


<br>


> The perfect website builder has never been created, it is up to you to
> build it.

For whatever reason proper web design is not something I've ever had the patience to learn properly, this includes "real" website generators like hugo, jekyll and the millions of others. Every time I've made a website its been some html or markdown hacked together with pandoc and some python or makefiles.

At one point I wrote the build script in C++, then another time in C, in order to directly link to the fastest markdown implementations. These basic static site generators always tend to have a basic struture:


1. Traverse some directory tree and discover the content and templating rules
2. Some map/reduce style processing of the site datastructure. Build markdown content, preprocess it for some syntax highlighting or tex math redering and so on.
3. Inject the content into some site templates and write the tree to disk.

  
I think there's a good argument for keeping it this basic and understandable.
On the other hand there are many projects that take this general observation
and run it to its logical conclusion in whatever direction. The logical
conclusion ranging from, "your website is actually a single json file" to "your
website is actually profunctor".

The opinion I have on my websites is that generally they shouldn't need javascript. Despite this I want some features sometimes like math rendering and syntax highlighting.

Thankfully there's a reasonably developed ecosystem of web focussed libraries in OCaml so I can just plug things together in a relatively short script (including a robust markdown library with good traversal apis).

Unfortunately the problems I like to solve again led me to writing the minimal OCaml bindings for quickjs so I could pre-run the $KaTeX$ math renderer. Then I decided I should make the templating based on lua. This is maximally flexible if you're willing to be quite hacky.

Anyway, this website is built with [site build](https://github.com/agle/sb). Its a 600 line OCaml program with:

- commonmark with extensions (cmarkit)
- lua-based templating (ocaml-lua)
- rss feed generation (rss)
- server-side code highlighting for languages supported by hilite: ocaml, dune, opam, sh, shell, diff, bash
- server-side $\LaTeX$ rendering using KaTeX
- local live preview

Its distributed as a [self-extracting tarball](https://agle.github.io/posts/self-extract-linux.html) so despite having heterogenous native dependencies I can easily pull the binary from inside CI and rebuild the site on push. This leads to a deploy time of 17 seconds.

Lua templates are quite nice to be honest, if perhaps a bit inscrutible the way I've hacked it together[^1]. The post list looks like this:

[^1]: Its also cool that Simon Cruanes released [lua generators](https://github.com/c-cube/ezlua/) in the time since I wrote this, which would definitely clean up the implementation a bit.


```lua
p = child_pages('./posts')

for k,v in pairs(p) do
    print([[<li>
        <div style="width:100\%">
            <div style="float:right">]] .. v.title .. [[</div>
            <div class=date><a href="]] .. v.url  .. [[">]] .. (os.date("%d %B %Y", v.date)) .. [[</a></div> 
        </div>
        </li>]])
end
```


This post is certainly not an endorsement of the tool as a robust website
generator, merely an enumeraton of my personal laziest possible way to make a
satisfying website.

I'm happy because finally I get to have all three:

- server side $\LaTeX$ rendering
- server side syntax highlighting
- good templating
