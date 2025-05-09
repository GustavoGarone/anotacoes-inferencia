# From khoffie at https://discourse.nixos.org/t/setting-up-r-and-julia-rcall-does-not-find-r-packages/59632. Thanks!
with import <nixpkgs> {};
let
  my-r = (rWrapper.override {
    packages = with pkgs.rPackages; [
      sf
      cli
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
      pypkgs.jupyter-cache
      pypkgs.matplotlib
    ]))
    my-r
    gcc
    R
    julia
    curl
  ]);
  runScript = "zsh";
}).env

