# From khoffie at https://discourse.nixos.org/t/setting-up-r-and-julia-rcall-does-not-find-r-packages/59632. Thanks!
with import <nixpkgs> {};
let
  my-r = (rWrapper.override {
    packages = with pkgs.rPackages; [
      sf
    ];
  });
  pkgs = import <nixpkgs> {inherit config;};
in
(pkgs.buildFHSEnv {
  name = "jupytriota";
  targetPkgs = pkgs: (with pkgs; [
    (python3.withPackages (pypkgs: [
      pypkgs.pip
      pypkgs.numpy
      pypkgs.ipython
      pypkgs.jupyter
      pypkgs.matplotlib
    ]))
    my-r
    gcc
    R
    julia
    curl
  ]);

  # Discouraged, find alternative solution
  # NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
  #   gcc  # ...
  #   gfortran
  #   stdenv
  #   openspecfun
  #   curl
  #   proj
  #   sqlite
  #   geos
  #   libssh2
  # ];
  # NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
  # shellHook = ''
  #   # Set R_LIBS_USER to an empty value to avoid unwanted user-specific libraries
  #   export LD_LIBRARY_PATH="${my-r}/lib/R/lib:$LD_LIBRARY_PATH"
  #   export R_LIBS_USER=""
  #   export R_LIBS_SITE=$(R RHOME)/library
  #   export R_HOME=$(R RHOME)
  # '';
  runScript = "zsh";
}).env

