fx_version 'adamant'
games { 'gta5' }

client_script 'client/main.lua'
server_script 'server/main.lua'
client_script "@mrp-infinity/client/cl_lib.lua"
server_script "@mrp-infinity/server/sv_lib.lua"

ui_page('client/html/index.html')

files {
    'client/html/index.html',
    'client/html/sounds/*.ogg',
}
