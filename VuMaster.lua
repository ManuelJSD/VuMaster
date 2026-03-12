----------------------------------------------------------------------
-- VuMaster  –  Control rápido de volumen maestro desde el minimapa
-- Autor: VuMaster Team  |  Licencia: MIT
----------------------------------------------------------------------

--- Namespace privado del addon
local ADDON_NAME = ...
-- Usaremos un icono interno garantizado del juego mediante su ruta de textura.
-- Fallback temporal a una textura sólida hasta que se corrija el PNG local.
local ICON_TEXTURE = "Interface\\Icons\\Spell_Holy_SealOfSacrifice"
local MINIMAP_RADIUS = 80  -- radio base del minimapa

----------------------------------------------------------------------
--  SavedVariables — valores por defecto
----------------------------------------------------------------------
local defaults = {
    minimapPos = 220,   -- ángulo inicial del icono (grados)
    pinned     = false, -- slider anclado por defecto: no
    sliderPos  = nil,   -- {x, y} posición guardada del panel; nil = junto al minimapa
    expanded   = false, -- sub-panel de sonidos adicionales expandido
    isMuted    = false, -- estado de silencio global
    panelColor = {0.1, 0.1, 0.1, 0.85}, -- color de fondo del panel (Classic Noir)
}

-- Altura del panel en cada estado
local PANEL_H_COLLAPSED = 70
local PANEL_H_EXPANDED  = 225

--- Helper para aplicar el color a los paneles
local function ApplyPanelColor(r, g, b, a)
    local col = {r, g, b, a or 0.85}
    if VuMasterDB then VuMasterDB.panelColor = col end
    if VuMasterSliderPanel then VuMasterSliderPanel:SetBackdropColor(unpack(col)) end
    if VuMasterExtraPanel then VuMasterExtraPanel:SetBackdropColor(unpack(col)) end
end

----------------------------------------------------------------------
--  Utilidades de posición en el minimapa
----------------------------------------------------------------------

--- Calcula la posición (x, y) en el borde del minimapa según un ángulo.
--- @param angle number  Ángulo en grados.
--- @return number, number  Offsets x, y respecto al centro del minimapa.
local function GetMinimapOffset(angle)
    local rad = math.rad(angle)
    local x = math.cos(rad) * MINIMAP_RADIUS
    local y = math.sin(rad) * MINIMAP_RADIUS
    return x, y
end

--- Actualiza la posición del botón del minimapa según el ángulo guardado.
--- @param button Frame  Botón del minimapa.
--- @param angle number  Ángulo en grados.
local function UpdateMinimapButtonPosition(button, angle)
    local x, y = GetMinimapOffset(angle)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

----------------------------------------------------------------------
--  Icono del Minimapa
----------------------------------------------------------------------
local minimapButton = CreateFrame("Button", "VuMasterMinimapButton", Minimap)
minimapButton:SetSize(32, 32)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)
minimapButton:SetMovable(true)
minimapButton:SetClampedToScreen(true)
minimapButton:RegisterForDrag("LeftButton")
minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Volvemos al fallback local, pero apuntando a la versión estricta generada 
-- (icon_v2.png) que hemos introducido en la base de datos de addons de WoW.
local iconTex = minimapButton:CreateTexture(nil, "ARTWORK")
iconTex:SetTexture("Interface\\AddOns\\VuMaster\\icon_v2.png")
iconTex:SetSize(22, 22)
iconTex:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)

local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
overlay:SetSize(53, 53)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT")

-- Para asegurar que se vea como botón interactivo
minimapButton:SetNormalTexture("") -- Limpiamos si hay algo nativo
iconTex:SetDrawLayer("ARTWORK")
overlay:SetDrawLayer("OVERLAY")

----------------------------------------------------------------------
--  Panel Slider de Volumen
----------------------------------------------------------------------
local sliderPanel = CreateFrame("Frame", "VuMasterSliderPanel", UIParent, "BackdropTemplate")
sliderPanel:SetSize(200, PANEL_H_COLLAPSED)
sliderPanel:SetFrameStrata("DIALOG")
sliderPanel:SetClampedToScreen(true)
sliderPanel:Hide()

