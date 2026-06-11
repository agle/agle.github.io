---
title: Filesystem-dependent metaprgramming in Scala3
date: 2026-06-12
template: post.html
---

Scala being a JVM language naturally compiles to a set of
class files on disk. While there are no restrictinos
on what we can make a Scala identifier, the filesyste
imposes some.

In particular, a case insensitive filesystem means that two classes whose names
differ only in _case_ will overwrite eachother at compile time. This results in
a compiler warning and a runtime crash when the dynamic type checker finds a
method call on a class with the wrong name.

Naturally on finding Scala has filesystem-sensitvity-dependent semantics, by
[Hyrum's law](https://www.hyrumslaw.com/) we can exploit this to our
benefit.


```scala
// test.sc

import java.nio.file.Path
import java.nio.file.Paths

object σ:
  def apply() = true

object Σ:
  def apply() = false

def sensitive() = 
  try 
    Σ() !=  σ()
  catch _ => false


given fileconv : Conversion[String, Path] with
  def apply(x: String): Path = Paths.get(if sensitive() then x else x.toLowerCase )

def toPath(x: Path) = println(x)

toPath("./CaSe SeNsItIvE")
```

Linux:

```
$ scala-cli test.sc
Compiling project (Scala 3.8.3, JVM (21))
[warn] ./test.sc:9:8
[warn] Generated class test$_$Σ$ differs only in case from test$_$σ$.
[warn]   Such classes will overwrite one another on case-insensitive filesystems.
[warn] object Σ:
[warn]        ^
Warning: there was 1 feature warning; re-run with -feature for details
Compiled project (Scala 3.8.3, JVM (21))
./CaSe SeNsItIvE
```


Macos: 

```
~ % scala test.sc
[warn] ./test.sc:9:8
[warn] Generated class test$_$Σ$ differs only in case from test$_$σ$.
[warn]   Such classes will overwrite one another on case-insensitive filesystems.
[warn] object Σ:
[warn]        ^
Compiling project (Scala 3.8.4, JVM (26))
Warning: there was 1 feature warning; re-run with -feature for details
Compiled project (Scala 3.8.4, JVM (26))
./case sensitive
```

This behaviour is less odd in Java because it requires classes to only be defined in
source files of the same name, so such a problem would appear at the source level---impossible
to write it on a case-insensitive filesystem, or appearing on checkout rather than runtime.



