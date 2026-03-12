local ADDON_NAME, ns = ...
local locale = GetLocale()
if locale ~= "ruRU" then return end

local L = ns.L

L["TITLE"] = "Общая громкость"
L["TOOLTIP_TITLE"] = "VuMaster"
L["TOOLTIP_VOL"] = "Громкость: "
L["TOOLTIP_DESC"] = "Нажмите, чтобы настроить общую громкость."
L["MUTE_ALL"] = "Выключить все"
L["UNMUTE"] = "Включить звук"
L["PIN_SLIDER"] = "Закрепить ползунок"
L["PIN_DESC"] = "Предотвращает закрытие ползунка при клике мыши снаружи."
L["MORE_CONTROLS"] = "+ Больше настроек"
L["LESS_CONTROLS"] = "- Меньше настроек"
L["ADDITIONAL_CONTROLS"] = "Дополнительные настройки"
L["CHANNELS_DESC"] = "Музыка, Звуковые эффекты, Диалоги, Окружение"
L["MUSIC"] = "Музыка"
L["SFX"] = "Звуковые эффекты"
L["DIALOG"] = "Диалоги"
L["AMBIENCE"] = "Окружение"
L["RAID"] = "Рейд"
L["WORLD"] = "Мир"
