
all: index.html awksupport.html bashsupport.html csupport.html gitsupport.html latexsupport.html luasupport.html perlsupport.html vimsupport.html

index.html: config.lua template_index.html
	./build_site.lua -p index

awksupport.html: config.lua template_plugin.html awksupport/content.html doc/awksupport.html
	./build_site.lua -p awk

bashsupport.html: config.lua template_plugin.html bashsupport/content.html doc/bashsupport.html
	./build_site.lua -p bash

csupport.html: config.lua template_plugin.html csupport/content.html doc/csupport.html
	./build_site.lua -p c

gitsupport.html: config.lua template_plugin.html gitsupport/content.html doc/gitsupport.html
	./build_site.lua -p git

latexsupport.html: config.lua template_plugin.html latexsupport/content.html doc/latexsupport.html
	./build_site.lua -p latex

luasupport.html: config.lua template_plugin.html luasupport/content.html doc/luasupport.html
	./build_site.lua -p lua

perlsupport.html: config.lua template_plugin.html perlsupport/content.html doc/perlsupport.html
	./build_site.lua -p perl

vimsupport.html: config.lua template_plugin.html vimsupport/content.html doc/vimsupport.html
	./build_site.lua -p vim

