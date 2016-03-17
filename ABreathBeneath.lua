local Addon = CreateFrame("FRAME");

local nameplateCache = {};
local WorldFrame = WorldFrame;
local pairs = pairs;
local strfind = string.find;



local function hideBlizzArt(self)
	self.healthbar:Hide();

	self.healthborder:Hide();
	self.glow:SetTexture(nil);
	self.skull:SetTexture("Interface\\AddOns\\ABreathBeneath\\Minimap_skull_normal.png");
	self.eliteicon:SetTexture(nil);

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
		if not nameplateCache[frame] and (strfind(frame:GetName() or "", "NamePlate")) then
		
			local healthBar, castBar = frame:GetChildren();
			local threat, _, _, name, level = frame:GetRegions();

			frame.healthbar = healthBar;
			frame.threat, frame.healthborder, frame.glow, frame.name, frame.level, frame.skull, frame.raidicons, frame.eliteicon = frame:GetRegions();
			--frame.castbarfill, frame.castborder, frame.shield, frame.spellicon = castBar:GetRegions();
			frame.healthbarfill = healthBar:GetRegions();


			--hide blizzard art
			hideBlizzArt(frame)
			--frame:HookScript("OnShow", hideBlizzArt);

			--nameplate sandbox
			--frame.t = frame:CreateTexture();
			--frame.t:SetTexture(1,1,1,0.5);
			--frame.t:SetAllPoints(frame);

			--name
			name:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 14, "OUTLINE");
			name:ClearAllPoints();
			name:SetPoint("CENTER", frame, "CENTER", 0, 10);


			--level
			level:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 12, "OUTLINE");
			level:ClearAllPoints();
			level:SetPoint("CENTER", frame, "RIGHT", 0, 8);


			--frame
			frame.border = CreateFrame("FRAME", nil, frame);
			frame.border:SetSize(256, 40);
			frame.border:SetPoint("BOTTOM", frame, "BOTTOM", 0, -10);


			--frame texture border
			frame.border.texture = frame.border:CreateTexture();
			frame.border.texture:SetTexture("Interface\\AddOns\\ABreathBeneath\\nameplateBorder.blp");
			frame.border.texture:SetAllPoints(frame.border);
			frame.border.texture:SetVertexColor(0.65, 0.65, 0.65);


			--threat
			threat:ClearAllPoints();
			threat:SetTexture("Interface\\AddOns\\ABreathBeneath\\nameplateThreat.blp");
			threat:SetTexCoord(0,1,0,1);		--it comes with texCoords, and SetTexture doesnt reset it
			threat:SetAllPoints(frame.border);


			--life bar
			frame.hpBar = CreateFrame("StatusBar", nil, frame.border);
			frame.hpBar:SetSize(138, 11);
			frame.hpBar:SetPoint("CENTER", 0, 0);
			frame.hpBar:SetMinMaxValues(healthBar:GetMinMaxValues());
			frame.hpBar:SetStatusBarTexture("Interface\\AddOns\\ABreathBeneath\\texture.blp");

			local r,g,b = healthBar:GetStatusBarColor();
			frame.hpBar:SetStatusBarColor(r,g,b,0.9);

			healthBar:SetScript("OnValueChanged", function(self, value)
				local min, max = self:GetMinMaxValues();
				frame.hpBar:SetMinMaxValues(min, max);
				frame.hpBar:SetValue(value);
				frame.hpBar:SetPoint("CENTER", setPosition(value, max), 0);
			end)
			
			
			--castingBar
			frame.castBar = CreateFrame("StatusBar", nil, frame.border);
			frame.castBar:SetSize(118, 9);
			frame.castBar:SetPoint("CENTER", 0, -15);
			frame.castBar:SetStatusBarTexture("Interface\\AddOns\\ABreathBeneath\\texture.blp");
			frame.castBar:SetStatusBarColor(1,1,0.2,0.9);

			frame.castBar.texture = frame.castBar:CreateTexture(nil, "BORDER")
			frame.castBar.texture:SetTexture("Interface\\AddOns\\ABreathBeneath\\nameplateBorder.blp");
			frame.castBar.texture:SetPoint("CENTER", frame.border, "CENTER", 0, -15);
			frame.castBar.texture:SetSize(220,30)
			frame.castBar.texture:SetVertexColor(0.65, 0.65, 0.65);
			
			frame.castBar.spellName = frame.castBar:CreateFontString();
			frame.castBar.spellName:SetFont("Interface\\AddOns\\Rising\\Futura-Condensed-Normal.TTF", 12, "OUTLINE");
			frame.castBar.spellName:SetPoint("CENTER");

			frame.castBar:Hide();

			castBar:SetScript("OnShow", function(self)
				frame.castBar:Show();
				frame.castBar:SetMinMaxValues(self:GetMinMaxValues())
				self:SetAlpha(0);
				local spell, _, spellName = UnitCastingInfo("target");
				frame.castBar.spellName:SetText(spellName);
			end)
			
			castBar:SetScript("OnHide", function(self)
				frame.castBar:Hide();
			end)
			
			castBar:SetScript("OnValueChanged", function(self, value)
				frame.castBar:SetValue(value);
			end)

			
			frame:SetScript("OnUpdate", nil);
			frame:SetScript("OnHide", nil);
			frame:SetScript("OnEvent", nil);
			
			--OnShow nameplate hookscript
			frame:HookScript("OnShow", function()
				local r,g,b,a = healthBar:GetStatusBarColor();
				frame.hpBar:SetStatusBarColor(r,g,b, 0.9);
				level:SetPoint("CENTER", frame, "RIGHT", 0, 8);
				threat:SetAllPoints(frame.border);
			end)

			--setting the frame in cache
			nameplateCache[frame] = true;
		end
	end
end




local numChidlren, total = -1, 0;
Addon:SetScript("OnUpdate", function(self, elapsed)
	total = total + elapsed;
	if(total > 0.25) then
		total = 0;
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
