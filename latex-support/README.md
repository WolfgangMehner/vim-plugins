README for latex-support.vim (Version 1.3alpha) / October 15 2017
================================================================================

  *  INSTALLATION
  *  RELEASE NOTES
  *  FILES
  *  ADDITIONAL TIPS
  *  CREDITS

LaTeX Support implements an LaTeX-IDE for Vim/gVim. It has been written to
considerably speed up writing code in a consistent style. This is done by
inserting complete statements, comments, idioms, and code snippets. There are
many additional hints and options which can improve speed and comfort when
writing LaTeX.
See the help file latexsupport.txt for more information.

This plugin can be used with Vim version 7.x.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================

A system-wide installation for all users can also be done. This will have
further effects on how the plug-in works. For a step-by-step instruction, as
well as an explanation of the other consequences, please see the help file
'doc/latexsupport.txt' or look up the documentation via:

      :help latexsupport-system-wide


(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive latex-support.zip mirror the directory
structure which is needed below the local installation directory $HOME/.vim/
(find the value of $HOME with `:echo $HOME` from inside Vim).

(1.0) Save the template files in '$HOME/.vim/latex-support/templates/Templates' if
   you have changed any of them.

(1.1) Copy the zip archive latex-support.zip to $HOME/.vim and run

      unzip latex-support.zip

   Afterwards, these files should exist:

      $HOME/.vim/autoload/mmtemplates/...
      $HOME/.vim/doc/...
      $HOME/.vim/plugin/latex-support.vim

(1.2) Loading of plugin files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file '$HOME/.vimrc'. Create one if there
   is none or use the files in $HOME/.vim/latex-support/rc as a starting point.

(1.3) Set at least some personal details. Use the map \ntw inside a LaTeX buffer
   or the menu entry:

      LaTeX -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file $HOME/.vim/templates/latex.templates to customize or add to your
   LaTeX template library. It can also be set up via the wizard.

   (Read more about the template system in the plugin documentation)

(1.4) Make the plugin help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME/.vim/doc/

(1.5) Consider additional settings in the file '$HOME/.vimrc'. The files
   customization.vimrc and customization.gvimrc are replacements or extensions
   for your .vimrc and .gvimrc. You may want to use parts of them. The files
   are documented.


(2) WINDOWS
----------------------------------------------------------------------

The subdirectories in the zip archive latex-support.zip mirror the directory
structure which is needed below the local installation directory $HOME/vimfiles/
(find the value of $HOME with ":echo $HOME" from inside Vim).

(2.0) Save the template files in '$HOME/vimfiles/latex-support/templates/Templates' if
   you have changed any of them.

(2.1) Copy the zip archive latex-support.zip to $HOME/vimfiles and run

      unzip latex-support.zip

   Afterwards, these files should exist:

      $HOME/vimfiles/autoload/mmtemplates/...
      $HOME/vimfiles/doc/...
      $HOME/vimfiles/plugin/latex-support.vim

(2.2) Loading of plugin files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file '$HOME/_vimrc'. Create one if there
   is none or use the files in $HOME/vimfiles/latex-support/rc as a starting point.

(2.3) Set at least some personal details. Use the map \ntw inside a LaTeX buffer
   or the menu entry:

      LaTeX -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file $HOME/vimfiles/templates/latex.templates to customize or add to
   your LaTeX template library. It can also be set up via the wizard.

   (Read more about the template system in the plugin documentation)

(2.4) Make the plugin help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME\vimfiles\doc\

(2.5) Consider additional settings in the file '$HOME/_vimrc'. The files
   customization.vimrc and customization.gvimrc are replacements or extensions
   for your _vimrc and _gvimrc. You may want to use parts of them. The files
   are documented.


(3) ADDITIONAL REMARKS
----------------------------------------------------------------------

There are a lot of features and options which can be used and influenced:

  *  use of template files and macros
  *  using and managing personal code snippets
  *  using additional plugins

Look at the LaTeX-Support help with:

      :help latexsupport 

               +-----------------------------------------------+
               | +-------------------------------------------+ |
               | |    ** PLEASE READ THE DOCUMENTATION **    | |
               | |    Actions differ for different modes!    | |
               | +-------------------------------------------+ |
               +-----------------------------------------------+

Any problems? See the TROUBLESHOOTING section at the end of the help file
'doc/latexsupport.txt'.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================

RELEASE NOTES FOR VERSION 1.3alpha
----------------------------------------------------------------------
- Adapt for running under Neovim more smoothly.
- Add commands :Latex, :LatexCheck, :LatexMakeindex, and :LatexBibtex to run the
  external commands.
- Add command :LatexMakeglossaries to run `makeglossaries`.
- Add command :LatexView to start external viewers.
- Add command :LatexConvert to convert documents.
- Add command :LatexMainDoc to set the document for typesetting, viewing, ...
- Add command :LatexTypesetter to change the typesetter during runtime.
- Add command :LatexProcessing to change between foreground and background
  processing.
- Add command :LatexErrors and map ´re to view errors from background processing
  in quickfix.
- BibTeX errors are recognized by quickfix.
- Add a converter 'eps-pdf'.
- The templates which are inserted into new files as file skeletons can be
  specified in the templates library, via the property:
    `Latex::FileSkeleton::Script`
- Add configuration variables `g:Latex_Ctrl_j` and `g:Latex_Ctrl_d` to control
  the creation of the `CTRL+J` and `CTRL+D` maps.
- Improve templates. (Includes the removal of some templates!)
- Move the filetype plug-ins for tex and make to `latex-support/rc`.
- Remove the definition of the maps `CTRL+F9` and `ALT+F9`. Add them to your
  filetype plug-ins if you want to use them.
- Minor bugfixes.

Note: The filetype plug-ins have been moved, and are thus not loaded
automatically anymore. Copy them from `latex-support/rc` to `ftplugin`,
or add the commands there to your own filetype plug-ins.


RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file 'latex-support/doc/ChangeLog'


--------------------------------------------------------------------------------

FILES
================================================================================

    README.md
                        This file.

    autoload/mmtemplates/*
                        The template system.
    autoload/mmtoolbox/*
                        The toolbox (make, ...).

    doc/latexsupport.txt
                        The help file for LaTeX support. 
    doc/templatesupport.txt
                        The help file for the template system.
    doc/toolbox*.txt
                        The help files for the toolbox.

    plugin/latex-support.vim
                        The LaTeX plug-in for Vim/gVim.

    latex-support/codesnippets/*
                        Some LaTeX code snippets as a starting point.

    latex-support/templates/Templates
                        LaTeX main template file.
    latex-support/templates/*.templates
                        Several dependent template files.


___The following files and extensions are for convenience only.___
___latex-support.vim will work without them.___
___The settings are explained in the files themselves.___

    ftdetect/template.vim
    ftplugin/template.vim
    syntax/template.vim
                        Additional files for working with templates.

    latex-support/doc/latex-hotkeys.pdf 
                        Hotkey reference card.
    latex-support/doc/ChangeLog
                        The change log.

    latex-support/rc/customization.ctags
                        Additional settings for use in .ctags to enable
                        navigation in LaTeX documents with the plug-in
                        taglist.vim.
    latex-support/rc/customization.gvimrc
                        Additional settings for use in .gvimrc:
                          hot keys, mouse settings, fonts, ...
                        The file is commented. Append it to your .gvimrc if you
                        like.
    latex-support/rc/customization.vimrc
                        Additional settings for use in .vimrc:
                          incremental search, tabstop, hot keys,
                          font, use of dictionaries, ...
                        The file is commented. Append it to your .vimrc if you
                        like.

    latex-support/rc/make.vim
                        Define maps for make(1) in makefiles.
    latex-support/rc/tex.vim
                        Suggestion for a filetype plugin:
                          defines additional maps, expands keyword characters
                          for better support of labels

    latex-support/rc/*.templates
                        Sample template files for customization. Used by the
                        template setup wizard.


--------------------------------------------------------------------------------

CREDITS
================================================================================

Fritz Mehner thanks:
----------------------------------------------------------------------

Many thanks to Wolfgang Mehner (wolfgang-mehner at web.de) for is template
engine Template Support.

Wolfgang Mehner thanks:
----------------------------------------------------------------------

This plug-in has been developed by Fritz Mehner, who maintained it until 2015.