sliderPanel:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 16,
    insets   = { left = 4, right = 4, top = 4, bottom = 4 },
})
sliderPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.85)
sliderPanel:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)

-- Permitir arrastrar el panel para reposicionarlo
sliderPanel:SetMovable(true)
sliderPanel:EnableMouse(true)
sliderPanel:RegisterForDrag("LeftButton")

sliderPanel:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

sliderPanel:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Guardar posición absoluta para restaurarla en la próxima apertura
    VuMasterDB.sliderPos = {
        x = self:GetLeft(),
        y = self:GetBottom(),
    }
end)

-- Título del panel
local titleText = sliderPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
titleText:SetPoint("TOP", sliderPanel, "TOP", 0, -8)
titleText:SetText("Volumen Maestro")
titleText:SetTextColor(1, 0.82, 0, 1) -- dorado

-- Botón Mute
local muteButton = CreateFrame("Button", "VuMasterMuteButton", sliderPanel)
muteButton:SetSize(16, 16)
muteButton:SetPoint("TOPLEFT", sliderPanel, "TOPLEFT", 6, -6)
local muteIcon = muteButton:CreateTexture(nil, "ARTWORK")
muteIcon:SetAllPoints()
muteIcon:SetAtlas("voicechat-icon-speaker") -- Icono de altavoz inicial

muteButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(VuMasterDB and VuMasterDB.isMuted and "Desilenciar" or "Silenciar todo", 1, 1, 1)
    GameTooltip:Show()
end)
muteButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

muteButton:SetScript("OnClick", function()
    local newState = (tonumber(GetCVar("Sound_EnableAllSound")) or 1) == 1 and 0 or 1
    SetCVar("Sound_EnableAllSound", newState)
    if VuMasterDB then VuMasterDB.isMuted = (newState == 0) end
    muteIcon:SetAtlas(newState == 0 and "voicechat-icon-speaker-mute" or "voicechat-icon-speaker")
    if GameTooltip:IsOwned(muteButton) then
        GameTooltip:SetText(newState == 0 and "Desilenciar" or "Silenciar todo", 1, 1, 1)
    end
end)

-- Slider de volumen
local volumeSlider = CreateFrame("Slider", "VuMasterVolumeSlider", sliderPanel, "OptionsSliderTemplate")
volumeSlider:SetPoint("TOP", titleText, "BOTTOM", 0, -8)
volumeSlider:SetWidth(150)
volumeSlider:SetHeight(17)
volumeSlider:SetMinMaxValues(0, 100)
volumeSlider:SetValueStep(1)
volumeSlider:SetObeyStepOnDrag(true)

-- Etiqueta del valor actual
local valueText = sliderPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
valueText:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -2)

-- Configurar textos de min/max del template
VuMasterVolumeSliderLow:SetText("0")
VuMasterVolumeSliderHigh:SetText("100")

----------------------------------------------------------------------
--  Botón de Anclaje (Pin)
----------------------------------------------------------------------
local pinButton = CreateFrame("CheckButton", "VuMasterPinButton", sliderPanel, "UICheckButtonTemplate")
pinButton:SetSize(22, 22)
pinButton:SetPoint("TOPRIGHT", sliderPanel, "TOPRIGHT", -4, -4)

--- Tooltip del botón de pin
pinButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Anclar slider", 1, 1, 1)
    GameTooltip:AddLine("Impide que el slider se cierre al hacer clic fuera.", nil, nil, nil, true)
    GameTooltip:Show()
end)
pinButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

pinButton:SetScript("OnClick", function(self)
    VuMasterDB.pinned = self:GetChecked()
    -- Al anclar, el panel permanece visible aunque se haga clic fuera
    -- (GLOBAL_MOUSE_DOWN respeta VuMasterDB.pinned para no cerrar el panel)
end)

