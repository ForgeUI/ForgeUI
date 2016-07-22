# ForgeUI
ForgeUI is WildStar UI overhaul. It's completely modular, so you don't have to use everything. Only 'ForgeUI' addon is required.

## Main features
* simple use - ForgeUI is created in way that after installation you dont need to setup anything. But if you want customize something, just type /forgeui or press ESC - > ForgeUI and voilà all options in one place.
* unified design - Main purpose why ForgeUI was created is to get nice, unified UI.
* optimalization - ForgeUI requires about half of resources than stock UI.
* customization - Currently there is decent amount of customization, but that amount will be increasing in the future.

## Instalation
* curse.com
 * Download zip-file from here: http://mods.curse.com/ws-addons/wildstar/227047-forgeui
 * Unpack zip-file here: %appdata%\NCSOFT\WildStar\addons
* git
 * Use this PowerShell command:

    ````
    git clone --recursive https://github.com/ForgeUI/ForgeUI.git
    mkdir -Force ~\AppData\Roaming\NCSOFT\WildStar\addons\
    cp -Recurse -Force ForgeUI\* ~\AppData\Roaming\NCSOFT\WildStar\addons\
    ````

## Additional addons
* ActionBarsExt
 * Addon for creating new and 100% customizable ActionBars & ActionButtons
 * https://github.com/ForgeUI/ForgeUI_ActionBarsExt
