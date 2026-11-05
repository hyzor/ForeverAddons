-- =====================================================================
--  Forever UI Scale
--
--  Pushes the global UI scale below the floor Blizzard's own slider
--  offers, which is still too large on 1440p and 4K displays.
--
--  Targets the Mainline UI stack, shared by both supported clients:
--    World of Warcraft: Forever   1.60.x   interface 16001
--    Midnight                     12.1.5   interface 120105
--
--  Written from scratch for this collection. The idea of a sub-minimum
--  UI scale addon is not original; zamtin's LowerUIScale predates it and
--  is credited in the .toc. No code was taken from it.
-- =====================================================================

local addonName = ...

local MIN_SCALE, MAX_SCALE, DEFAULT_SCALE = 0.40, 1.00, 0.53
local STEP = 0.01
local PREFIX = "|cff33ff99Forever UI Scale|r "

local core = CreateFrame("Frame", "ForeverUIScaleCore")

-- Panel widgets, built further down.
local panel, slider, valueBox, status

-- Guards the slider against re-entering its own handler while SyncUI()
-- writes a value back into it.
local suppressing = false

------------------------------------------------------------------------
--  Scale plumbing
------------------------------------------------------------------------

local function coerce(value)
    value = tonumber(value)
    if value == nil then return nil end
    if value < MIN_SCALE then return MIN_SCALE end
    if value > MAX_SCALE then return MAX_SCALE end
    return value
end

function core:GetScale()
    return coerce(self.db and self.db.scale) or DEFAULT_SCALE
end

function core:SetScale(value)
    local applied = coerce(value)
    if applied == nil then return nil end
    if self.db then self.db.scale = applied end
    UIParent:SetScale(applied)
    return applied
end

function core:SyncUI()
    if not slider then return end
    local current = self:GetScale()

    suppressing = true
    slider:SetValue(current)
    suppressing = false

    if valueBox then valueBox:SetText(("%.2f"):format(current)) end
    if status then status:SetText(("Current scale: %.2f"):format(current)) end
end

------------------------------------------------------------------------
--  Lifecycle
------------------------------------------------------------------------

core:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end
        ForeverUIScaleDB = ForeverUIScaleDB or {}
        self.db = ForeverUIScaleDB
        -- Normalise whatever was stored: missing, wrong type, or out of range.
        self:SetScale(self:GetScale())
        return
    end

    -- The client applies its own uiScale on login and on every zone load,
    -- so re-assert ours after it has had its turn.
    if self.db then
        self:SetScale(self:GetScale())
    end
end)

core:RegisterEvent("ADDON_LOADED")
core:RegisterEvent("PLAYER_LOGIN")
core:RegisterEvent("PLAYER_ENTERING_WORLD")

------------------------------------------------------------------------
--  Options panel
------------------------------------------------------------------------

panel = CreateFrame("Frame", "ForeverUIScalePanel")
panel.name = "Forever UI Scale"

Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(panel, panel.name))

local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
heading:SetPoint("TOPLEFT", 16, -16)
heading:SetText("Forever UI Scale")

local blurb = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
blurb:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -8)
blurb:SetWidth(540)
blurb:SetJustifyH("LEFT")
blurb:SetText(
    "Blizzard's slider stops at its own minimum, which is still too large on a high-DPI " ..
    "screen. This sets the scale of UIParent directly, so you can go lower.\n\n" ..
    "0.53 is a sensible starting point for 1440p and 4K. Below about 0.40 text stops being " ..
    "readable, so values outside the allowed range are clamped instead of rejected.\n\n" ..
    "Slash command: /uis 0.53"
)

slider = CreateFrame("Slider", "ForeverUIScaleSlider", panel, "OptionsSliderTemplate")
slider:SetPoint("TOPLEFT", blurb, "BOTTOMLEFT", 0, -36)
slider:SetWidth(280)
slider:SetMinMaxValues(MIN_SCALE, MAX_SCALE)
slider:SetValueStep(STEP)
slider:SetObeyStepOnDrag(true)

-- OptionsSliderTemplate names its caption children after the slider, so
-- look them up rather than hard-coding the globals.
local sliderName = slider:GetName()
local lowCaption, highCaption, labelCaption =
    _G[sliderName .. "Low"], _G[sliderName .. "High"], _G[sliderName .. "Text"]
if lowCaption then lowCaption:SetText(("%.2f"):format(MIN_SCALE)) end
if highCaption then highCaption:SetText(("%.2f"):format(MAX_SCALE)) end
if labelCaption then labelCaption:SetText("UI scale") end

local valueLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
valueLabel:SetPoint("LEFT", slider, "RIGHT", 28, 8)
valueLabel:SetText("Exact value")

valueBox = CreateFrame("EditBox", "ForeverUIScaleValueBox", panel, "InputBoxTemplate")
valueBox:SetSize(72, 24)
valueBox:SetPoint("TOP", valueLabel, "BOTTOM", 0, -2)
valueBox:SetAutoFocus(false)
valueBox:SetMaxLetters(5)

valueBox:SetScript("OnEnterPressed", function(self)
    core:SetScale(self:GetText())
    core:SyncUI()
    self:ClearFocus()
end)

valueBox:SetScript("OnEscapePressed", function(self)
    core:SyncUI()
    self:ClearFocus()
end)

slider:SetScript("OnValueChanged", function(self, value)
    if suppressing then return end
    core:SetScale(value)
    core:SyncUI()
end)

local PRESETS = {
    { text = "0.45", value = 0.45 },
    { text = "0.53", value = 0.53 },
    { text = "0.65", value = 0.65 },
    { text = "0.80", value = 0.80 },
    { text = "1.00", value = 1.00 },  -- back to what Blizzard would use
}

local previousButton
for _, preset in ipairs(PRESETS) do
    local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    button:SetSize(58, 22)
    if previousButton then
        button:SetPoint("LEFT", previousButton, "RIGHT", 6, 0)
    else
        button:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -20)
    end
    button:SetText(preset.text)
    button:SetScript("OnClick", function()
        core:SetScale(preset.value)
        core:SyncUI()
    end)
    previousButton = button
end

status = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
status:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -56)
status:SetText(("Current scale: %.2f"):format(core:GetScale()))

panel:SetScript("OnShow", function() core:SyncUI() end)
panel.OnRefresh = function() core:SyncUI() end
panel.OnDefault = function()
    core:SetScale(DEFAULT_SCALE)
    core:SyncUI()
end

------------------------------------------------------------------------
--  Slash command
------------------------------------------------------------------------

SLASH_FOREVERUISCALE1 = "/uis"
SLASH_FOREVERUISCALE2 = "/foreveruiscale"

SlashCmdList["FOREVERUISCALE"] = function(input)
    local requested = tonumber((input or ""):match("^%s*(.-)%s*$"))

    if requested == nil then
        print(PREFIX .. ("current scale is %.2f — try /uis 0.53"):format(core:GetScale()))
        return
    end

    local applied = core:SetScale(requested)
    core:SyncUI()
    print(PREFIX .. ("scale set to %.2f"):format(applied))
end
