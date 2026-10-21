local ADDON_NAME, ns = ...
local L = ns.L or {}

----------------------------------------------------------------------
--  Panel de Opciones Principal
----------------------------------------------------------------------
local optionsPanel = CreateFrame("Frame", "VuMasterOptionsFrame", UIParent, "BackdropTemplate")
optionsPanel:SetSize(450, 350)
optionsPanel:SetPoint("CENTER")
optionsPanel:SetFrameStrata("DIALOG")
optionsPanel:SetMovable(true)
optionsPanel:EnableMouse(true)
optionsPanel:RegisterForDrag("LeftButton")
optionsPanel:SetScript("OnDragStart", optionsPanel.StartMoving)
optionsPanel:SetScript("OnDragStop", optionsPanel.StopMovingOrSizing)
optionsPanel:Hide()
tinsert(UISpecialFrames, "VuMasterOptionsFrame")

-- Estilo del panel (Moderno por defecto para las opciones)
optionsPanel:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = true,
    tileSize = 32,
    edgeSize = 32,
    insets   = { left = 11, right = 12, top = 12, bottom = 11 },
})

-- Título
local title = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", optionsPanel, "TOP", 0, -16)
title:SetText("VuMaster Options")

-- Botón Cerrar (Esquina superior derecha)
local closeButton = CreateFrame("Button", nil, optionsPanel, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", optionsPanel, "TOPRIGHT", -4, -4)
closeButton:SetScript("OnClick", function()
    optionsPanel:Hide()
end)

----------------------------------------------------------------------
--  Sistema de Pestañas / Menú Lateral
----------------------------------------------------------------------
-- Contenedor izquierdo para botones
local sidebar = CreateFrame("Frame", nil, optionsPanel, "BackdropTemplate")
sidebar:SetSize(120, 280)
sidebar:SetPoint("TOPLEFT", optionsPanel, "TOPLEFT", 16, -50)
sidebar:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
sidebar:SetBackdropColor(0, 0, 0, 0.5)

-- Contenedor derecho para el contenido
local content = CreateFrame("Frame", nil, optionsPanel, "BackdropTemplate")
content:SetSize(280, 280)
content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
content:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
})
content:SetBackdropColor(0, 0, 0, 0.5)

-- Arrays para manejar la navegación
local tabs = {}
local panels = {}

local function ShowPanel(index)
    for i, p in ipairs(panels) do
        if i == index then
            p:Show()
            tabs[i]:LockHighlight()
        else
            p:Hide()
            tabs[i]:UnlockHighlight()
        end
    end
end

local function CreateTabButton(index, text)
    local btn = CreateFrame("Button", nil, sidebar, "UIPanelButtonTemplate")
    btn:SetSize(100, 25)
    if index == 1 then
        btn:SetPoint("TOP", sidebar, "TOP", 0, -10)
    else
        btn:SetPoint("TOP", tabs[index-1], "BOTTOM", 0, -5)
    end
    btn:SetText(text)
    btn:SetScript("OnClick", function()
        ShowPanel(index)
    end)
    tabs[index] = btn
    return btn
end

local function CreateContentPanel(index)
    local p = CreateFrame("Frame", nil, content)
    p:SetAllPoints()
    p:Hide()
    panels[index] = p
    return p
end

----------------------------------------------------------------------
--  Panel 1: Skins / Apariencia
----------------------------------------------------------------------
local tabSkins = CreateTabButton(1, "Apariencia")
local panelSkins = CreateContentPanel(1)

local skinsTitle = panelSkins:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
skinsTitle:SetPoint("TOPLEFT", panelSkins, "TOPLEFT", 16, -16)
skinsTitle:SetText(L["SKINS_TAB"] or "Selector de Skin")

-- Lista de skins disponibles
local skinNames = {"Classic", "ElvUI", "Modern", "Custom"}
local skinRadioButtons = {}

-- Configuración Personalizada (solo visible si skin == Custom)
local customConfigFrame = CreateFrame("Frame", nil, panelSkins)
customConfigFrame:SetSize(250, 100)
customConfigFrame:SetPoint("TOPLEFT", skinsTitle, "BOTTOMLEFT", 0, -140)
customConfigFrame:Hide()

local function UpdateCustomConfigVisibility()
    if VuMasterDB.skin == "Custom" then
        customConfigFrame:Show()
    else
        customConfigFrame:Hide()
    end
end

-- Función para actualizar los Radio Buttons
local function UpdateSkinRadios()
    for _, btn in ipairs(skinRadioButtons) do
        btn:SetChecked(VuMasterDB.skin == btn.skinID)
    end
    UpdateCustomConfigVisibility()
    ns.ApplySkin()
end

