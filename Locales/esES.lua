local ADDON_NAME, ns = ...
local locale = GetLocale()
if locale ~= "esES" and locale ~= "esMX" then return end

local L = ns.L

L["TITLE"] = "Volumen Maestro"
L["TOOLTIP_TITLE"] = "VuMaster"
L["TOOLTIP_VOL"] = "Volumen: "
L["TOOLTIP_DESC"] = "Clic para ajustar el volumen maestro."
L["MUTE_ALL"] = "Silenciar todo"
L["UNMUTE"] = "Desilenciar"
L["PIN_SLIDER"] = "Anclar slider"
L["PIN_DESC"] = "Impide que el slider se cierre al hacer clic fuera."
L["MORE_CONTROLS"] = "+ Más controles"
L["LESS_CONTROLS"] = "- Menos controles"
L["ADDITIONAL_CONTROLS"] = "Controles adicionales"
L["CHANNELS_DESC"] = "Música, Efectos, Voces, Ambiente"
L["MUSIC"] = "Música"
L["SFX"] = "Efectos"
L["DIALOG"] = "Voces"
L["AMBIENCE"] = "Ambiente"
L["RAID"] = "Banda"
L["WORLD"] = "Paseo"
