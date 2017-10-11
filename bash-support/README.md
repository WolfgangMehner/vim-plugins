README for bash-support.vim (Version 5.0alpha) / October 10 2017
================================================================================

  *  INSTALLATION
  *  RELEASE NOTES
  *  FILES
  *  ADDITIONAL TIPS
  *  CREDITS

Bash Support implements a Bash-IDE for Vim/gVim. It is written to considerably
speed up writing code in a consistent style. This is done by inserting complete
statements, comments, idioms, and code snippets. Syntax checking, running a
script, starting a debugger can be done with a keystroke. There are many
additional hints and options which can improve speed and comfort when writing
shell scripts.

This plug-in can be used with Vim version 7.x.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================

A system-wide installation for all users can also be done. This will have
further effects on how the plug-in works. For a step-by-step instruction, as
well as an explanation of the other consequences, please see the help file
`doc/bashsupport.txt` or look up the documentation via:

      :help bashsupport-system-wide


(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive `bash-support.zip` mirror the directory
structure which is needed below the local installation directory `$HOME/.vim/`
(find the value of `$HOME` with `:echo $HOME` from inside Vim).

(1.0) Save the template files in `$HOME/.vim/bash-support/templates/Templates`
   if you have changed any of them.

(1.1) Copy the zip archive `bash-support.zip` to `$HOME/.vim` and run

      unzip bash-support.zip

   Afterwards, these files should exist:

      $HOME/.vim/autoload/mmtemplates/...
      $HOME/.vim/doc/...
      $HOME/.vim/plugin/bash-support.vim

(1.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/.vimrc`. Create one if there
   is none or use the files in `$HOME/.vim/bash-support/rc` as a starting point.

(1.3) Set at least some personal details. Use the map `\ntw` inside a Bash buffer
   or the menu entry:

      Bash -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/.vim/templates/bash.templates` to customize or add to your
   Bash template library. It can also be set up via the wizard.

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

The subdirectories in the zip archive `bash-support.zip` mirror the directory
structure which is needed below the local installation directory
`$HOME/vimfiles/` (find the value of $HOME with `:echo $HOME` from inside Vim).

(2.0) Save the template files in `$HOME/vimfiles/bash-support/templates/Templates`
   if you have changed any of them.

(2.1) Copy the zip archive bash-support.zip to `$HOME/vimfiles` and run

      unzip bash-support.zip

   Afterwards, these files should exist:

      $HOME/vimfiles/autoload/mmtemplates/...
      $HOME/vimfiles/doc/...
      $HOME/vimfiles/plugin/bash-support.vim

(2.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/_vimrc`. Create one if there
   is none or use the files in `$HOME/vimfiles/bash-support/rc` as a starting point.

(2.3) Set at least some personal details. Use the map `\ntw` inside a Bash buffer
   or the menu entry:

      Bash -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/vimfiles/templates/bash.templates` to customize or add to
   your Bash template library. It can also be set up via the wizard.

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
  *  bash dictionary for keyword completion
  *  removing the root menu
  *  using additional plug-ins

Actions differ for different modes. Please read the documentation:

      :help bashsupport

Any problems? See the TROUBLESHOOTING section at the end of the help file
`doc/bashsupport.txt`.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================

RELEASE NOTES FOR VERSION 5.0alpha
----------------------------------------------------------------------
- Adapt for running under Neovim more smoothly.
- Add command `:Bash [<args>]` to run the interpreter with arguments.
- Add command `:BashDirectRun` to run executable scripts without `g:BASH_Executable`.
- Add command `:BashOutputMethod` to set the output destination for `:Bash`.
- Add command `:BashExecutable` to set the executable during runtime.
- Add output method 'terminal' for running scripts in a terminal window
  (requires +terminal).
- The templates which are inserted into new files as file skeletons can be
  specified in the templates library, via the property:
    `Bash::FileSkeleton::Script`
- Use `g:Xterm_Executable`.
- Use `g:Xterm_Options` instead of `g:BASH_XtermDefaults`. The setting
  `g:BASH_XtermDefaults` still works for backwards compatibility.
- Add configuration variables `g:BASH_Ctrl_j` and `g:BASH_Ctrl_d` to control the
  creation of the `CTRL+J` and `CTRL+D` maps.
- Remove the definition of the maps `CTRL+F9`, `SHIFT+F9`, and `ALT+F9`.
  Add them to your filetype plug-in if you want to use them.
- Integration of BashDB moved into the toolbox.
- Add shell options and variables for BASH Version 4.4.
- Minor corrections and improvements.

Note: The filetype plug-in has been moved, and is thus not loaded automatically
anymore. Copy it from `bash-support/rc` to `ftplugin`, or add the commands there
to your own filetype plug-in.


RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file `bash-support/doc/ChangeLog`


--------------------------------------------------------------------------------

FILES
================================================================================

    README.md
                        This file.

    autoload/mmtemplates/*
                        The template system.

    doc/bashsupport.txt
                        The help file for Bash Support.
    doc/templatesupport.txt
                        The help file for the template system.

    plugin/bash-support.vim
                        The Bash plugin for Vim/gVim.

    bash-support/codesnippets/*
                        Some Bash code snippets as a starting point.

    bash-support/scripts/*
                        Several helper scripts.

    bash-support/templates/Templates
                        Bash main template file.
    bash-support/templates/*.templates
                        Several dependent template files.

    bash-support/wordlists/bash-keywords.list
                        A file used as dictionary for automatic word completion.
                        This file is referenced in the file customization.vimrc.

___The following files and extensions are for convenience only.___
___bash-support.vim will work without them.___
___The settings are explained in the files themselves.___

    ftdetect/template.vim
    ftplugin/template.vim
    syntax/template.vim
                        Additional files for working with templates.

    bash-support/doc/bash-hotkeys.pdf
                        Reference card for the key mappings. The mappings can
                        also be used with the non-GUI Vim, where the menus are
                        not available.
    bash-support/doc/ChangeLog
                        The change log.

    bash-support/rc/customization.bashrc
                        Additional settings for use in .bashrc:
                          set the prompt P2, P3, P4 (for debugging)
    bash-support/rc/customization.gvimrc
                        Additional settings for use in .gvimrc:
                          hot keys, mouse settings, ...
                        The file is commented. Append it to your .gvimrc if you
                        like.
    bash-support/rc/customization.vimrc
                        Additional settings for use in  .vimrc:
                          incremental search, tabstop, hot keys,
                          font, use of dictionaries, ...
                        The file is commented. Append it to your .vimrc if you
                        like.

    bash-support/rc/sh.vim
                        Example filetype plug-ins for Bash:
                          defines additional maps

    bash-support/rc/*.templates
                        Sample template files for customization. Used by the
                        template setup wizard.


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

