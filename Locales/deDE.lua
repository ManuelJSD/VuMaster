local ADDON_NAME, ns = ...
local locale = GetLocale()
if locale ~= "deDE" then return end

local L = ns.L

L["TITLE"] = "Gesamtlautstärke"
L["TOOLTIP_TITLE"] = "VuMaster"
L["TOOLTIP_VOL"] = "Lautstärke: "
L["TOOLTIP_DESC"] = "Klicken, um die Gesamtlautstärke anzupassen."
L["MUTE_ALL"] = "Alle stummschalten"
L["UNMUTE"] = "Stummschaltung aufheben"
L["PIN_SLIDER"] = "Schieberegler anheften"
L["PIN_DESC"] = "Verhindert, dass sich der Schieberegler schließt, wenn nach außen geklickt wird."
L["MORE_CONTROLS"] = "+ Mehr Optionen"
L["LESS_CONTROLS"] = "- Weniger Optionen"
L["ADDITIONAL_CONTROLS"] = "Zusätzliche Optionen"
L["CHANNELS_DESC"] = "Musik, Soundeffekte, Dialog, Umgebung"
L["MUSIC"] = "Musik"
L["SFX"] = "Soundeffekte"
L["DIALOG"] = "Dialog"
L["AMBIENCE"] = "Umgebung"
L["RAID"] = "Schlachtzug"
L["WORLD"] = "Welt"
