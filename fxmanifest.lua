fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Up-n-Atom Script'
author 'Hex'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
