SLASH_GET_RAID_NAMES1 = "/gexport"
SLASH_GET_PROFESSION_SKILLS1 = "/pexport"


function SlashCmdList.GET_RAID_NAMES()
	local t = {}
	tinsert(t, ("{\"hahmot\":["))
	for i = 1, GetNumGuildMembers() do
		local name,rank,rankIndex,level,class = GetGuildRosterInfo(i);
		if level == 60 then
			if i == GetNumGuildMembers() then
				tinsert(t, ("{\"name\":\"".. name .. "\",\"rank\":\"" .. rank .. "\",\"rankIndex\":\"" .. rankIndex .. "\",\"level\":\"" .. level .. "\",\"class\":\"" .. class .. "\"}"))
			else
				tinsert(t, ("{\"name\":\"".. name .. "\",\"rank\":\"" .. rank .. "\",\"rankIndex\":\"" .. rankIndex .. "\",\"level\":\"" .. level .. "\",\"class\":\"" .. class .. "\"},"))
			end
		end
	end
	tinsert(t, ("]}"))
	KethoEditBox:Show(table.concat(t, "\n"))
end


function SlashCmdList.GET_PROFESSION_SKILLS()
	local t = {}
	local playerName = UnitName("player")
	tinsert(t,("{\"name\":\""..playerName.."\",\"recipes\":["))
	if GetTradeSkillLine() ~= 'UNKNOWN' then
		for i=1,GetNumTradeSkills() do
			local skill_name, skill_type = GetTradeSkillInfo(i)
			-- Skip the headers, only check real skills
			if skill_name ~= nil and skill_type ~= "header" then
				if i == GetNumTradeSkills() then
					tinsert(t, ("\"".. skill_name .."\""))
				else
					tinsert(t, ("\"".. skill_name .."\","))
				end
			end
		end
	elseif GetCraftSkillLine(1) ~= nil then
		for i=1, GetNumCrafts() do
			local craftName = GetCraftInfo(i)
			-- Skip the headers, only check real skills
			if craftName ~= nil then
				if i == GetNumCrafts() then
					tinsert(t, ("\"".. craftName .."\""))
				else
					tinsert(t, ("\"".. craftName .."\","))
				end
			end
		end
	end
	tinsert(t,("]}"))
	KethoEditBox:Show(table.concat(t, "\n"))
end

-- Rest is taken from google


KethoEditBox = {}

function KethoEditBox:Create()
	local f = CreateFrame("Frame", nil, UIParent, "DialogBoxFrame")
	self.Frame = f
	f:SetPoint("CENTER")
	f:SetSize(600, 500)

	f:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
		edgeSize = 16,
		insets = { left = 8, right = 6, top = 8, bottom = 8 },
	})
	f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue

	-- Movable
	f:SetMovable(true)
	f:SetClampedToScreen(true)
	f:SetScript("OnMouseDown", function(frame, button)
		if button == "LeftButton" then
			frame:StartMoving()
		end
	end)
	f:SetScript("OnMouseUp", f.StopMovingOrSizing)

	-- ScrollFrame
	local sf = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
	sf:SetPoint("LEFT", 16, 0)
	sf:SetPoint("RIGHT", -32, 0)
	sf:SetPoint("TOP", 0, -16)
	sf:SetPoint("BOTTOM", f, "BOTTOM", 0, 50)

	-- EditBox
	local eb = CreateFrame("EditBox", nil, sf)
	self.EditBox = eb
	eb:SetSize(sf:GetSize())
	eb:SetMultiLine(true)
	eb:SetAutoFocus(false) -- dont automatically focus
	eb:SetFontObject("ChatFontNormal")
	eb:SetScript("OnEscapePressed", eb.ClearFocus)
	sf:SetScrollChild(eb)

	-- Resizable
	f:SetResizable(true)
	f:SetMinResize(150, 100)
	local rb = CreateFrame("Button", nil, f)
	rb:SetPoint("BOTTOMRIGHT", -6, 7)
	rb:SetSize(16, 16)
	rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

	rb:SetScript("OnMouseDown", function(frame, button)
		if button == "LeftButton" then
			f:StartSizing("BOTTOMRIGHT")
			frame:GetHighlightTexture():Hide() -- more noticeable
		end
	end)
	rb:SetScript("OnMouseUp", function(frame)
		f:StopMovingOrSizing()
		frame:GetHighlightTexture():Show()
		eb:SetWidth(sf:GetWidth())
	end)
end

function KethoEditBox:Show(text)
	if not self.EditBox then
		self:Create()
	end
	self.EditBox:SetText(text)
	self.Frame:Show()
end