-- Crear botones de opción (Radio Buttons) para cada Skin
for i, skinID in ipairs(skinNames) do
    local radio = CreateFrame("CheckButton", nil, panelSkins, "UIRadioButtonTemplate")
    radio:SetPoint("TOPLEFT", skinsTitle, "BOTTOMLEFT", 0, -10 - ((i-1)*25))
    local text = radio:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", radio, "RIGHT", 5, 0)
    text:SetText(ns.Skins[skinID] and ns.Skins[skinID].name or skinID)
    
    radio.skinID = skinID
    radio:SetScript("OnClick", function(self)
        VuMasterDB.skin = self.skinID
        UpdateSkinRadios()
    end)
    table.insert(skinRadioButtons, radio)
end

-- Opciones para "Custom" Skin
local customDesc = customConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
customDesc:SetPoint("TOPLEFT", customConfigFrame, "TOPLEFT", 0, 0)
customDesc:SetText(L["CUSTOM_COLORS"] or "Colores Personalizados")

-- Función para abrir ColorPicker en cualquier versión de WoW
local function OpenColorPicker(colorTable, callback)
    local r, g, b, a = unpack(colorTable)
    
    -- Retail (Dragonflight 10.2.5+) usa ColorPickerFrame.SetupColorPickerAndShow
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, a = a,
            hasOpacity = true,
            swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                local na = ColorPickerFrame:GetColorAlpha()
                callback(nr, ng, nb, na)
            end,
            opacityFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                local na = ColorPickerFrame:GetColorAlpha()
                callback(nr, ng, nb, na)
            end,
            cancelFunc = function(prev)
                callback(prev.r, prev.g, prev.b, prev.a)
            end,
        })
    else
        -- Classic y Retail antiguo
        ColorPickerFrame.func = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            local na = OpacitySliderFrame:GetValue()
            callback(nr, ng, nb, 1 - na) -- OpacitySliderFrame usa opacidad inversa a veces, pero a = 1-na es común
        end
        ColorPickerFrame.opacityFunc = ColorPickerFrame.func
        ColorPickerFrame.cancelFunc = function(prev)
            callback(prev.r, prev.g, prev.b, prev.a)
        end
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = 1 - (a or 1)
        ColorPickerFrame.previousValues = {r=r, g=g, b=b, a=a}
        ColorPickerFrame:SetColorRGB(r, g, b)
        ShowUIPanel(ColorPickerFrame)
    end
end

-- Botón para Color de Fondo
local btnBgColor = CreateFrame("Button", nil, customConfigFrame, "UIPanelButtonTemplate")
btnBgColor:SetSize(120, 22)
btnBgColor:SetPoint("TOPLEFT", customDesc, "BOTTOMLEFT", 0, -10)
btnBgColor:SetText("Fondo")
local bgTex = btnBgColor:CreateTexture(nil, "ARTWORK")
bgTex:SetSize(14, 14)
bgTex:SetPoint("RIGHT", btnBgColor, "RIGHT", -4, 0)
bgTex:SetColorTexture(1,1,1,1)

btnBgColor:SetScript("OnClick", function()
    OpenColorPicker(VuMasterDB.customBgColor or {0.1,0.1,0.1,0.85}, function(r, g, b, a)
        VuMasterDB.customBgColor = {r, g, b, a}
        bgTex:SetColorTexture(r, g, b, a)
        ns.ApplySkin()
    end)
end)

-- Botón para Color de Borde
local btnBorderColor = CreateFrame("Button", nil, customConfigFrame, "UIPanelButtonTemplate")
btnBorderColor:SetSize(120, 22)
btnBorderColor:SetPoint("TOPLEFT", btnBgColor, "BOTTOMLEFT", 0, -5)
btnBorderColor:SetText("Borde")
local borderTex = btnBorderColor:CreateTexture(nil, "ARTWORK")
borderTex:SetSize(14, 14)
borderTex:SetPoint("RIGHT", btnBorderColor, "RIGHT", -4, 0)
borderTex:SetColorTexture(1,1,1,1)

btnBorderColor:SetScript("OnClick", function()
    OpenColorPicker(VuMasterDB.customBorderColor or {0.6,0.6,0.6,0.8}, function(r, g, b, a)
        VuMasterDB.customBorderColor = {r, g, b, a}
        borderTex:SetColorTexture(r, g, b, a)
        ns.ApplySkin()
    end)
end)

local function UpdateCustomColorTextures()
    if VuMasterDB.customBgColor then
        bgTex:SetColorTexture(unpack(VuMasterDB.customBgColor))
    end
    if VuMasterDB.customBorderColor then
        borderTex:SetColorTexture(unpack(VuMasterDB.customBorderColor))
    end
end

----------------------------------------------------------------------
--  Panel 2: General / Minimapa
----------------------------------------------------------------------
local tabGeneral = CreateTabButton(2, "General")
local panelGeneral = CreateContentPanel(2)

