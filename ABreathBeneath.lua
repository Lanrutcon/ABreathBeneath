-----------------------------------
--Missing functions - VANILLA

local function SetSize(frame, width, height)
	frame:SetHeight(height);
	frame:SetWidth(width);
end


--From CustomNameplates by Dridzt
local function isNamePlateFrame(frame)
	local overlayRegion = frame:GetRegions()
	if not overlayRegion or overlayRegion:GetObjectType() ~= "Texture" or overlayRegion:GetTexture() ~= "Interface\\Tooltips\\Nameplate-Border" then
		return false
	end
	return true
end

----------------------------------


local Addon = CreateFrame("FRAME");

local nameplateCache = {};
local WorldFrame = WorldFrame;
local pairs = pairs;
local strfind = string.find;



local function hideBlizzArt(self)
	self.healthbar:Hide();

	self.healthborder:Hide();
	self.glow:SetTexture(nil);
	self.skull:SetTexture("Interface\\AddOns\\ABreathBeneath\\Textures\\Minimap_skull_normal.blp");
	--self.eliteicon:SetTexture(nil);

	--self.castbarfill:SetTexture(nil);
	--self.castborder:SetTexture(nil);
	--self.shield:SetTexture(nil);
	--self.spellicon:SetTexture(nil);

	self.healthbarfill:Hide();
end


local function setPosition(currentHP, maxHP)
	local x = currentHP*138/maxHP;

	return (138-x)/2;
end


local function retextureNameplates()
	local worldFrames = { WorldFrame:GetChildren() };

	for _, frame in pairs(worldFrames) do
		
		if not nameplateCache[frame] and isNamePlateFrame(frame) then --(strfind(frame:GetName() or "", "NamePlate")) then
			local healthBar = frame:GetChildren();
			local _, _, name, level = frame:GetRegions();

			frame.healthbar = healthBar;
			frame.healthborder, frame.glow, frame.name, frame.level, frame.skull, frame.raidicons = frame:GetRegions();
			frame.healthbarfill = healthBar:GetRegions();


			--VANILLA
			--local HealthBar = frame:GetChildren()
			--local Border, Glow, Name, Level, Boss, RaidTargetIcon = frame:GetRegions()
			
			
			--hide blizzard art
			hideBlizzArt(frame)
			--frame:HookScript("OnShow", hideBlizzArt);


			--name
			name:SetFont("Interface\\AddOns\\ABreathBeneath\\Futura-Condensed-Normal.TTF", 14, "OUTLINE");
			name:ClearAllPoints();
			name:SetPoint("CENTER", frame, "CENTER", 0, 10);


			--level
			level:SetFont("Interface\\AddOns\\ABreathBeneath\\Futura-Condensed-Normal.TTF", 12, "OUTLINE");
			level:ClearAllPoints();
			level:SetPoint("CENTER", frame, "RIGHT", 0, 8);


			--frame
			frame.border = CreateFrame("FRAME", nil, frame);
			SetSize(frame.border, 256, 40);
			frame.border:SetPoint("BOTTOM", frame, "BOTTOM", 0, -10);


			--frame texture border
			frame.border.texture = frame.border:CreateTexture();
			frame.border.texture:SetTexture("Interface\\AddOns\\ABreathBeneath\\Textures\\nameplateBorder.blp");
			frame.border.texture:SetAllPoints(frame.border);
			frame.border.texture:SetVertexColor(0.65, 0.65, 0.65);




			--life bar
			frame.hpBar = CreateFrame("StatusBar", nil, frame.border);
			SetSize(frame.hpBar, 138, 11);
			frame.hpBar:SetPoint("CENTER", 0, 0);
			frame.hpBar:SetMinMaxValues(healthBar:GetMinMaxValues());
			frame.hpBar:SetStatusBarTexture("Interface\\AddOns\\ABreathBeneath\\Textures\\texture.blp");

			local r,g,b = healthBar:GetStatusBarColor();
			frame.hpBar:SetStatusBarColor(r,g,b,0.9);

			healthBar:SetScript("OnValueChanged", function()
				local min, max = healthBar:GetMinMaxValues();
				local value = healthBar:GetValue();
				
				healthBar:GetParent().hpBar:SetMinMaxValues(min, max);
				healthBar:GetParent().hpBar:SetValue(value);
				healthBar:GetParent().hpBar:SetPoint("CENTER", setPosition(value, max), 0);
			end)
			
			
			frame:SetScript("OnUpdate", nil);
			frame:SetScript("OnHide", nil);
			frame:SetScript("OnEvent", nil);
			
			--OnShow nameplate hookscript
			frame:SetScript("OnShow", function()
				--frame:GetScript("OnShow")();
			
				local r,g,b,a = healthBar:GetStatusBarColor();
				this.hpBar:SetStatusBarColor(r,g,b, 0.9);
				this.level:SetPoint("CENTER", this, "RIGHT", 0, 8);
			end)

			--setting the frame in cache
			nameplateCache[frame] = true;
		end
	end
end



local GetTime = GetTime;

local numChidlren, elapsed = -1, 0;

local time = GetTime();
Addon:SetScript("OnUpdate", function()
	elapsed = GetTime()-time;
	if(elapsed > 0.25) then
		time = GetTime();
		if (WorldFrame:GetNumChildren() ~= numChidlren) then
			numChidlren = WorldFrame:GetNumChildren();
			retextureNameplates();
		end
	end
end);

Addon:SetScript("OnEvent", function(self, event, ...)
	retextureNameplates();
end);


Addon:RegisterEvent("PLAYER_ENTERING_WORLD");
