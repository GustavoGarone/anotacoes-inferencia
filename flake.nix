{
  description = "Flake for quarto development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      pythonEnv = pkgs.python313.withPackages (ps:
        with ps; [
          numpy
          scipy
          pandas
          matplotlib
          ipython
        ]);
      my-tex = pkgs.texlive.combine {
        inherit
          (pkgs.texlive)
          scheme-small
          framed
          lualatex-math
          collection-latexextra
          collection-luatex
          collection-langportuguese
          collection-fontsrecommended
          biber
          ;
      };

      # Extract the site-packages path directly in Nix
      pythonPath = "${pythonEnv}/${pkgs.python313.sitePackages}";
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          R
          rPackages.ggplot2
          rPackages.gganimate
          rPackages.gifski # Dependency for animation
          rPackages.png # Dependecy
          rPackages.GGally
          rPackages.dplyr
          rPackages.tidyr
          rPackages.broom
          rPackages.kableExtra
          rPackages.languageserver
          quarto
          my-tex
          julia-bin
          pythonEnv
        ];

        # Export these so direnv picks them up automatically
        R_HOME = "${pkgs.R}/lib/R";
        LIBR = "${pkgs.R}/lib/R/lib/libR.so";
        PYTHONPATH = pythonPath;
        JULIA_PYTHONCALL_EXE = "${pythonEnv}/bin/python";
        JULIA_CONDAPKG_BACKEND = "Null";

        shellHook = ''
          # Update Julia Preferences automatically so RCall works properly
          julia --project=. -e '
            using Pkg, Preferences
            set_preferences!(Pkg.Types.UUID("6f49c342-dc21-5d91-9882-a32aef131414"), "Rhome" => "'$R_HOME'", "libR" => "'$LIBR'", force = true)
            set_preferences!(Pkg.Types.UUID("6099a3de-0909-46bc-b1f4-468b9a2dfc0d"), "python" => "'$JULIA_PYTHONCALL_EXE'", force = true)
          '

          # Create a CLEAN _environment file for Quarto
          echo "PYTHONPATH=$PYTHONPATH" > _environment
          echo "R_HOME=$R_HOME" >> _environment
          echo "LIBR=$LIBR" >> _environment
          echo "JULIA_PYTHONCALL_EXE=$JULIA_PYTHONCALL_EXE" >> _environment
          echo "JULIA_CONDAPKG_BACKEND=Null" >> _environment

          # Create a YAML fragment with the Nix paths
          cat <<EOF > _metadata.yml
          julia:
              env:
                  - "PYTHONPATH=$PYTHONPATH"
                  - "JULIA_PYTHONCALL_EXE=$JULIA_PYTHONCALL_EXE"
                  - "JULIA_CONDAPKG_BACKEND=Null"
                  - "R_HOME=$R_HOME"
                  - "LIBR=$LIBR"
                  - "QT_QPA_PLATFORM=xcb"
                  - "QT_STYLE_OVERRIDE=Fusion"
          EOF
        '';
      };
    });
}
