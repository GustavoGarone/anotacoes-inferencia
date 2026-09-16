# Anotações de Inferência Frequentista

Este repositório contém as fontes do livro *Anotações de Inferência
Frequentista*, elaborado a partir das disciplinas de inferência frequentista da
graduação em Estatística do IME-USP.

A versão publicada está disponível em
[stats.garone.me/inferencia-classica](https://stats.garone.me/inferencia-classica/).

## Ambiente de desenvolvimento

O ambiente reproduzível do projeto é definido por Nix e inclui Quarto, Julia,
R, Python e LaTeX. É necessário ter o [Nix](https://nixos.org/download/), com
suporte a flakes, instalado.

Entre no ambiente com:

```bash
nix develop
```

Quem usa [direnv](https://direnv.net/) pode executar `direnv allow` uma vez; a
partir daí, o ambiente será ativado ao entrar no diretório.

Na primeira execução, instancie as dependências Julia e configure o RCall:

```bash
julia --threads auto --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.build("RCall")'
```

## Visualização e compilação

Para visualizar apenas a versão HTML durante a edição:

```bash
quarto preview --to html
```

Para gerar todos os formatos configurados:

```bash
quarto render
```

Os resultados são gravados em `_book/`. Esse diretório e os demais artefatos
de renderização não fazem parte do controle de versão.

## Organização do repositório

- Os capítulos `.qmd` ficam na raiz para preservar os endereços publicados e
  simplificar as referências entre capítulos.
- `assets/images/` contém imagens editoriais, como capa e favicon.
- `bibliography/` contém a base BibTeX e o estilo CSL.
- `styles/` contém os estilos dos formatos HTML claro e escuro.
- `_extensions/` contém extensões Quarto usadas pelo livro.
- `Project.toml`, `Manifest.toml`, `flake.nix` e `flake.lock` fixam o ambiente
  computacional.
- `.github/workflows/` verifica pull requests e publica mudanças de `main`.

## Contribuições

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) antes de enviar alterações. Dúvidas
e sugestões podem ser abertas como issue ou pull request no GitHub. Também é
possível entrar em contato por `gustavo.garone@usp.br` ou `contact@garone.me`.

## Licença

O conteúdo está disponível sob os termos descritos em [LICENSE](LICENSE).
