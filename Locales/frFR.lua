local ADDON_NAME, ns = ...
local locale = GetLocale()
if locale ~= "frFR" then return end

local L = ns.L

L["TITLE"] = "Volume général"
L["TOOLTIP_TITLE"] = "VuMaster"
L["TOOLTIP_VOL"] = "Volume : "
L["TOOLTIP_DESC"] = "Cliquez pour ajuster le volume général."
L["MUTE_ALL"] = "Rendre tout muet"
L["UNMUTE"] = "Rétablir le son"
L["PIN_SLIDER"] = "Épingler le curseur"
L["PIN_DESC"] = "Empêche la fermeture du curseur lors d'un clic à l'extérieur."
L["MORE_CONTROLS"] = "+ Plus d'options"
L["LESS_CONTROLS"] = "- Moins d'options"
L["ADDITIONAL_CONTROLS"] = "Options supplémentaires"
L["CHANNELS_DESC"] = "Musique, Effets sonores, Dialogue, Ambiance"
L["MUSIC"] = "Musique"
L["SFX"] = "Effets sonores"
L["DIALOG"] = "Dialogue"
L["AMBIENCE"] = "Ambiance"
L["RAID"] = "Raid"
L["WORLD"] = "Monde"