----------------------------------------------------------------------
--  Sub-panel de sonidos adicionales
----------------------------------------------------------------------
local extraPanel = CreateFrame("Frame", "VuMasterExtraPanel", sliderPanel, "BackdropTemplate")
extraPanel:SetSize(192, 145)
extraPanel:SetPoint("TOP", volumeSlider, "BOTTOM", 0, -22)
extraPanel:Hide()

extraPanel:SetBackdrop({
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile     = true,
    tileSize = 16,
    edgeSize = 12,
    insets   = { left = 3, right = 3, top = 3, bottom = 3 },
})
extraPanel:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
extraPanel:SetBackdropBorderColor(0.45, 0.45, 0.55, 0.7)

-- Tabla con los canales de sonido adicionales: {nombre, cvar}
local soundChannels = {
    { nombre = "Música",    cvar = "Sound_MusicVolume"    },
    { nombre = "Efectos",   cvar = "Sound_SFXVolume"      },
    { nombre = "Voces",     cvar = "Sound_DialogVolume"   },
    { nombre = "Ambiente",  cvar = "Sound_AmbienceVolume" },
}

-- Referencia a cada slider extra para sincronizarlos luego
local extraSliders = {}

--- Crea una fila de slider dentro del extraPanel.
--- @param parent Frame   Frame padre.
--- @param info   table   {nombre, cvar}.
--- @param index  number  Posición vertical (1-based).
--- @return Slider El slider creado.
local function CreateSoundSlider(parent, info, index)
    local ROW_H  = 26
    local yOff   = -6 - (index - 1) * ROW_H

    -- Etiqueta del canal
    local lbl = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yOff)
    lbl:SetText(info.nombre)
    lbl:SetTextColor(0.85, 0.85, 0.85, 1)

    -- Slider
    local sl = CreateFrame("Slider", "VuMaster_"..info.cvar.."_Slider", parent, "OptionsSliderTemplate")
    sl:SetPoint("LEFT", parent, "LEFT", 68, 0)
    sl:SetPoint("RIGHT", parent, "RIGHT", -32, 0)
    sl:SetPoint("TOP", lbl, "TOP", 0, 2)
    sl:SetHeight(14)
    sl:SetMinMaxValues(0, 100)
    sl:SetValueStep(1)
    sl:SetObeyStepOnDrag(true)

    -- Ocultar etiquetas Low/High del template (muy pequeño el panel)
    local lowLbl  = _G["VuMaster_"..info.cvar.."_SliderLow"]
    local highLbl = _G["VuMaster_"..info.cvar.."_SliderHigh"]
    if lowLbl  then lowLbl:SetText("")  end
    if highLbl then highLbl:SetText("") end

    -- Porcentaje a la derecha
    local pctLbl = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pctLbl:SetPoint("LEFT", sl, "RIGHT", 4, 0)
    pctLbl:SetText("--")

    -- Lógica de cambio de valor
    sl:SetScript("OnValueChanged", function(_, value)
        local pct = math.floor(value + 0.5)
        pctLbl:SetText(pct .. "%")
        SetCVar(info.cvar, value / 100)
    end)

    -- Tooltip
    sl:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(info.nombre, 1, 0.82, 0)
        local v = tonumber(GetCVar(info.cvar)) or 1
        GameTooltip:AddLine(math.floor(v * 100 + 0.5) .. "%", 1, 1, 1)
        GameTooltip:Show()
    end)
    sl:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return sl
end

-- Construir los sliders extra
for i, ch in ipairs(soundChannels) do
    extraSliders[i] = CreateSoundSlider(extraPanel, ch, i)
end

----------------------------------------------------------------------
--  Botones de Perfiles y Colores
----------------------------------------------------------------------
local btnBanda = CreateFrame("Button", "VuMasterProfileRaid", extraPanel, "UIPanelButtonTemplate")
btnBanda:SetSize(55, 20)
btnBanda:SetPoint("BOTTOMLEFT", extraPanel, "BOTTOMLEFT", 6, 8)
btnBanda:SetText("Banda")

