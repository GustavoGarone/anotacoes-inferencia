{
  description = "Flake for R development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [pkgs.bashInteractive];
        buildInputs = with pkgs; [
          R
          rPackages.ggplot2
          rPackages.GGally
          rPackages.dplyr
          rPackages.tidyr
          rPackages.broom
          rPackages.kableExtra
          rPackages.languageserver
          blas
          julia
          curl
          gcc
          gfortran
          gfortran.cc.lib
          (python313.withPackages (ppkgs: [
            ppkgs.pynvim
            ppkgs.numpy
            ppkgs.pandas
            ppkgs.matplotlib
            ppkgs.seaborn
            ppkgs.flake8
            ppkgs.scipy
            ppkgs.black
            ppkgs.mdformat
            ppkgs.isort
            ppkgs.jupyter
            ppkgs.ipykernel
            ppkgs.jupyter-cache
          ]))
        ];
        shellHook = ''
          export LD_LIBRARY_PATH="${pkgs.gfortran.cc.lib}/lib"
          export R_REMOTES_NO_ERRORS_FROM_WARNINGS="TRUE"
        '';
      };
    });
}
