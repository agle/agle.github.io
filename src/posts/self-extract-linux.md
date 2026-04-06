---
title: Single-binary dynamic executables with makeself
date: 2026-04-06
template: post.html
---


This is a "where has this tool been my whole life?" post.

Linux makes it notoriously hard to package software across distros with its
particular shared-library situation.

Often I would like to take a bundle of shared objects, a binary, package them
together and distribute them to another computer, (say a server).

The tool to use for this is [makeself](https://makeself.io/). This
generates a script with a tarball concatenated on the end, such that the script
extracts itself, and runs a script inside the tarball.


This way you create a structure like:

```
dir/libs/
  libfoo.so
  libbar.so
  libbaz.so
dir/
  start.sh
  main.exe
```

With the contents of start.sh being:

```bash
#!/usr/bin/env bash
LD_LIBRARY_PATH=libs ./main.exe
```

Then run:

```
./makeself.sh dir binary "my program" ./start.sh
```

And it will build a single file `binary`, which appears
to run `main.exe` with the libraries loaded.

Of course, this is a bit of a hack. It's inadvisable to distribute glibc, and
you should ensure your software licences permit you to vendor these shared
objects. However its Good Enough(R), as long as your target system has a similar
enough glibc.

Nevertheless this mostly solves problem of distributing Linux programs,
(e.g. OCaml programs using depexts), without delving into nightmares of
flatpak, appimage, dev, rpm, containers. 