local btnPaseo = CreateFrame("Button", "VuMasterProfileWorld", extraPanel, "UIPanelButtonTemplate")
btnPaseo:SetSize(55, 20)
btnPaseo:SetPoint("BOTTOMRIGHT", extraPanel, "BOTTOMRIGHT", -6, 8)
btnPaseo:SetText("Paseo")

-- Forward declaration needed for SyncExtraSliders which is defined below
-- but we simply inline the setting or rely on the game updating it
btnBanda:SetScript("OnClick", function()
    SetCVar("Sound_MusicVolume", 0.1)
    SetCVar("Sound_SFXVolume", 0.6)
    SetCVar("Sound_DialogVolume", 1.0)
    SetCVar("Sound_AmbienceVolume", 0.3)
    -- Reflejar en la UI
    extraSliders[1]:SetValue(10)
    extraSliders[2]:SetValue(60)
    extraSliders[3]:SetValue(100)
    extraSliders[4]:SetValue(30)
end)

btnPaseo:SetScript("OnClick", function()
    SetCVar("Sound_MusicVolume", 0.8)
    SetCVar("Sound_SFXVolume", 0.8)
    SetCVar("Sound_DialogVolume", 0.8)
    SetCVar("Sound_AmbienceVolume", 0.8)
    extraSliders[1]:SetValue(80)
    extraSliders[2]:SetValue(80)
    extraSliders[3]:SetValue(80)
    extraSliders[4]:SetValue(80)
end)

-- Temas de Color (3 cuadros pequeños centrados en la parte inferior de extraPanel)
local colors = {
    {r=0.1,  g=0.1,  b=0.1},   -- Noir/Classic
    {r=0.25, g=0.05, b=0.05},  -- Horda
    {r=0.05, g=0.1,  b=0.25},  -- Alianza
}
local c1 = CreateFrame("Button", nil, extraPanel)
c1:SetSize(12, 12)
c1:SetPoint("BOTTOM", extraPanel, "BOTTOM", -16, 12)
local c1tex = c1:CreateTexture(nil, "BACKGROUND")
c1tex:SetAllPoints(); c1tex:SetColorTexture(colors[1].r, colors[1].g, colors[1].b)
c1:SetScript("OnClick", function() ApplyPanelColor(colors[1].r, colors[1].g, colors[1].b) end)

local c2 = CreateFrame("Button", nil, extraPanel)
c2:SetSize(12, 12)
c2:SetPoint("LEFT", c1, "RIGHT", 4, 0)
local c2tex = c2:CreateTexture(nil, "BACKGROUND")
c2tex:SetAllPoints(); c2tex:SetColorTexture(colors[2].r, colors[2].g, colors[2].b)
c2:SetScript("OnClick", function() ApplyPanelColor(colors[2].r, colors[2].g, colors[2].b) end)

local c3 = CreateFrame("Button", nil, extraPanel)
c3:SetSize(12, 12)
c3:SetPoint("LEFT", c2, "RIGHT", 4, 0)
local c3tex = c3:CreateTexture(nil, "BACKGROUND")
c3tex:SetAllPoints(); c3tex:SetColorTexture(colors[3].r, colors[3].g, colors[3].b)
c3:SetScript("OnClick", function() ApplyPanelColor(colors[3].r, colors[3].g, colors[3].b) end)

----------------------------------------------------------------------
--  Botón expandir / colapsar
----------------------------------------------------------------------
local expandButton = CreateFrame("Button", "VuMasterExpandButton", sliderPanel)
expandButton:SetSize(120, 16)
expandButton:SetPoint("BOTTOM", sliderPanel, "BOTTOM", 0, 4)

-- Texto del botón
local expandLabel = expandButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
expandLabel:SetAllPoints()
expandLabel:SetText("+ Más controles")
expandLabel:SetTextColor(0.8, 0.8, 0.8, 1)

-- Resaltado al pasar el ratón
expandButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

