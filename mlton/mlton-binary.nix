{
  lib,
  stdenv,
  fetchurl,
  patchelf,
  gmp,
}:
let
  dynamic-linker = stdenv.cc.bintools.dynamicLinker;
in
stdenv.mkDerivation rec {
  pname = "mlton";
  version = "20210117";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      (fetchurl {
        url = "https://github.com/MLton/mlton/releases/download/on-${version}-release/${pname}-${version}-1.amd64-linux-glibc2.31.tgz.tgz";
        sha256 = "0f4q575yfm5dpg4a2wsnqn4l2zrar96p6rlsk0dw10ggyfwvsjlf";
      })
    else if stdenv.hostPlatform.system == "x86_64-darwin" then
      (fetchurl {
        url = "https://github.com/MLton/mlton/releases/download/on-${version}-release/${pname}-${version}-1.amd64-darwin-19.6.gmp-static.tgz";
        sha256 = "1cw7yhw48qp12q0adwf8srpjzrgkp84kmlkqw3pz8vkxz4p9hbdv";
      })
    else if stdenv.hostPlatform.system == "aarch64-linux" then
      (fetchurl {
        url = "https://github.com/ii8/mlton-builds/releases/download/${version}/${pname}-${version}.aarch64-linux-gnu.tar.gz";
        sha256 = "sha256-ps8oqAsbAW8VP06H8Fc9KO00Tiw9Tb+Y8RGix9zSupQ=";
      })
    else
      throw "Architecture not supported";

  buildInputs = [ gmp ];
  nativeBuildInputs = lib.optional stdenv.hostPlatform.isLinux patchelf;

  buildPhase =
    if stdenv.hostPlatform.system == "aarch64-linux" then
      ''''
    else
      ''
        make update \
          CC="$(type -p cc)" \
          WITH_GMP_INC_DIR="${gmp.dev}/include" \
          WITH_GMP_LIB_DIR="${gmp}/lib"
      '';

  installPhase =
    if stdenv.hostPlatform.system == "aarch64-linux" then
      ''
        mkdir -p $out
        tar -xzf $src -C $out
        mv $out/${pname}-${version}.aarch64-linux-gnu/* $out/
        rmdir $out/${pname}-${version}.aarch64-linux-gnu
      ''
    else
      ''
        make install PREFIX=$out
      '';

  postFixup =
    if stdenv.hostPlatform.system == "aarch64-linux" then
      ''''
    else
      lib.optionalString stdenv.hostPlatform.isLinux ''
        patchelf --set-interpreter ${dynamic-linker} $out/lib/mlton/mlton-compile
        patchelf --set-rpath ${gmp}/lib $out/lib/mlton/mlton-compile

        for e in mllex mlnlffigen mlprof mlyacc; do
          patchelf --set-interpreter ${dynamic-linker} $out/bin/$e
          patchelf --set-rpath ${gmp}/lib $out/bin/$e
        done
      ''
      + lib.optionalString stdenv.hostPlatform.isDarwin ''
        install_name_tool -change \
          /opt/local/lib/libgmp.10.dylib \
          ${gmp}/lib/libgmp.10.dylib \
          $out/lib/mlton/mlton-compile

        for e in mllex mlnlffigen mlprof mlyacc; do
          install_name_tool -change \
            /opt/local/lib/libgmp.10.dylib \
            ${gmp}/lib/libgmp.10.dylib \
            $out/bin/$e
        done
      '';

  meta = import ./meta.nix;
}
