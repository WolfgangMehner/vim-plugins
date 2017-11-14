README for perl-support.vim (Version 5.5pre) / October 02 2017
================================================================================

  *  INSTALLATION
  *  RELEASE NOTES
  *  FILES
  *  ADDITIONAL TIPS
  *  CREDITS

Perl Support implements a Perl-IDE for Vim/gVim. It has been written to
considerably speed up writing code in a consistent style.  This is done by
inserting complete statements, comments, idioms, code snippets, templates, and
POD documentation.  Reading perldoc is integrated.  Syntax checking, running a
script, running perltidy,  running perlcritics, starting a debugger and a
profiler can be done with a keystroke.  There are many additional hints and
options which can improve speed and comfort when writing Perl. Please read the
documentation.

This plug-in can be used with Vim version 7.x.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================

A system-wide installation for all users can also be done. This will have
further effects on how the plug-in works. For a step-by-step instruction, as
well as an explanation of the other consequences, please see the help file
`doc/perlsupport.txt` or look up the documentation via:

      :help perlsupport-system-wide


(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive `perl-support.zip` mirror the directory
structure which is needed below the local installation directory `$HOME/.vim/`
(find the value of `$HOME` with `:echo $HOME` from inside Vim).

(1.0) Save the template files in `$HOME/.vim/perl-support/templates/Templates` if
    you have changed any of them.

(1.1) Copy the zip archive `perl-support.zip` to `$HOME/.vim` and run

      unzip perl-support.zip

   Afterwards, these files should exist:

      $HOME/.vim/autoload/mmtemplates/...
      $HOME/.vim/doc/...
      $HOME/.vim/plugin/perl-support.vim

(1.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/.vimrc`. Create one if there
   is none or use the files in `$HOME/.vim/perl-support/rc` as a starting point.

(1.3) Set at least some personal details. Use the map `\ntw` inside a Perl buffer
   or the menu entry:

      Perl -> Snippets -> template setup wizard

   It will help you set up the file `_runtimepath_/templates/personal.templates`.
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/.vim/templates/perl.templates` to customize or add to
   your Perl template library. It can also be set up via the wizard.

   (Read more about the template system in the plug-in documentation)

(1.4) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME/.vim/doc/

(1.5) Consider additional settings in the file `$HOME/.vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or
   extensions for your `.vimrc` and `.gvimrc`. You may want to use parts of
   them. The files are documented.


(2) WINDOWS
----------------------------------------------------------------------

The subdirectories in the zip archive `perl-support.zip` mirror the directory
structure which is needed below the local installation directory
`$HOME/vimfiles/` (find the value of `$HOME` with `:echo $HOME` from inside Vim).

(2.0) Save the template files in `$HOME/vimfiles/perl-support/templates/Templates`
   if you have changed any of them.

(2.1) Copy the zip archive `perl-support.zip` to `$HOME/vimfiles` and run

      unzip perl-support.zip

   Afterwards, these files should exist:

      $HOME/vimfiles/autoload/mmtemplates/...
      $HOME/vimfiles/doc/...
      $HOME/vimfiles/plugin/perl-support.vim

(2.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file `$HOME/_vimrc`. Create one if there
   is none or use the files in `$HOME/vimfiles/perl-support/rc` as a starting point.

(2.3) Set at least some personal details. Use the map `\ntw` inside a Perl buffer
   or the menu entry:

      Perl -> Snippets -> template setup wizard

   It will help you set up the file `_runtimepath_/templates/personal.templates`.
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file `$HOME/vimfiles/templates/perl.templates` to customize or add to
   your Perl template library. It can also be set up via the wizard.

   (Read more about the template system in the plug-in documentation)

(2.4) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME\vimfiles\doc\

(2.5) Consider additional settings in the file `$HOME/_vimrc`. The files
   `customization.vimrc` and `customization.gvimrc` are replacements or
   extensions for your `_vimrc` and `_gvimrc`. You may want to use parts of
   them. The files are documented.

(2.6) Make sure the shell is set up correctly. The options 'shell',
   'shellcmdflag', 'shellquote', and 'shellxquote' must be set consistently.
   Compare `:help perlsupport-troubleshooting`.


(3) ADDITIONAL REMARKS
----------------------------------------------------------------------

There are a lot of features and options which can be used and influenced:

  *  use of template files and tags
  *  using and managing personal code snippets
  *  Perl dictionary for keyword completion
  *  the Perl module list
  *  reading Perl documentation with integrated calls to perldoc
  *  removing the root menu
  *  using additional plug-ins

Look at the Perl Support help with:

      :help perlsupport

               +-----------------------------------------------+
               | +-------------------------------------------+ |
               | |    ** PLEASE READ THE DOCUMENTATION **    | |
               | |    Actions differ for different modes!    | |
               | +-------------------------------------------+ |
               +-----------------------------------------------+

Any problems? See the TROUBLESHOOTING section at the end of the help file
`doc/perlsupport.txt`.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================

RELEASE NOTES FOR VERSION 5.5pre
----------------------------------------------------------------------
- The templates which are inserted into new files as file skeletons can be
  specified in the templates library, via the properties:
    `Perl::FileSkeleton::Script`, `Perl::FileSkeleton::Module`,
    `Perl::FileSkeleton::Test`,   `Perl::FileSkeleton::POD`
- Add configuration variable `g:Perl_Ctrl_d` to control the creation
  of the `CTRL+D` map.
- Minor changes.

Note: The filetype plug-ins have been moved, and are thus not loaded
automatically anymore. Copy them from `perl-support/rc` to `ftplugin`,
or add the commands there to your own filetype plug-ins.
Note: Some configuration for `*.t` and `*.pod` files has been removed.
See `perl-support/rc/customization.vimrc` for how to add them to your
configuration files.


RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file `perl-support/doc/ChangeLog`


--------------------------------------------------------------------------------

FILES
================================================================================

    README.md
                        This file.

    autoload/perlsupportprofiling.vim
                        Profiler support.
    autoload/perlsupportregex.vim
                        Regex analyser code.
    autoload/mmtemplates/*
                        The template system.
    autoload/mmtoolbox/*
                        The toolbox (make, ...).

    doc/perlsupport.txt
                        The help file for perl support.
    doc/templatesupport.txt
                        The help file for the template system.
    doc/toolbox*.txt
                        The help files for the toolbox.

    plugin/perl-support.vim
                        The Perl plugin for Vim/gVim.

    perl-support/codesnippets/*
                        Some Perl code snippets as a starting point.

    perl-support/modules/
                        Directory for the list of installed Perl modules.

    perl-support/scripts/*
                        Several helper scripts.

    perl-support/templates/Templates
                        Perl main template file.
    perl-support/templates/*.templates
                        Several dependent template files.

    perl-support/wordlists/perl.list
                        A file used as dictionary for automatic word completion.
                        This file is referenced in the file customization.vimrc.

___The following files and extensions are for convenience only.___
___perl-support.vim will work without them.___
___The settings are explained in the files themselves.___

    ftdetect/template.vim
    ftplugin/template.vim
    syntax/template.vim
                        Additional files for working with templates.

    perl-support/rc/customization.ctags
                        Additional settings for use in .ctags to enable
                        navigation through POD with the plugin taglist.vim.
    perl-support/rc/customization.gvimrc
                        Additional settings for use in  .gvimrc:
                          hot keys, mouse settings, ...
                        The file is commented. Append it to your .gvimrc if you
                        like.
    perl-support/rc/customization.perltidyrc
                        Additional settings for use in .perltidyrc to customize
                        perltidy.
    perl-support/rc/customization.smallprof
                        Additional settings for use to control the profiler
                        Devel::SmallProf
    perl-support/rc/customization.vimrc
                        Additional settings for use in  .vimrc:
                          incremental search, tabstop, hot keys,
                          font, use of dictionaries, ...
                        The file is commented. Append it to your .vimrc if you
                        like.

    perl-support/rc/make.vim
                        Access hotkeys for make(1) in makefiles.
    perl-support/rc/perl.vim
    perl-support/rc/pod.vim
                        Example filetype plug-ins for Perl and POD:
                          defines additional maps,
                          set tabs according to Perl Style Guide
                          expands keyword characters for better support of tokens,
    perl-support/rc/qf.vim
                        Some maps to help with the profilers' output.

    perl-support/rc/*.templates
                        Sample template files for customization. Used by the
                        template setup wizard.

    perl-support/doc/perl-hot-keys.pdf
                        Reference card for the key mappings. The mappings can
                        also be used with the non-GUI Vim, where the menus are
                        not available.
    perl-support/doc/pmdesc3.text
                        The man page for pmdesc3.
    perl-support/doc/ChangeLog
                        The change log.


--------------------------------------------------------------------------------

ADDITIONAL TIPS
================================================================================

(1) You may want to use a central hidden directory for all your backup files
   (see also `rc/customization.vimrc`):

   1.1 Add the following line to `.vimrc` (see also rc/customization.vimrc ):

      set backupdir  =$HOME/.vim.backupdir

   1.2 Create `$HOME/.vim.backupdir`.

   1.3 Add the following line to your shell initialization file `~/.profile`:

      find $HOME/.vim.backupdir/  -name "*" -type f -mtime +60 -exec rm -f {} \;

   When you are logging in all files in the backup directory older then 60
   days (-mtime +60) will be removed (60 days is a suggestion, of course).
   Be shure to backup in shorter terms!

(2) gVim. Toggle 'insert mode' <--> 'normal mode' with the right mouse button
   (see mapping in file `customization.gvimrc`).

(3) gVim. Use tear off menus.

(4) Try 'Focus under mouse' as window behavior (No mouse click when the mouse
   pointer is back from the menu entry).

(5) Use Emulate3Buttons "on" (X11) even for a 3-button mouse. Pressing left and
   right button simultaneously without moving your fingers is faster than
   moving a finger to the middle button (which is often a wheel).


--------------------------------------------------------------------------------

CREDITS
================================================================================

Fritz Mehner thanks:
----------------------------------------------------------------------

Wolfgang Mehner (wolfgang-mehner AT web.de) for the implementation of the
  powerful template system templatesupport.

David Fishburn (fishburn AT ianywhere.com) for the implementation of the
  single root menu and several suggestions for improving the customization
  and the documentation.

Ryan Hennig (hennig AT amazon.com) improved the install script.

Aristotle, http://qs321.pair.com/~monkads/ is the author of the script pmdesc2
  which is the base of the included script pmdesc3.

David Fishburn contributed changes for the Windows platform and suggested to not
  let snippets and templates enter the list of alternate files.

The two files pod-template-application.pl and pod-template-module.pl are taken
  from Damian Conway's book "Perl Best Practices".

Wolfgang Mehner thanks:
----------------------------------------------------------------------

This plug-in has been developed by Fritz Mehner, who maintained it until 2015.