expandButton:SetScript("OnEnter", function(self)
    expandLabel:SetTextColor(1, 0.82, 0, 1)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:SetText("Controles adicionales", 1, 0.82, 0)
    GameTooltip:AddLine("Música, Efectos, Voces, Ambiente", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
expandButton:SetScript("OnLeave", function()
    expandLabel:SetTextColor(0.8, 0.8, 0.8, 1)
    GameTooltip:Hide()
end)

--- Sincroniza los sliders extra con los CVars actuales.
local function SyncExtraSliders()
    for i, ch in ipairs(soundChannels) do
        local v = tonumber(GetCVar(ch.cvar)) or 1
        extraSliders[i]:SetValue(v * 100)
    end
end

--- Expande o colapsa el sub-panel de sonidos adicionales.
local function ToggleExtraPanel()
    if extraPanel:IsShown() then
        -- Colapsar
        extraPanel:Hide()
        sliderPanel:SetHeight(PANEL_H_COLLAPSED)
        expandLabel:SetText("+ Más controles")
        if VuMasterDB then VuMasterDB.expanded = false end
    else
        -- Expandir
        SyncExtraSliders()
        sliderPanel:SetHeight(PANEL_H_EXPANDED)
        extraPanel:Show()
        expandLabel:SetText("- Menos controles")
        if VuMasterDB then VuMasterDB.expanded = true end
    end
end

expandButton:SetScript("OnClick", function()
    ToggleExtraPanel()
end)

----------------------------------------------------------------------
--  Lógica del Slider de Volumen
----------------------------------------------------------------------

--- Actualiza el texto del porcentaje y aplica el CVar.
--- @param value number  Valor del slider (0-100).
local function ApplyVolume(value)
    local pct = math.floor(value + 0.5)
    valueText:SetText(pct .. "%")
    SetCVar("Sound_MasterVolume", value / 100)
end

volumeSlider:SetScript("OnValueChanged", function(_, value)
    ApplyVolume(value)
end)

--- Lee el volumen maestro actual del CVar y lo refleja en el slider.
local function SyncSliderToCurrentVolume()
    local vol = tonumber(GetCVar("Sound_MasterVolume")) or 1
    volumeSlider:SetValue(vol * 100)
    ApplyVolume(vol * 100)
end

----------------------------------------------------------------------
--  Posicionamiento del panel junto al icono
----------------------------------------------------------------------

--- Posiciona el panel slider.
--- Si el usuario lo movió previamente, restaura esa posición;
--- de lo contrario lo ancla debajo del botón del minimapa.
local function AnchorSliderPanel()
    sliderPanel:ClearAllPoints()
    if VuMasterDB and VuMasterDB.sliderPos then
        -- Restaurar posición guardada por el usuario
        sliderPanel:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",
            VuMasterDB.sliderPos.x, VuMasterDB.sliderPos.y)
    else
        -- Posición por defecto: debajo del botón del minimapa
        sliderPanel:SetPoint("TOP", minimapButton, "BOTTOM", 0, -5)
    end
end

----------------------------------------------------------------------
--  Mostrar / Ocultar el panel
----------------------------------------------------------------------

--- Alterna la visibilidad del panel slider.
local function ToggleSliderPanel()
    if sliderPanel:IsShown() then
        sliderPanel:Hide()
    else
        SyncSliderToCurrentVolume()
        AnchorSliderPanel()
        sliderPanel:Show()
        -- Restaurar estado expandido guardado
        if VuMasterDB and VuMasterDB.expanded then
            SyncExtraSliders()
            sliderPanel:SetHeight(PANEL_H_EXPANDED)
            extraPanel:Show()
            expandLabel:SetText("- Menos controles")
        end
    end
end

----------------------------------------------------------------------
--  Ocultar al hacer clic fuera (si no está anclado)
----------------------------------------------------------------------

-- Registrar el panel para cerrar con Escape
tinsert(UISpecialFrames, "VuMasterSliderPanel")

-- NOTA: se usa GLOBAL_MOUSE_DOWN en lugar de un frame invisible (clickCatcher).
-- El clickCatcher bloqueaba el arrastre derecho del ratón para mover la cámara.
-- GLOBAL_MOUSE_DOWN detecta clics en toda la pantalla sin interferir con la UI.

sliderPanel:SetScript("OnShow", function()
end)

sliderPanel:SetScript("OnHide", function()
end)

----------------------------------------------------------------------
--  Eventos del botón del minimapa
----------------------------------------------------------------------

minimapButton:SetScript("OnClick", function(_, button)
    if button == "LeftButton" then
        ToggleSliderPanel()
    end
end)

-- Tooltip del botón del minimapa
minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("VuMaster", 1, 0.82, 0)
    local vol = tonumber(GetCVar("Sound_MasterVolume")) or 1
    GameTooltip:AddLine("Volumen: " .. math.floor(vol * 100 + 0.5) .. "%", 1, 1, 1)
    GameTooltip:AddLine("Clic para ajustar el volumen maestro.", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

----------------------------------------------------------------------
--  Arrastrar el icono alrededor del minimapa
----------------------------------------------------------------------
local isDragging = false

minimapButton:SetScript("OnDragStart", function()
    isDragging = true
    -- Ocultar el slider mientras se arrastra
    if sliderPanel:IsShown() then
        sliderPanel:Hide()
    end
end)

minimapButton:SetScript("OnDragStop", function()
    isDragging = false
end)

--- OnUpdate durante el drag para recalcular la posición angular.
minimapButton:SetScript("OnUpdate", function()
    if not isDragging then return end

    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale  = Minimap:GetEffectiveScale()
    cx, cy = cx / scale, cy / scale

    local angle = math.deg(math.atan2(cy - my, cx - mx))
    VuMasterDB.minimapPos = angle
    UpdateMinimapButtonPosition(minimapButton, angle)
end)

----------------------------------------------------------------------
--  Inicialización — ADDON_LOADED + PLAYER_LOGIN
----------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        -- Inicializar SavedVariables con valores por defecto
        if not VuMasterDB then
            VuMasterDB = {}
        end
        for k, v in pairs(defaults) do
            if VuMasterDB[k] == nil then
                VuMasterDB[k] = v
            end
        end

        -- Posicionar el icono del minimapa
        UpdateMinimapButtonPosition(minimapButton, VuMasterDB.minimapPos)

        -- Restaurar estado del pin
        pinButton:SetChecked(VuMasterDB.pinned)

        -- Restaurar estado de silencio visual
        local isActuallyMuted = (tonumber(GetCVar("Sound_EnableAllSound")) or 1) == 0
        if VuMasterDB.isMuted ~= isActuallyMuted then
            VuMasterDB.isMuted = isActuallyMuted
        end
        _G["VuMasterMuteButton"]:GetNormalTexture() -- Not used directly, using muteIcon:
        -- Access local texture by traversing
        local regions = {_G["VuMasterMuteButton"]:GetRegions()}
        for _, reg in ipairs(regions) do
            if reg:GetObjectType() == "Texture" and reg:GetDrawLayer() == "ARTWORK" then
                reg:SetAtlas(VuMasterDB.isMuted and "voicechat-icon-speaker-mute" or "voicechat-icon-speaker")
            end
        end

        -- Restaurar color
        if VuMasterDB.panelColor then
            ApplyPanelColor(unpack(VuMasterDB.panelColor))
        end

    elseif event == "PLAYER_LOGIN" then
        -- Sincronizar el slider con el volumen actual del juego
        SyncSliderToCurrentVolume()

    elseif event == "GLOBAL_MOUSE_DOWN" then
        -- Cerrar el panel si se hace clic izquierdo fuera de él y no está anclado.
        -- A diferencia del clickCatcher, este evento NO bloquea el ratón ni la cámara.
        local button = arg1
        if button == "LeftButton"
            and not VuMasterDB.pinned
            and sliderPanel:IsShown()
            and not MouseIsOver(sliderPanel)
            and not MouseIsOver(minimapButton) then
            sliderPanel:Hide()
        end
    end
end)
