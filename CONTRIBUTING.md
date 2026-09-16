# Como contribuir

Contribuições de conteúdo, correções e melhorias de infraestrutura são
bem-vindas. Antes de começar uma alteração grande, abra uma issue para alinhar
o escopo.

## Preparação

1. Entre no ambiente com `nix develop` ou habilite o direnv com `direnv allow`.
2. Instancie as dependências Julia:

   ```bash
   julia --threads auto --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.build("RCall")'
   ```

3. Use `quarto preview --to html` durante a edição.

## Convenções editoriais

- Mantenha os capítulos `.qmd` na raiz e registre sua ordem em `_quarto.yml`.
- Use nomes de arquivo descritivos, em minúsculas e separados por hífen.
- Use identificadores semânticos com os prefixos do Quarto, como `sec-`,
  `fig-`, `tbl-` e `eq-`, e referências no formato `@sec-identificador`.
- Coloque imagens editoriais em `assets/images/`, referências bibliográficas em
  `bibliography/` e estilos em `styles/`.
- Adicione dependências Julia a `Project.toml` e `Manifest.toml`. Dependências
  de R e Python são definidas pelo ambiente em `flake.nix`.
- Não inclua `_book/`, `.quarto/`, `*_files/`, caches ou arquivos auxiliares do
  LaTeX no commit.

Renomear um capítulo também altera sua URL publicada. Quando isso for realmente
necessário, atualize todas as referências internas e planeje um redirecionamento
para o endereço anterior.

## Verificação

Antes de abrir um pull request, gere pelo menos o HTML:

```bash
quarto render --to html
```

Para mudanças em LaTeX, figuras ou configuração global, execute também o render
completo:

```bash
quarto render
```

Confira `git status` para garantir que nenhum resultado gerado foi incluído. O
workflow de pull requests repete o render completo no ambiente Nix.
