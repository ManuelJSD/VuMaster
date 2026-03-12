local ADDON_NAME, ns = ...
local locale = GetLocale()
if locale ~= "itIT" then return end

local L = ns.L

L["TITLE"] = "Volume Principale"
L["TOOLTIP_TITLE"] = "VuMaster"
L["TOOLTIP_VOL"] = "Volume: "
L["TOOLTIP_DESC"] = "Clicca per regolare il volume principale."
L["MUTE_ALL"] = "Disattiva audio"
L["UNMUTE"] = "Riattiva audio"
L["PIN_SLIDER"] = "Fissa cursore"
L["PIN_DESC"] = "Impedisce la chiusura del cursore quando si clicca fuori."
L["MORE_CONTROLS"] = "+ Più controlli"
L["LESS_CONTROLS"] = "- Meno controlli"
L["ADDITIONAL_CONTROLS"] = "Controlli aggiuntivi"
L["CHANNELS_DESC"] = "Musica, Effetti Sonori, Dialoghi, Ambiente"
L["MUSIC"] = "Musica"
L["SFX"] = "Effetti Sonori"
L["DIALOG"] = "Dialoghi"
L["AMBIENCE"] = "Ambiente"
L["RAID"] = "Incursione"
L["WORLD"] = "Mondo"
