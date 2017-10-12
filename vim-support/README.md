README for vim-support.vim (Version 2.5alpha) / October 12 2017
================================================================================

[INSTALLATION][sec_install]

[RELEASE NOTES][sec_release]

[FILES][sec_files]

[CREDITS][sec_credits]

VimScript Support implements a VimScript-IDE for Vim/gVim/Neovim. It has been
written to considerably speed up writing code in a consistent style. This is
done by inserting complete statements, comments, idioms, and code snippets.
There are many additional hints and options which can improve speed and comfort
when writing VimScript. Please read the documentation.

This plug-in can be used with Vim version 7.3+ and Neovim 0.2.1+.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================
  [sec_install]: #installation

A system-wide installation for all users can also be done. This will have
further effects on how the plug-in works. For a step-by-step instruction, as
well as an explanation of the other consequences, please see the help file
`doc/vimsupport.txt` or look up the documentation via:

      :help vimsupport-system-wide


(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive vim-support.zip mirror the directory
structure which is needed below the local installation directory `$HOME/.vim/`
(find the value of $HOME with `:echo $HOME` from inside Vim).

(1.0) Save the template files in `$HOME/.vim/vim-support/templates/` if you
   have changed any of them.

(1.1) Copy the zip archive vim-support.zip to $HOME/.vim and run

      unzip vim-support.zip

   Afterwards, these files should exist:

      $HOME/.vim/autoload/mmtemplates/...
      $HOME/.vim/doc/...
      $HOME/.vim/plugin/vim-support.vim

(1.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/.vimrc`. Create one if there
   is none or use the file in $HOME/.vim/vim-support/rc as a starting point.

(1.3) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME/.vim/doc/

(1.4) Set at least some personal details. Use the map \ntw inside a Vim buffer
   or the menu entry:

      Vim -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',       'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',    'WM' )
      SetMacro( 'EMAIL',        'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',    'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file $HOME/.vim/templates/vim.templates to customize or add to your
   Vim template library. It can also be set up via the wizard.

   (Read more about the template system in the plug-in documentation.)

(1.5) Consider additional settings in the file `$HOME/.vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or
   extensions for your `.vimrc` and `.gvimrc`. You may want to use parts of
   them. The files are documented.

   Some settings are specifically for VimScript buffers and should be placed in
   the filetype plug-in. You may copy the file `vim-support/rc/vim.vim` into the
   directory `$HOME/.vim/ftplugin/`, or use the settings there as additions to
   your own filetype plug-in.


(2) WINDOWS
----------------------------------------------------------------------

The subdirectories in the zip archive vim-support.zip mirror the directory
structure which is needed below the local installation directory `$HOME/vimfiles/`
(find the value of $HOME with `:echo $HOME` from inside Vim).

(2.0) Save the template files in `$HOME/vimfiles/vim-support/templates/` if you
   have changed any of them.

(2.1) Copy the zip archive vim-support.zip to $HOME/vimfiles and run

      unzip vim-support.zip

   Afterwards, these files should exist:

      $HOME/vimfiles/autoload/mmtemplates/...
      $HOME/vimfiles/doc/...
      $HOME/vimfiles/plugin/vim-support.vim

(2.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/_vimrc`. Create one if there
   is none or use the file in $HOME/vimfiles/vim-support/rc as a starting point.

(2.3) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME\vimfiles\doc\

(2.4) Set at least some personal details. Use the map \ntw inside a Vim buffer
   or the menu entry:

      Vim -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',       'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',    'WM' )
      SetMacro( 'EMAIL',        'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',    'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file $HOME/vimfiles/templates/vim.templates to customize or add to
   your Vim template library. It can also be set up via the wizard.

   (Read more about the template system in the plug-in documentation.)

(2.5) Consider additional settings in the file `$HOME/_vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or
   extensions for your `_vimrc` and `_gvimrc`. You may want to use parts of
   them. The files are documented.

   Some settings are specifically for VimScript buffers and should be placed in
   the filetype plug-in. You may copy the file `vim-support/rc/vim.vim` into the
   directory `$HOME/vimfiles/ftplugin/`, or use the settings there as additions
   to your own filetype plug-in.


(3) ADDITIONAL REMARKS
----------------------------------------------------------------------

There are a lot of features and options which can be used and influenced:

  *  use of the extendible template library
  *  using and managing personal code snippets
  *  using additional plugins

Actions differ for different modes. Please read the documentation:

      :help vimsupport

Any problems? See the TROUBLESHOOTING section at the end of the help file
`doc/vimsupport.txt`.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================
  [sec_release]: #release-notes

RELEASE NOTES FOR VERSION 2.5alpha
----------------------------------------------------------------------
- Add configuration variables `g:Vim_Ctrl_j` and `g:Vim_Ctrl_d` to control the
  creation of the `CTRL+J` and `CTRL+D` maps.
- Remove the definition of the map `SHIFT+F1`. Add it to your filetype plug-in
  if you want to use it.
- Minor changes.

Note: Copy the sample filetype plug-in from `vim-support/rc` to `ftplugin`, or
add the commands there to your own one.


RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file `vim-support/doc/ChangeLog`


--------------------------------------------------------------------------------

FILES
================================================================================
  [sec_files]: #files

    README.md
                        This file.

    autoload/mmtemplates/*
                        The template system.

    doc/vimsupport.txt
                        The help file for the Vim Support.
    doc/templatesupport.txt
                        The help file for the template system.

    plugin/vim-support.vim
                        The VimScript plugin for Vim/gVim.

    vim-support/templates/Templates
                        VimScript main template file.
    vim-support/templates/*.templates
                        Several dependent template files.

___The following files and extensions are for convenience only.___
___vim-support.vim will work without them.___
___The settings are explained in the files themselves.___

    ftdetect/template.vim
    ftplugin/template.vim
    syntax/template.vim
                        Additional files for working with templates.

    vim-support/codesnippets/*
                        Some VimScript code snippets as a starting point.

    vim-support/doc/vim-hotkeys.pdf
                        Reference card for the key mappings. The mappings can
                        be used with the non-GUI Vim, where the menus are not
                        available.
    vim-support/doc/ChangeLog
                        The change log.

    vim-support/rc/customization.gvimrc
                        Additional settings for use in .gvimrc:
                          hot keys, mouse settings, fonts, ...
                        The file is commented. Append it to your .gvimrc if you
                        like.
    vim-support/rc/customization.vimrc
                        Additional settings for use in .vimrc:
                          incremental search, tabstop, hot keys,
                          font, use of dictionaries, ...
                        The file is commented. Append it to your .vimrc if you
                        like.

    vim-support/rc/vim.vim
                        Example filetype plug-in for VimScript:
                          defines additional maps

    vim-support/rc/*.templates
                        Sample template files for customization. Used by the
                        template setup wizard.


--------------------------------------------------------------------------------

CREDITS
================================================================================
  [sec_credits]: #credits

This plug-in has been developed together with Fritz Mehner, who maintained it
until 2015.

