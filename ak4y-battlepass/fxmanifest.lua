shared_scripts { '@FiniAC/fini_events.js', '@FiniAC/fini_events.lua' }



fx_version 'cerulean'
game 'gta5'

shared_script {
	"config.lua",
	'@es_extended/imports.lua',
	'@es_extended/locale.lua',
}

client_scripts {
	'example.lua',
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	-- '@mysql-async/lib/MySQL.lua',
	'server/server_config.lua',
	'server/main.lua',
	'server/admin_commands.lua',
}

ui_page {
	'html/ui.html'
}

files {
	'html/ui.html',
	'html/font/*.ttf',
	'html/font/*.otf',
	'html/css/*.css',
	'html/images/*.jpg',
	'html/images/*.png',
	'html/images/prestige1.png',
	'html/images/prestige2.png',
	'html/images/prestige3.png',
	'html/images/prestige4.png',
	'html/images/prestige5.png',
	'html/images/prestige6.png',
	'html/js/*.js',
}

escrow_ignore {
	'client/main.lua',
	'server/main.lua',
	'config.lua',
	'example.lua',
	'server/admin_commands.lua',
	'server/server_config.lua',
}  

dependencies {
    'es_extended',
}


lua54 'on'
dependency '/assetpacks'
dependency '/assetpacks'