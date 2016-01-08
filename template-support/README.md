README for template-support.vim (Version 1.0) / January 08 2016
================================================================================

With this plug-in, you can configure a template library for arbitrary filetypes.

For writing your own template files, see the documentation of the template
engine:

    :help template-support

Also have a look at the template libraries of the other plug-ins for
inspiration, if you like.

Add Template Files
----------------------------------------------------------------------

Add a template file for a certain filetype in your `.vimrc`, e.g.:

    call mmtemplates#config#Add ( 'html', $HOME.'/somepath/html-templates/Templates', 'local', 'ntl' )

The arguments are as follows:

1. filetype: Has to be the name Vim uses for the filetype.
2. template file: The template file to load for the filetype.
3. name (_optional_): The symbolic name of the template file.
4. map (_optional_): The map which will be created for editing this template
   file. Will be preceded by the mapleader, the map will be `\ntl` in this
   example.

Mapleader
----------------------------------------------------------------------

The mapleader used for the created maps can also be set in the `.vimrc`, e.g.:

    let g:Templates_MapLeader = '#'

Commenting
----------------------------------------------------------------------

Maps for turning code into comment and vice versa can also be created for the
corresponding filetype. The maps will be `\cc` and `\co`, but using the chosen
mapleader.

To configure them, the template files have to contain the following settings.
E.g., for HTML:

    SetProperty ( 'Comments::LinePrefix',  '<!--' )
    SetProperty ( 'Comments::LinePostfix', '-->' )

Lines which are turned into comments will be prefixed with `<!--` and postfixed
with `-->`.

Or, for config files (filetype `conf`):

    SetProperty ( 'Comments::LinePrefix', '#' )

The property `Comments::LinePostfix` does not have to be set.

Included Template Libraries
----------------------------------------------------------------------

Templates for writing template files are already included. Find out the path
where the plug-in is installed (`<PATH_TO_PLUG>/plugin/template-support.vim`)
and add this line to the `.vimrc`:

    call mmtemplates#config#Add ( 'template', '<PATH_TO_PLUG>/template-support/templates/Templates', 'local', 'ntl' )

