--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local string 	= _G.string;
local table     = _G.table;
local format = string.format;
local tcopy = table.copy;
local SOURCE_KEY = 1;
local TRANSFER_MAP = {
	["general"] = "general",
	["screen"] = "screen",
	["SVTip"] = "Tooltip",
	["SVChat"] = "Chat",
	["SVPlate"] = "NamePlates",
	["SVTools"] = "Extras",
	["SVAura"] = "Auras",
	["SVQuest"] = "QuestTracker",
	["Dock"] = "Dock",
	["SVDock"] = "Dock",
	["SVStats"] = "Reports",
	["SVBag"] = "Inventory",
	["SVMap"] = "Maps",
	["SVUnit"] = "UnitFrames",
	["SVBar"] = "ActionBars",
	["SVGear"] = "Gear",
}

local function GetGlobalData(file)
	local DATA = _G[file];
	if(not file or (file and not file.STORED)) then return end
    return DATA.STORED[SOURCE_KEY]
end

local function tablecopy(d, s)
    if(type(s) ~= "table") then return end
    if(type(d) ~= "table") then return end
    for k, v in pairs(s) do
        local saved = rawget(d, k)
        if type(v) == "table" then
            if not saved then rawset(d, k, {}) end
            tablecopy(d[k], v)
        elseif(saved == nil or (saved and type(saved) ~= type(v))) then
            rawset(d, k, v)
        end
    end
end

local TransferButton_OnClick = function(self)
	local SV = _G["SVUI"];
	if(not SV or (SV and not SV.db)) then
		print("An error occured.")
		return 
	end

	local SVUILib = Librarian("Registry");

	if(SVUI_Profile and SVUI_Profile.SAFEDATA and SVUI_Profile.SAFEDATA.dualSpecEnabled) then
		SOURCE_KEY = GetSpecialization()
	end

	local data = rawget(SV.db, "data");
	local private = GetGlobalData("SVUI_Profile");
	if(private) then
		for k, v in pairs(private) do
			local link = TRANSFER_MAP[k]
			if(link and data[link]) then
				tablecopy(data[link], v)
			end
		end
	end

	local cache = GetGlobalData("SVUI_Cache")
	if(cache and cache.Anchors and data.LAYOUT) then
		for k, v in pairs(cache.Anchors) do
			data.LAYOUT[k] = v
		end
	end

	print("Transfer Wizard Complete.")
	SVUI_TransferWizard:Hide()
	SVUILib:SaveSafeData("transfer_wizard_used", true);
	if(not InCombatLockdown()) then
        ReloadUI()
    end
end

_G.SVUI_TRANSFER_WIZARD = function()
	if not SVUI_TransferWizard then 
		local frame = CreateFrame("Button", "SVUI_TransferWizard", UIParent)
		frame:SetSize(500, 180)
		frame:SetStyle("Frame", "Window")
		frame:SetPoint("TOP", UIParent, "TOP", 0, -150)
		frame:SetFrameStrata("TOOLTIP")

		--[[ TRANSFER BUTTON ]]--

		frame.Transfer = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Transfer:SetSize(110, 25)
		frame.Transfer:SetPoint("BOTTOM", 0, 5)
		frame.Transfer:SetStyle("Button")
		frame.Transfer.text = frame.Transfer:CreateFontString(nil, "OVERLAY")
		frame.Transfer.text:SetFontObject(SVUI_Font_Caps)
		frame.Transfer.text:SetPoint("CENTER")
		frame.Transfer.text:SetText("Begin Transfer")
		frame.Transfer:SetScript("OnClick", TransferButton_OnClick)

		--[[ TEXT HOLDERS ]]--

		local statusHolder = CreateFrame("Frame", nil, frame)
		statusHolder:SetFrameLevel(statusHolder:GetFrameLevel() + 2)
		statusHolder:SetSize(150, 30)
		statusHolder:SetPoint("BOTTOM", frame, "TOP", 0, 2)

		local titleHolder = frame:CreateFontString(nil, "OVERLAY")
		titleHolder:SetFontObject(SVUI_Font_Header)
		titleHolder:SetPoint("TOP", 0, -5)
		titleHolder:SetText("SVUI Transfer Wizard")

		local subTitle = frame:CreateFontString(nil, "OVERLAY")
		subTitle:SetFontObject(SVUI_Font_Narrator)
		subTitle:SetPoint("TOP", 0, -40)
		subTitle:SetText("This will attempt to convert SVUI (Classic) settings\nfor use with the latest version of SVUI.")

		--[[ MISC ]]--

		local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
		closeButton:SetScript("OnClick", function() frame:Hide() end)
	end
	
	SVUI_TransferWizard:Show()
end

_G.SlashCmdList["SVUISVTRANSFER"] = SVUI_TRANSFER_WIZARD;
_G.SLASH_SVUISVTRANSFER1 = "/svtransfer"
