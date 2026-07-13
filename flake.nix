{
  description = "Flake for quarto development";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
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
          pip
        ]);

      rPkgNames = [
        "ggplot2"
        "gganimate"
        "gifski" # Dependency for animation
        "png" # Dependency
        "GGally"
        "dplyr"
        "tidyr"
        "broom"
        "kableExtra"
        "languageserver"
      ];

      rDeps = builtins.map (name: pkgs.rPackages.${name}) rPkgNames;

      rDepsNames = builtins.concatStringsSep ",\n    " (
        builtins.map (name: "${name} (>= ${pkgs.rPackages.${name}.version})") rPkgNames
      );

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
          collection-pictures
          collection-mathscience
          biber
          ;
      };
      patchedQuarto = pkgs.quarto.overrideAttrs (oldAttrs: {
        postPatch =
          (oldAttrs.postPatch or "")
          + ''
            substituteInPlace bin/quarto.js \
              --replace-fail "syntax-highlighting" "highlight-style"
          '';
      });

      # Extract the site-packages path directly in Nix
      pythonPath = "${pythonEnv}/${pkgs.python313.sitePackages}";
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            R
            jetbrains-mono
            patchedQuarto
            my-tex
            librsvg
            julia-bin
            pythonEnv
          ]
          ++ rDeps;

        # Export these so direnv picks them up automatically
        R_HOME = "${pkgs.R}/lib/R";
        LIBR = "${pkgs.R}/lib/R/lib/libR.so";
        PYTHONPATH = pythonPath;
        JULIA_PYTHONCALL_EXE = "${pythonEnv}/bin/python";
        JULIA_CONDAPKG_BACKEND = "Null";
        OSFONTDIR = "${pkgs.jetbrains-mono}/share/fonts";

        shellHook = ''
          # Update Julia Preferences automatically so RCall works properly
          luaotfload-tool --update --force

          julia --project=. -e '
            using Pkg, Preferences
            set_preferences!(Pkg.Types.UUID("6f49c342-dc21-5d91-9882-a32aef131414"), "Rhome" => "'$R_HOME'", "libR" => "'$LIBR'", force = true)
            set_preferences!(Pkg.Types.UUID("6099a3de-0909-46bc-b1f4-468b9a2dfc0d"), "python" => "'$JULIA_PYTHONCALL_EXE'", force = true)
          '

          pip freeze | grep -v "tkinter" > py_requirements.txt

          cat << EOF > DESCRIPTION
          Package: anotacoesInferencia
          Title: Inferência Clássica
          Version: 0.5.0
          Description: Pacote companheiro para o livro de Inferência Clássica
          License: GPL-3
          Encoding: UTF-8
          LazyData: true
          Imports:
              ${rDepsNames}
          EOF

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
                  - "OSFONTDIR=$OSFONTDIR"
          EOF
        '';
      };
    });
}
