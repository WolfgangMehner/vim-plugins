
all: gitsupport.html luasupport.html

gitsupport.html: template_plugin.html gitsupport/content.html doc/gitsupport.html
	./build_site.lua -p git

luasupport.html: template_plugin.html luasupport/content.html doc/luasupport.html
	./build_site.lua -p lua

