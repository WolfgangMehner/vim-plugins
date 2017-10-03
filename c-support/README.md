README for c.vim (Version 6.2.1pre) / February 05 2017
================================================================================

  *  INSTALLATION
  *  RELEASE NOTES
  *  FILES
  *  ADDITIONAL TIPS
  *  CREDITS

C/C++-IDE for Vim/gVim. It is written to considerably speed up writing code in
a consistent style. This is done by inserting complete statements, idioms,
comments, and code snippets. These code fragments are provided in an extendible
template library. Syntax checking, compiling, running a program, running indent
or code checkers can be done with a keystroke. There are many additional hints
and options which can improve speed and comfort when writing C/C++.
See the help file csupport.txt for more information.

This plugin can be used with Vim version 7.x.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================

A system-wide installation for all users can also be done. This will have
further effects on how the plug-in works. For a step-by-step instruction, as
well as an explanation of the other consequences, please see the help file
'doc/csupport.txt' or look up the documentation via:

      :help csupport-system-wide


(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive c-support.zip mirror the directory
structure which is needed below the local installation directory $HOME/.vim/
(find the value of $HOME with `:echo $HOME` from inside Vim).

(1.0) Save the template files in '$HOME/.vim/c-support/templates/Templates' if
   you have changed any of them.

(1.1) Copy the zip archive c-support.zip to $HOME/.vim and run

      unzip c-support.zip

   Afterwards, these files should exist:

      $HOME/.vim/autoload/mmtemplates/...
      $HOME/.vim/doc/...
      $HOME/.vim/plugin/c.vim

(1.2) Loading of plugin files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file '$HOME/.vimrc'. Create one if there
   is none or use the files in $HOME/.vim/c-support/rc as a starting point.

(1.3) Set at least some personal details. Use the map \ntw inside a C/C++ buffer
   or the menu entry:

      C/C++ -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file $HOME/.vim/templates/c.templates to customize or add to your
   C/C++ template library. It can also be set up via the wizard.

   (Read more about the template system in the plugin documentation)

(1.4) Make the plugin help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME/.vim/doc/

(1.5) Consider additional settings in the file '$HOME/.vimrc'. The files
   customization.vimrc and customization.gvimrc are replacements or extensions
   for your .vimrc and .gvimrc. You may want to use parts of them. The files
   are documented.

(1.6) To enable additional tools, add these lines to your '$HOME/.vimrc'. To
   enable the CMake and Doxygen tools, use:

      let g:C_UseTool_cmake    = 'yes'
      let g:C_UseTool_doxygen  = 'yes'

   For enabling the Doxygen templates, see chapter 1.10.1 of the documentation:

      :help csupport-doxygen-enable


(2) WINDOWS
----------------------------------------------------------------------

The subdirectories in the zip archive c-support.zip mirror the directory
structure which is needed below the local installation directory $HOME/vimfiles/
(find the value of $HOME with `:echo $HOME` from inside Vim).

(2.0) Save the template files in '$HOME/vimfiles/c-support/templates/Templates' if
   you have changed any of them.

(2.1) Copy the zip archive c-support.zip to $HOME/vimfiles and run

      unzip c-support.zip

   Afterwards, these files should exist:

      $HOME/vimfiles/autoload/mmtemplates/...
      $HOME/vimfiles/doc/...
      $HOME/vimfiles/plugin/c.vim

(2.2) Loading of plugin files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file '$HOME/_vimrc'. Create one if there
   is none or use the files in $HOME/vimfiles/c-support/rc as a starting point.

(2.3) Set at least some personal details. Use the map \ntw inside a C/C++ buffer
   or the menu entry:

      C/C++ -> Snippets -> template setup wizard

   It will help you set up the file _runtimepath_/templates/personal.templates .
   The file is read by all plug-ins supporting this feature to get your personal
   details. Here is the minimal personalization (my settings as an example):

      SetMacro( 'AUTHOR',      'Wolfgang Mehner' )
      SetMacro( 'AUTHORREF',   'wm' )
      SetMacro( 'EMAIL',       'wolfgang-mehner@web.de' )
      SetMacro( 'COPYRIGHT',   'Copyright (c) |YEAR|, |AUTHOR|' )

   Use the file $HOME/vimfiles/templates/c.templates to customize or add to
   your C/C++ template library. It can also be set up via the wizard.

   (Read more about the template system in the plugin documentation)

(2.4) Make the plugin help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME\vimfiles\doc\

(2.5) Consider additional settings in the file '$HOME/_vimrc'. The files
   customization.vimrc and customization.gvimrc are replacements or extensions
   for your _vimrc and _gvimrc. You may want to use parts of them. The files
   are documented.

(2.6) To enable additional tools, add these lines to your '$HOME/_vimrc'. To
   enable the CMake and Doxygen tools, use:

      let g:C_UseTool_cmake    = 'yes'
      let g:C_UseTool_doxygen  = 'yes'

   For enabling the Doxygen templates, see chapter 1.10.1 of the documentation:

      :help csupport-doxygen-enable

(2.7) Make sure the shell is set up correctly. The options 'shell',
   'shellcmdflag', 'shellquote', and 'shellxquote' must be set consistently.
   Compare `:help csupport-troubleshooting`.


(3) ADDITIONAL REMARKS
----------------------------------------------------------------------

There are a lot of features and options which can be used and influenced:

  *  use of the extendible template files and tags
  *  surround marked blocks with statements
  *  using and managing personal code snippets
  *  generate/remove multiline comments
  *  picking up prototypes
  *  C/C++ dictionaries for keyword completion
  *  (re)moving the root menu

Look at the C-Support help with:

      :help csupport

               +-----------------------------------------------+
               | +-------------------------------------------+ |
               | |    ** PLEASE READ THE DOCUMENTATION **    | |
               | |    Actions differ for different modes!    | |
               | +-------------------------------------------+ |
               +-----------------------------------------------+

Any problems? See the TROUBLESHOOTING section at the end of the help file
'doc/csupport.txt'.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================

RELEASE NOTES FOR VERSION 6.2.1
----------------------------------------------------------------------
- The templates which are inserted into new files as file skeletons can be
  specified in the templates library, via properties:
    C::FileSkeleton::Header, Cpp::FileSkeleton::Header,
    C::FileSkeleton::Source, Cpp::FileSkeleton::Source
- Fix a problem with the path when setting 'Run->executable to run'.
- New and reworked templates. Change statement templates.

Note: The filetype plug-ins have been moved, and are thus not loaded
automatically anymore. Copy them from 'c-support/rc' to 'ftplugin',
or add the commands there to your own filetype plug-ins.

Note: This reworks most of the statement templates. The loop and if templates
which do not introduce a block have been remove entirely, since the templates
without blocks save barely any typing. They do not make much sense in visual
mode either. Removing them allows us to clean up the menu and use more consistent
maps.


RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file 'c-support/doc/ChangeLog'


--------------------------------------------------------------------------------

FILES
================================================================================

    README.md
                        This file.

    autoload/mmtemplates/*
                        The template system.
    autoload/mmtoolbox/*
                        The toolbox (cmake, doxygen, make, ...).

    doc/csupport.txt
                        The help file for C support.
    doc/templatesupport.txt
                        The help file for the template system.
    doc/toolbox*.txt
                        The help files for the toolbox.

    plugin/c.vim
                        The C/C++ plug-in for Vim/gVim.

    c-support/codesnippets/*
                        Some C/C++ code snippets as a starting point.

    c-support/scripts/wrapper.sh
                        The wrapper script for the use of a xterm.

    c-support/templates/Templates
                        C and C++ main template file.
    c-support/templates/*.templates
                        Several dependent template files.

    c-support/wordlists/c-c++-keywords.list
                        All C and C++ keywords (also in word.list).
    c-support/wordlists/k+r.list
                        K&R-Book: Words from the table of content.
                        They appear frequently in comments.
    c-support/wordlists/stl_index.list
                        STL: method and type names.

___The following files and extensions are for convenience only.___
___c.vim will work without them.___
___The settings are explained in the files themselves.___

    ftdetect/template.vim
    ftplugin/template.vim
    syntax/template.vim
                        Additional files for working with templates.

    c-support/doc/c-hotkeys.pdf 
                        Hotkey reference card.
    c-support/doc/ChangeLog
                        Complete change log.

    c-support/rc/customization.ctags
                        Additional settings for use in .ctags to enable
                        navigation through makefiles and qmake files with the
                        plug-in taglist.vim.
    c-support/rc/customization.gvimrc
                        Additional settings for use in .gvimrc:
                          hot keys, mouse settings, fonts, ...
                        The file is commented. Append it to your .gvimrc if you
                        like.
    c-support/rc/customization.indent.pro
                        Additional settings for use in .indent.pro.
                        See the indent manual.
    c-support/rc/customization.vimrc
                        Additional settings for use in .vimrc:
                          incremental search, tabstop, hot keys,
                          font, use of dictionaries, ...
                        The file is commented. Append it to your .vimrc if you
                        like.

    c-support/rc/c.vim
    c-support/rc/cpp.vim
                        Example filetype plug-in for C/C++:
                          defines additional maps
    c-support/rc/make.vim
                        Access hotkeys for make(1) in makefiles.

    c-support/rc/*.templates
                        Sample template files for customization. Used by the
                        template setup wizard.

    c-support/rc/project/in.vim
                        Example for using the project plug-in's "in=" option
                        (see :help project-syntax) to set up the toolbox. For
                        example, a project's Makefile could be set up this way.


--------------------------------------------------------------------------------

CREDITS
================================================================================

Fritz Mehner thanks:
----------------------------------------------------------------------

Most of the people who have contributed ideas, patches, and bug reports, is
thanked in the file ChangeLog.

I would like to especially thank my son Wolfgang Mehner, who has repeatedly
proposed improvements and introduced new ideas.

Some ideas are taken from the following documents:

1. Recommended C Style and Coding Standards (Indian Hill Style Guide)
   ([read in html][1] or [read as pdf][2])
2. Programming in C++, Ellemtel Telecommunication Systems Laboratories
   ([read as pdf][3])
3. C++ Coding Standard, Todd Hoff
   ([read in html][4])

The splint error format is taken from the file splint.vim (Vim standard
distribution).

[1]: http://ieng9.ucsd.edu/~cs30x/indhill-cstyle.html
[2]: http://www.sourceformat.com/pdf/cpp-coding-standard-indianhill.pdf
[3]: http://www.literateprogramming.com/ellemtel.pdf
[4]: http://www.possibility.com/Cpp/CppCodingStandard.html

Wolfgang Mehner thanks:
----------------------------------------------------------------------

This plug-in has been developed by Fritz Mehner, who maintained it until 2015.


--------------------------------------------------------------------------------

  ... finally

Johann Wolfgang von Goethe (1749-1832), the greatest of the German poets,
about LINUX, Vim/gVim and other great tools (Ok, almost.) :

    Ein Mann, der recht zu wirken denkt,     Who on efficient work is bent,
    Muß auf das beste Werkzeug halten.       Must choose the fittest instrument.

_Faust, Teil 1, Vorspiel auf dem Theater_    _Faust, Part 1, Prologue for the Theatre_

