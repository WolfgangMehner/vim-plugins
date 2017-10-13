README for git-support.vim (Version 0.9.4pre) / October 13 2017
================================================================================

  *  INSTALLATION
  *  RELEASE NOTES
  *  FILES
  *  CREDITS


Integration of Git for Vim/gVim. The plug-in at hand allows to use Git from
within Vim, eliminating the need for context switches. The output of commands
like "git status" is written into buffers, and the commit can be manipulated
from right there. Further commands allow to quickly add the file in the
current buffer or show its diff.
Please read the documentation.

This plug-in can be used with Vim version 7.x.


--------------------------------------------------------------------------------

INSTALLATION
================================================================================

(1) LINUX
----------------------------------------------------------------------

The subdirectories in the zip archive git-support.zip mirror the directory
structure which is needed below the local installation directory

      $HOME/.vim/

(find the value of $HOME with `:echo $HOME` from inside Vim).

(1.1) Copy the zip archive git-support.zip to $HOME/.vim and run

      unzip git-support.zip

(1.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file '$HOME/.vimrc'. Create one if there
   is none or use the file in $HOME/.vim/git-support/rc as a starting point.

(1.3) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME/.vim/doc/

(1.4) To get a syntax highlighting closer to the one Git uses, take a look at
   the suggestions in git-support/rc/additions.vimrc, which offers example
   settings for bright and dark backgrounds.

(1.5) Consider additional settings in the file '$HOME/.vimrc'. The files
   customization.vimrc and customization.gvimrc are replacements or extensions
   for your .vimrc and .gvimrc. You may want to use parts of them. The files
   are documented.

(2) WINDOWS
----------------------------------------------------------------------

The subdirectories in the zip archive git-support.zip mirror the directory
structure which is needed below the local installation directory

      $HOME/vimfiles/

(find the value of $HOME with `:echo $HOME` from inside Vim).

(2.1) Copy the zip archive git-support.zip to $HOME/vimfiles and run

      unzip git-support.zip

(2.2) Loading of plug-in files must be enabled. If not use

      :filetype plugin on

   This is the minimal content of the file '$HOME/_vimrc'. Create one if there
   is none or use the file in $HOME/vimfiles/git-support/rc as a starting point.

(2.3) Make the plug-in help accessible by typing the following command on the
   Vim command line:

      :helptags $HOME\vimfiles\doc\

(2.4) Set the correct executable. This is not necessary if 'git' is already on
   your path. See :help g:Git_Executable .

(2.5) To get a syntax highlighting closer to the one Git uses, take a look at
   the suggestions in git-support\rc\additions.vimrc, which offers example
   settings for bright and dark backgrounds.

(2.6) Consider additional settings in the file '$HOME/_vimrc'. The files
   customization.vimrc and customization.gvimrc are replacements or extensions
   for your _vimrc and _gvimrc. You may want to use parts of them. The files
   are documented.


(3) ADDITIONAL REMARKS
----------------------------------------------------------------------

There are a lot of features and options which can be used and influenced:

  *  the Git executable
  *  removing the Git menu
  *  the syntax highlighting
  *  the behavior of various commands

Look at the Git-Support help with:

      :help gitsupport

               +-----------------------------------------------+
               | +-------------------------------------------+ |
               | |    ** PLEASE READ THE DOCUMENTATION **    | |
               | +-------------------------------------------+ |
               +-----------------------------------------------+

Any problems? See the TROUBLESHOOTING section at the end of the help file
'doc/gitsupport.txt'.


--------------------------------------------------------------------------------

RELEASE NOTES
================================================================================

RELEASE NOTES FOR VERSION 0.9.4pre
----------------------------------------------------------------------
- Add command :GitTerm to execute Git in a terminal window (requires +terminal).
- Improve :GitGrep (in case +conceal is available).
- Adapt for running under Neovim more smoothly.
- Minor changes.


RELEASE NOTES FOR OLDER VERSIONS
----------------------------------------------------------------------
-> see file 'git-support/doc/ChangeLog'


--------------------------------------------------------------------------------

KNOWN ISSUES
================================================================================

* Windows: When entered on the Vim command line, commands containing filenames
  as parameters cause errors such as "... file not found ...".
  - This may happen if filenames contain special characters such as spaces. The
    Vim command line escapes those differently then Windows expects then to be
    escaped.
  - However, a filename containing spaces can always be escape using quotes:
      :GitAdd "help 1.txt"
  - If you already are in the corresponding buffer, simply use:
      :GitAdd


--------------------------------------------------------------------------------

FILES
================================================================================

    README.md
                        This file.

    doc/gitsupport.txt
                        The help file for Git Support.

    plugin/git-support.vim
                        The Git plug-in for Vim/gVim.

    syntax/gitsbranch.vim
    syntax/gitscommit.vim
    syntax/gitsdiff.vim
    syntax/gitslog.vim
    syntax/gitssshort.vim
    syntax/gitsstatus.vim
                        The syntax files used by Git Support. gitssshort.vim
                        is used for the output of "git status --short".
                        gitscommit.vim is used for commit messages.

___The following files and extensions are for convenience only.___
___git-support.vim will work without them.___
___The settings are explained in the files themselves.___

    git-support/doc/ChangeLog
                        Complete change log.

    git-support/rc/additions.gvimrc
                        Additional settings for use in .gvimrc:
                          hot keys, mouse settings, fonts, ...

    git-support/rc/additions.vimrc
                        Example settings for use in .vimrc:
                          setup of the plug-in, syntax highlighting

    git-support/rc/customization.gvimrc
                        Suggestion for the configuration file .gvimrc:
                          hot keys, mouse settings, fonts, ...

    git-support/rc/customization.vimrc
                        Suggestion for the configuration file .vimrc:
                          hot keys, tabstop, use of dictionaries,
                          the setup of the plug-in, ...


--------------------------------------------------------------------------------

CREDITS
================================================================================

For a complete list of people who made contributions to this plug-in,
please be so kind as to take a look at the credits:

      :help gitsupport-credits

