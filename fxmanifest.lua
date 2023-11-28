fx_version "cerulean"
game "gta5"

lua54 "yes"


client_scripts {
    "client.lua",
}

shared_script {
    "config.lua",
    '@ox_lib/init.lua',
    '@es_extended/imports.lua' -- Comment out if you are not using ESX
}

server_scripts {
    "server.lua",
    '@oxmysql/lib/MySQL.lua',
}
