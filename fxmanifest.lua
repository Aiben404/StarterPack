fx_version 'cerulean'

game 'gta5'

author 'Snowamn'

description 'Advanced Starter Pack System for ESX'

version '1.0.0'

shared_scripts {
    'public/lib.js',
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'oxmysql'
}