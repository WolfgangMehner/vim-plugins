README for lua-support.vim (Version 1.1alpha) / October 13 2017
================================================================================

  *  INSTALLATION
  *  RELEASE NOTES
  *  FILES
  *  ADDITIONAL TIPS
  *  CREDITS


Lua-IDE for Vim/gVim/Neovim. It is written to considerably speed up writing code
in a consistent style. This is done by inserting complete statements, idioms and
comments. These code fragments are provided in an extendible template library.
This plug-in helps with running and compiling Lua scripts, applying the code
checker, and provides quick access to the online documentation of the Lua
functions.
Please read the documentation.

This plug-in can be used with Vim version 7.3+ and Neovim 0.2.1+.

Lua is: Copyright 1994-2016 Lua.org, PUC-Rio.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================

A system-wide installation for all users can also be done. This will have
further effects on how the plug-in works. For a step-by-step instruction, as
well as an explanation of the other consequences, please see the help file
`doc/luasupport.txt` or look up the documentation via:

      :help luasupport-system-wide


(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive lua-support.zip mirror the directory
structure which is needed below the local installation directory `$HOME/.vim/`
(find the value of `$HOME` with `:echo $HOME` from inside Vim).

(1.0) Save the template files in `$HOME/.vim/lua-support/templates/` if you
   have changed any of them.

(1.1) Copy the zip archive `lua-support.zip` to `$HOME/.vim` and run

      unzip lua-support.zip

   Afterwards, these files should exist:

      $HOME/.vim/autoload/mmtemplates/...
      $HOME/.vim/doc/...
      $HOME/.vim/plugin/lua-support.vim

(1.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/.vimrc`. Create one if there
   is none or use the file in `$HOME/.vim/lua-support/rc` as a starting point.

(1.3) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME/.vim/doc/

(1.4) Set at least some personal details. Use the map \ntw inside a Lua buffer
   or the menu entry:

      Lua -> Snippets -> template setup wizard

   It will help you set up the file `_runtimepath_/templates/personal.templates`.
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',       'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',    'WM' )
      SetMacro( 'EMAIL',        'wolfgang-mehner@web.de' )
      SetMacro( 'ORGANIZATION', '' )
      SetMacro( 'COPYRIGHT',    'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/.vim/templates/lua.templates` to customize or add to your
   Lua template library. It can also be set up via the wizard.

   This plug-in ships with templates for Lua's C-API. If you want to use them,
   please consult the help file `:help luasupport-usage-capi`.

   (Read more about the template system in the plug-in documentation.)

(1.5) Consider additional settings in the file `$HOME/.vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or
   extensions for your `.vimrc` and `.gvimrc`. You may want to use parts of
   them. The files are documented.

   Some settings are specifically for Lua buffers and should be placed in the
   filetype plug-in. You may copy the file `lua-support/rc/lua.vim` into the
   directory `$HOME/.vim/ftplugin/`, or use the settings there as additions to
   your own filetype plug-in.


(2) WINDOWS
----------------------------------------------------------------------

The subdirectories in the zip archive lua-support.zip mirror the directory
structure which is needed below the local installation directory `$HOME/vimfiles/`
(find the value of `$HOME` with `:echo $HOME` from inside Vim).

(2.0) Save the template files in `$HOME/vimfiles/lua-support/templates/` if you
   have changed any of them.

(2.1) Copy the zip archive `lua-support.zip` to `$HOME/vimfiles` and run

      unzip lua-support.zip

   Afterwards, these files should exist:

      $HOME/vimfiles/autoload/mmtemplates/...
      $HOME/vimfiles/doc/...
      $HOME/vimfiles/plugin/lua-support.vim

(2.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/_vimrc`. Create one if there
   is none or use the file in `$HOME/vimfiles/lua-support/rc` as a starting point.

(2.3) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME\vimfiles\doc\

(2.4) Set at least some personal details. Use the map \ntw inside a Lua buffer
   or the menu entry:

      Lua -> Snippets -> template setup wizard

   It will help you set up the file `_runtimepath_/templates/personal.templates`.
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',       'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',    'WM' )
      SetMacro( 'EMAIL',        'wolfgang-mehner@web.de' )
      SetMacro( 'ORGANIZATION', '' )
      SetMacro( 'COPYRIGHT',    'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/vimfiles/templates/lua.templates` to customize or add to
   your Lua template library. It can also be set up via the wizard.

   This plug-in ships with templates for Lua's C-API. If you want to use them,
   please consult the help file `:help luasupport-usage-capi`.

   (Read more about the template system in the plug-in documentation.)

(2.5) Consider additional settings in the file `$HOME/_vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or
   extensions for your `_vimrc` and `_gvimrc`. You may want to use parts of
   them. The files are documented.

   Some settings are specifically for Lua buffers and should be placed in the
   filetype plug-in. You may copy the file `lua-support/rc/lua.vim` into the
   directory `$HOME/vimfiles/ftplugin/`, or use the settings there as additions
   to your own filetype plug-in.

(2.6) Make sure the shell is set up correctly. The options `shell`,
   `shellcmdflag`, `shellquote`, and `shellxquote` must be set consistently.
   Compare `:help luasupport-troubleshooting`.


(3) ADDITIONAL REMARKS
----------------------------------------------------------------------

There are a lot of features and options which can be used and influenced:

  *  use of the extendible template library
  *  automated generation of comments for functions
  *  use of the Lua interpreter, compiler and code checker
  *  quick access to the online documentation
  *  removing the Lua menu

Actions differ for different modes. Please read the documentation:

      :help luasupport

Any problems? See the TROUBLESHOOTING section at the end of the help file
`doc/luasupport.txt`.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================

RELEASE NOTES FOR VERSION 1.1alpha
----------------------------------------------------------------------
- Adapt for running under Neovim more smoothly.
- Add output method 'terminal' for running scripts in a terminal window
  (requires +terminal).
- Rename output methods 'vim-io' to 'cmd-line', and 'vim-qf' to 'quickfix',
  for more consistency (old settings will still work).
- The templates which are inserted into new files as file skeletons can be
  specified in the templates library, via the property:
    `Lua::FileSkeleton::Script`
- Add configuration variables `g:Lua_Ctrl_j` and `g:Lua_Ctrl_d` to control the
  creation of the `CTRL+J` and `CTRL+D` maps.
- Update Lua's reference manual to 5.3.4.
- Move the filetype plug-in for lua to `lua-support/rc`.
- Minor changes and bugfixes.

Note: The filetype plug-in has been moved, and is thus not loaded automatically
anymore. Copy it from `lua-support/rc/` to `ftplugin`, or add the commands there
to your own filetype plug-in.


RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file `lua-support/doc/ChangeLog`


--------------------------------------------------------------------------------

FILES
================================================================================

    README.md
                        This file.

    autoload/mmtemplates/*
                        The template system.
    autoload/mmtoolbox/*
                        The toolbox (make, ...).

    doc/luasupport.txt
                        The help file for Lua support.
    doc/templatesupport.txt
                        The help file for the template system.
    doc/toolbox*.txt
                        The help files for the toolbox.

    plugin/lua-support.vim
                        The Lua plug-in for Vim/gVim.

    lua-support/templates/Templates
                        Lua main template file.
    lua-support/templates/*.templates
                        Several dependent template files.

___The following files and extensions are for convenience only.___
___lua-support.vim will work without them.___
___The settings are explained in the files themselves.___

    ftdetect/template.vim
    ftplugin/template.vim
    syntax/template.vim
                        Additional files for working with templates.

    lua-support/codesnippets/*
                        Some Lua code snippets as a starting point.

    lua-support/doc/ChangeLog
                        Complete change log.

    lua-support/rc/additions.gvimrc
                        Additional settings for use in .gvimrc:
                          hot keys, mouse settings, fonts, ...
    lua-support/rc/additions.vimrc
                        Example settings for use in .vimrc:
                          setup of the plug-in

    lua-support/rc/customization.gvimrc
                        Suggestion for the configuration file .gvimrc:
                          hot keys, mouse settings, fonts, ...
    lua-support/rc/customization.vimrc
                        Suggestion for the configuration file .vimrc:
                          hot keys, tabstop, use of dictionaries,
                          the setup of the plug-in, ...

    lua-support/rc/lua.vim
                        Example filetype plug-in for Lua:
                          defines additional maps

    lua-support/rc/*.templates
                        Sample template files for customization. Used by the
                        template setup wizard.


--------------------------------------------------------------------------------

ADDITIONAL TIPS
================================================================================

(1) You may want to use a central hidden directory for all your backup files:

   1.1 Add the following line to .vimrc:

      set backupdir=$HOME/.vim.backupdir

   1.2 Create  $HOME/.vim.backupdir  .

   1.3 Add the following line to your shell initialization file  ~/.profile :

      find $HOME/.vim.backupdir/  -name "*" -type f -mtime +60 -exec rm -f {} \;

   When you are logging in all files in the backup directory older then 60
   days (-mtime +60) will be removed (60 days is a suggestion, of course).
   Be sure to backup in shorter terms !

(2) gVim. Toggle 'insert mode' <--> 'normal mode' with the right mouse button
   (see mapping in file customization.gvimrc).

(3) gVim. Use tear off menus.

(4) Try 'Focus under mouse' as window behavior (No mouse click when the mouse
   pointer is back from the menu entry).

(5) Use Emulate3Buttons "on" (X11) even for a 3-button mouse. Pressing left and
   right button simultaneously without moving your fingers is faster than
   moving a finger to the middle button (which is often a wheel).


--------------------------------------------------------------------------------

CREDITS
================================================================================

* Fritz Mehner (vim.org user name: mehner) for a number of things:
  - his plug-ins (bash-support, c-support, perl-support, ...) provided the
    inspiration and model for this plug-in and the utilized template support
  - parts of the documentation and other material (including the 'ADDITIONAL TIPS'
    above) are taken from his plug-ins as well

* Luis Carvalho (Kozure):
  - the idea for suppling Lua's reference manual in Vim's help format is taken
    from his plug-in "luarefvim", which contains previous versions of the
    reference manual
    ( http://vim.sourceforge.net/scripts/script.php?script_id=1291 )


For a complete list of people who made contributions to this plug-in,
please be so kind as to take a look at the credits:

      :help luasupport-credits