local genTitle = panelGeneral:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
genTitle:SetPoint("TOPLEFT", panelGeneral, "TOPLEFT", 16, -16)
genTitle:SetText(L["GENERAL_TAB"] or "Configuración General")

local chkHideMinimap = CreateFrame("CheckButton", "VuMasterHideMinimapOption", panelGeneral, "UICheckButtonTemplate")
chkHideMinimap:SetPoint("TOPLEFT", genTitle, "BOTTOMLEFT", 0, -15)
local chkText = chkHideMinimap:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
chkText:SetPoint("LEFT", chkHideMinimap, "RIGHT", 5, 0)
chkText:SetText(L["HIDE_MINIMAP"] or "Ocultar botón del minimapa")
chkHideMinimap:SetScript("OnClick", function(self)
    local hide = self:GetChecked()
    VuMasterDB.hideMinimap = hide
    if VuMasterMinimapButton then
        if hide then
            VuMasterMinimapButton:Hide()
        else
            VuMasterMinimapButton:Show()
        end
    end
end)

-- Slider de Escala del Panel
local scaleSlider = CreateFrame("Slider", "VuMasterScaleOptionSlider", panelGeneral, "OptionsSliderTemplate")
scaleSlider:SetPoint("TOPLEFT", chkHideMinimap, "BOTTOMLEFT", 5, -25)
scaleSlider:SetWidth(200)
scaleSlider:SetHeight(17)
scaleSlider:SetMinMaxValues(0.5, 1.5)
scaleSlider:SetValueStep(0.05)
if scaleSlider.SetObeyStepOnDrag then
    scaleSlider:SetObeyStepOnDrag(true)
end

-- Textos del Slider de Escala
_G["VuMasterScaleOptionSliderLow"]:SetText("50%")
_G["VuMasterScaleOptionSliderHigh"]:SetText("150%")
local scaleText = scaleSlider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
scaleText:SetPoint("BOTTOM", scaleSlider, "TOP", 0, 2)
scaleText:SetText((L["PANEL_SCALE"] or "Escala del panel") .. ": 100%")

scaleSlider:SetScript("OnValueChanged", function(self, value)
    local pct = math.floor(value * 100 + 0.5)
    scaleText:SetText((L["PANEL_SCALE"] or "Escala del panel") .. ": " .. pct .. "%")
    VuMasterDB.panelScale = value
    if VuMasterSliderPanel then
        VuMasterSliderPanel:SetScale(value)
    end
end)

-- Actualizar valores en OnShow de panelGeneral
panelGeneral:SetScript("OnShow", function()
    chkHideMinimap:SetChecked(VuMasterDB.hideMinimap)
    scaleSlider:SetValue(VuMasterDB.panelScale or 1.0)
end)

----------------------------------------------------------------------
--  Funciones Públicas y Eventos
----------------------------------------------------------------------
function ns.ToggleOptionsPanel()
    if optionsPanel:IsShown() then
        optionsPanel:Hide()
    else
        UpdateSkinRadios()
        UpdateCustomColorTextures()
        ShowPanel(1) -- Mostrar primera pestaña por defecto
        optionsPanel:Show()
    end
end

-- Comandos de chat
SLASH_VUMASTER1 = "/vm"
SLASH_VUMASTER2 = "/vumaster"
SlashCmdList["VUMASTER"] = function()
    ns.ToggleOptionsPanel()
end

----------------------------------------------------------------------
--  Integración con la Interfaz de Addons de Blizzard
----------------------------------------------------------------------
local blizzPanel = CreateFrame("Frame", "VuMasterBlizzPanel", UIParent)
blizzPanel.name = "VuMaster"

local blizzTitle = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
blizzTitle:SetPoint("TOPLEFT", 16, -16)
blizzTitle:SetText("VuMaster")

local blizzDesc = blizzPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
blizzDesc:SetPoint("TOPLEFT", blizzTitle, "BOTTOMLEFT", 0, -8)
blizzDesc:SetText("Control rápido de volumen maestro.")

local btnOpenOptions = CreateFrame("Button", nil, blizzPanel, "UIPanelButtonTemplate")
btnOpenOptions:SetSize(200, 40)
btnOpenOptions:SetPoint("TOPLEFT", blizzDesc, "BOTTOMLEFT", 0, -20)
btnOpenOptions:SetText(L["OPEN_OPTIONS"] or "Abrir Panel de Opciones")
btnOpenOptions:SetScript("OnClick", function()
    -- Cerrar paneles de Blizzard para evitar que se superpongan
    if SettingsPanel then SettingsPanel:Hide() end
    if InterfaceOptionsFrame then InterfaceOptionsFrame:Hide() end
    ns.ToggleOptionsPanel()
end)

-- Registro dual: modern Settings API (Retail / Forever) o legacy InterfaceOptions (Classic)
if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    local category, layout = Settings.RegisterCanvasLayoutCategory(blizzPanel, blizzPanel.name)
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(blizzPanel)
end
