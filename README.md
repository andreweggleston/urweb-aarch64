# urweb on aarch64-linux
I use NixOS (btw)--which means I have to deal with NixOS's non-FHS compliance. All of my development environments are distributed as flakes, so I'm restricted to using packages that are available on nixpkgs (or package them myself, but I'm not a Nix pro by any means)

I've been interested in making a webapp using [Ur/Web](http://www.impredicative.com/ur/) -- a domain specific language for writing webapps that, to quote the creator, "don't go wrong". Ur/Web uses a lot of type magic to give some seriously strong guarantees to the developer. Cool!

Fortunately, urweb has already been packaged for Nix by a kind soul! It has a few buildtime dependencies; openssl, sqlite, and some thing called 'mlton'.
MLton is also packaged on nixpkgs, but unfortunately it is only packaged for [ "x86_64-darwin" "x86_64-linux" "i686-linux" ]. I'm running Asahi Linux, so I'm on aarch64-linux--I need to modify mlton to be able to build on my platform.

This could be a real issue. MLton is a self hosted compiler, so I could be SOL if I can't find a recent-(ish) version of MLton for aarch64-linux to bootstrap from. Thankfully, another kind soul has builds of mlton for all sorts of architectures, aarch64-linux included: [ii8/mlton-builds](https://github.com/ii8/mlton-builds)

In this repository I've modified the upstream mlton package to, if being built on aarch64-linux, be bootstrapped from the mlton-builds repository. As of Nov 13th, 2024, I've got MLton 20210117 compiling itself on aarch64-linux. Hooray! 

Until I can figure out how to submit my changes to nixpkgs (which would be my first commit there), this repository will hold my experimentation with Ur/Web as well as the mlton overlay.
