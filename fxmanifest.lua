fx_version 'cerulean'
game 'gta5'
name 'triggerzone'
provides 'triggerzone'
description 'Fancy little zone entry/exit trigger script'
version '0.0.1'
lua54 'yes'
shared_scripts { 'config.lua', 'shared/*.lua' }
server_scripts { 'server/*.lua' }
client_scripts { 'client/*.lua' }
files { 'ui/*.html', 'ui/*.js', 'ui/*.css' }
ui_page 'ui/index.html'
