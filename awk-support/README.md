README for awk-support.vim (Version 1.3) / July 24 2016
================================================================================

  *  INSTALLATION
  *  RELEASE NOTES
  *  FILES
  *  ADDITIONAL TIPS
  *  CREDITS

Awk Support implements an Awk-IDE for Vim/gVim. It is written to considerably
speed up writing code in a consistent style. This is done by inserting complete
statements, comments, idioms, and code snippets. Reading the Awk documentation
is integrated. There are many additional hints and options which can improve
speed and comfort when writing Awk. Please read the documentation.

This plug-in can be used with Vim version 7.x.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================

A system-wide installation for all users can also be done. This will have
further effects on how the plug-in works. For a step-by-step instruction, as
well as an explanation of the other consequences, please see the help file
`doc/awksupport.txt` or look up the documentation via:

      :help awksupport-system-wide


(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive `awk-support.zip` mirror the directory
structure which is needed below the local installation directory `$HOME/.vim/`
(find the value of `$HOME` with `:echo $HOME` from inside Vim).

(1.0) Save the template files in `$HOME/.vim/awk-support/templates/Templates`
   if you have changed any of them.

(1.1) Copy the zip archive `awk-support.zip` to `$HOME/.vim` and run

      unzip awk-support.zip

   Afterwards, these files should exist:

      $HOME/.vim/autoload/mmtemplates/...
      $HOME/.vim/doc/...
      $HOME/.vim/plugin/awk-support.vim

(1.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/.vimrc`. Create one if there
   is none or use the files in `$HOME/.vim/awk-support/rc` as a starting point.

(1.3) Set at least some personal details. Use the map `\ntw` inside a Awk buffer
   or the menu entry:

      Awk -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/.vim/templates/awk.templates` to customize or add to your
   Awk template library. It can also be set up via the wizard.

   (Read more about the template system in the plug-in documentation.)

(1.4) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME/.vim/doc/

(1.5) Consider additional settings in the file `$HOME/.vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or extensions
   for your `.vimrc` and `.gvimrc`. You may want to use parts of them. The files
   are documented.


(2) WINDOWS
----------------------------------------------------------------------

The subdirectories in the zip archive `awk-support.zip` mirror the directory
structure which is needed below the local installation directory
`$HOME/vimfiles/` (find the value of $HOME with `:echo $HOME` from inside Vim).

(2.0) Save the template files in `$HOME/vimfiles/awk-support/templates/Templates`
   if you have changed any of them.

(2.1) Copy the zip archive awk-support.zip to `$HOME/vimfiles` and run

      unzip awk-support.zip

   Afterwards, these files should exist:

      $HOME/vimfiles/autoload/mmtemplates/...
      $HOME/vimfiles/doc/...
      $HOME/vimfiles/plugin/awk-support.vim

(2.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/_vimrc`. Create one if there
   is none or use the files in `$HOME/vimfiles/awk-support/rc` as a starting point.

(2.3) Set at least some personal details. Use the map `\ntw` inside a Awk buffer
   or the menu entry:

      Awk -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/vimfiles/templates/awk.templates` to customize or add to
   your Awk template library. It can also be set up via the wizard.

   (Read more about the template system in the plug-in documentation.)

(2.4) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME\vimfiles\doc\

(2.5) Consider additional settings in the file `$HOME/_vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or extensions
   for your `_vimrc` and `_gvimrc`. You may want to use parts of them. The files
   are documented.


(3) ADDITIONAL REMARKS
----------------------------------------------------------------------

There are a lot of features and options which can be used and influenced:

  *  use of template files and macros
  *  using and managing personal code snippets
  *  using additional plug-ins

Look at the Awk Support help with:

      :help awksupport

               +-----------------------------------------------+
               | +-------------------------------------------+ |
               | |    ** PLEASE READ THE DOCUMENTATION **    | |
               | |    Actions differ for different modes!    | |
               | +-------------------------------------------+ |
               +-----------------------------------------------+

Any problems? See the TROUBLESHOOTING section at the end of the help file
`doc/awksupport.txt`.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================

RELEASE NOTES FOR VERSION 1.3
----------------------------------------------------------------------
- Add 'g:Awk_CustomTemplateFile'.
- Add template personalization file and setup wizard.
- Change the way lines of code are turned into comments
  (insert no space after the hash).
- Change the map for 'comment -> code' to '\co' for consistency with the other
  plug-ins. The old map '\cu' still works, however.
- Minor corrections and improvements.

RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file `awk-support/doc/ChangeLog`


--------------------------------------------------------------------------------

FILES
================================================================================

    README.md
                        This file.

    autoload/mmtemplates/*
                        The template system.

    doc/awksupport.txt
                        The help file for Awk Support.
    doc/templatesupport.txt
                        The help file for the template system.

    plugin/awk-support.vim
                        The Awk plugin for Vim/gVim.

    awk-support/codesnippets/*
                        Some Awk code snippets as a starting point.

    awk-support/scripts/*
                        Several helper scripts.

    awk-support/templates/Templates
                        Awk main template file.
    awk-support/templates/*.templates
                        Several dependent template files.

    awk-support/wordlists/awk-keywords.list
                        A file used as dictionary for automatic word completion.
                        This file is referenced in the file customization.vimrc.

___The following files and extensions are for convenience only.___
___awk-support.vim will work without them.___
___The settings are explained in the files themselves.___

    ftdetect/template.vim
    ftplugin/template.vim
    syntax/template.vim
                        Additional files for working with templates.

    awk-support/rc/customization.gvimrc
                        Additional settings for use in  .gvimrc:
                          hot keys, mouse settings, ...
                        The file is commented. Append it to your .gvimrc if you
                        like.
    awk-support/rc/customization.vimrc
                        Additional settings for use in  .vimrc:
                          incremental search, tabstop, hot keys,
                          font, use of dictionaries, ...
                        The file is commented. Append it to your .vimrc if you
                        like.

    awk-support/rc/*.templates
                        Sample template files for customization. Used by the
                        template setup wizard.

    awk-support/doc/awk-hotkeys.pdf
                        Reference card for the key mappings. The mappings can
                        also be used with the non-GUI Vim, where the menus are
                        not available.
    awk-support/doc/ChangeLog
                        The change log.


--------------------------------------------------------------------------------

ADDITIONAL TIPS
================================================================================

(1) gvim. Toggle 'insert mode' <--> 'normal mode' with the right mouse button
   (see mapping in file `customization.gvimrc`).

(2) gvim. Use tear off menus and

(3) try 'Focus under mouse' as window behavior (No mouse click when the mouse
   pointer is back from the menu entry).

(4) Use Emulate3Buttons "on" (X11) even for a 3-button mouse. Pressing left and
   right button simultaneously without moving your fingers is faster then moving
   a finger to the middle button (often a wheel).


--------------------------------------------------------------------------------

CREDITS
================================================================================

Fritz Mehner thanks:
----------------------------------------------------------------------

Wolfgang Mehner (wolfgang-mehner AT web.de) for the implementation of the
  powerful template system templatesupport.

Wolfgang Mehner thanks:
----------------------------------------------------------------------

This plug-in has been developed by Fritz Mehner, who maintained it until 2015.

