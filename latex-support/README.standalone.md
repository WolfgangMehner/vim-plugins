Preface
================================================================================

This repository is mainly for the use with plug-in managers.

Have a look at the [Screenshot Page](https://wolfgangmehner.github.io/vim-plugins/latexsupport.html).

The development happens in [WolfgangMehner/vim-plugins](https://github.com/WolfgangMehner/vim-plugins).


Preview Version
================================================================================

___This is a preview version!___

Notable new features:

- Call external tools via the command-line: `:Latex`, `:LatexCheck`,
  `:LatexMakeindex`, `:LatexBibtex`, `:LatexView`.
- Change the typesetter during runtime using `:LatexTypesetter`.
- Background processing, enable via `:LatexProcessing`.
- View errors from background processing in quickfix using `:LatexErrors`.
- Add maps for BibTeX buffers. The maps for the Comment, Text, and BibTeX
  templates now are available when editing BibTeX.

The background processing relies on the new `+job` feature, which becomes
available with a patch level of approx. `7.4.2000`.

_Please read the release notes below._


--------------------------------------------------------------------------------

