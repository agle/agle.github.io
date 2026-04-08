---
title: agle \\ alicia michael
template: post.html 
---

I am Alicia, a static program analysis research engineer based in Meanjin
(Brisbane), Australia.

#### Research Interests

I work on research towards formal verification of information-flow-security of
compiled binary (AArch64) programs. This feeds my varied interests across
static analysis, compilers and de-compilers, automated reasoning, SMT, and
program verification. I have a persistent interest in software performance and
fitness-for-purpose. The problem solving loop of how to address this gnarly
multifaceted problem with the right conceptual and practical tools is what
keeps me interested.

I love working in the OCaml programming language, and feel that interest
encompasses my aspirations as a software engineer. OCaml is designed with a
seriousness, care and consideration, [practical application of formal
methods](https://ocaml.org/papers) coupled with a pragmatism ([63-bit ints](https://blog.janestreet.com/what-is-gained-and-lost-with-63-bit-integers/)) and
[evidence-orientation](https://www.youtube.com/watch?v=XGGSPpk1IB0), that I can
only hope to emulate.

#### Publications

- Sadra Bayat Tork, Nicholas Coughlin, Alicia Michael, James Tobler and Kirsten Winter. Data Structure Analysis for Binaries. TACAS 2026.

- Nicholas Coughlin, Alicia Michael, Kait Lam,. (2025). Lift-Offline: Instruction Lifter Generators. In: Giacobazzi, R., Gorla, A. (eds) Static Analysis. SAS 2024. Lecture Notes in Computer Science, vol 14995. Springer, Cham. [https://doi.org/10.1007/978-3-031-74776-2_4](https://doi.org/10.1007/978-3-031-74776-2_4)

#### Talks

- Boogie-Backed Translation Validation for Decompilation 
  - June 2025, FMOz @ The University of Queensland
- Procedure-Local Rely-Guarantee Specifications for Binaries
  - June 2024, FMOz @ The University of Queensland

#### Projects

Most of my recent work is within [BASIL](https://github.com/UQ-PAC/BASIL).
Basil aims to prove binary programs adhere to a security classification specification,
i.e. addressing the information-flow security problem. Working at the binary level,
it requires decompilation, which utilises the [ASLp](http://github.com/uq-pac/aslp) lifter.

I spent most of the last two years working on a simple program optimiser for
BASIL geared towards improving the precision of abstract interpreters, and
subsquently an SMT-based translation validator for said optimiser. 

Part of my mission has been to improve the developer experience so that our
student collaborators get the most out of their experience contributing to the
project, and can have as much impact as possible. To this end I have worked on
the surrounding tooling, including on BASIL's IR design, textual IR
representation, static analysis and rewriting framework and language-server
support for such.

Recently I have been working on a successor project,
[bincaml](https://github.com/agle/bincaml/), in the same problem space, and am
thrilled to see it already taking a life of its own through students'
contributions.

Earlier, interning at Oracle Labs Brisbane I worked on adding a (Souffle)
datalog-based policy language and checker to the
[macaron](https://github.com/oracle/macaron) software supply chain security
posture analyser.

