local ADDON_NAME, ns = ...
local locale = GetLocale()
if locale ~= "ptBR" then return end

local L = ns.L

L["TITLE"] = "Volume Principal"
L["TOOLTIP_TITLE"] = "VuMaster"
L["TOOLTIP_VOL"] = "Volume: "
L["TOOLTIP_DESC"] = "Clique para ajustar o volume principal."
L["MUTE_ALL"] = "Silenciar tudo"
L["UNMUTE"] = "Reativar som"
L["PIN_SLIDER"] = "Fixar controle"
L["PIN_DESC"] = "Impede que o controle feche ao clicar fora."
L["MORE_CONTROLS"] = "+ Mais controles"
L["LESS_CONTROLS"] = "- Menos controles"
L["ADDITIONAL_CONTROLS"] = "Controles adicionais"
L["CHANNELS_DESC"] = "Música, Efeitos Sonoros, Diálogo, Ambiente"
L["MUSIC"] = "Música"
L["SFX"] = "Efeitos Sonoros"
L["DIALOG"] = "Diálogo"
L["AMBIENCE"] = "Ambiente"
L["RAID"] = "Raide"
L["WORLD"] = "Mundo"
