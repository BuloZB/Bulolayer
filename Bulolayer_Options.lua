Bulolayer = {
  message = "layer",
  delay = 1800,
  channel = "layer",
  guild = true,
  whisper = true,
  inviteThreshold = 4,
  inviteInRaid = false,
}

function Bulolayer_AddonLoadedOptions()
  Bulolayer_MessageBox:SetText(Bulolayer.channel);
  Bulolayer_ChannelBox:SetText(Bulolayer.message);
  Bulolayer_DelayBox:SetText(Bulolayer.delay);
  Bulolayer_DelayBox:SetCursorPosition(0)
  Bulolayer_ChannelBox:SetCursorPosition(0)
  Bulolayer_MessageBox:SetCursorPosition(0)
  Bulolayer_GuildCheck:SetChecked(Bulolayer.guild);
  Bulolayer_WhisperCheck:SetChecked(Bulolayer.whisper);
  Bulolayer_RaidInvite:SetChecked(Bulolayer.inviteInRaid);
end

function Bulolayer_CreateOptions()
  local options = CreateFrame("Frame", "Bulolayer_Options")
  options.name = "Bulolayer"
  InterfaceOptions_AddCategory(options);
  Bulolayer_Options_CreateLabel(0, 0, "Bulolayer Config");
  Bulolayer_Options_CreateLabel(0, 40, "Invite Message")
  Bulolayer_Options_CreateEditbox(160, 40, false, "Bulolayer_MessageBox")
	Bulolayer_MessageBox:SetScript("OnTextChanged", function()
		if(Bulolayer_MessageBox:IsNumeric()) then
			Bulolayer.message = Bulolayer_MessageBox:GetNumber();
    else
      Bulolayer.message = Bulolayer_MessageBox:GetText();
		end
	end);

  Bulolayer_Options_CreateLabel(0, 80, "Invite Channel")
  Bulolayer_Options_CreateEditbox(160, 80, false, "Bulolayer_ChannelBox")
	Bulolayer_ChannelBox:SetScript("OnTextChanged", function()
		if(Bulolayer_ChannelBox:IsNumeric()) then
			Bulolayer.channel = Bulolayer_ChannelBox:GetNumber();
    else
      Bulolayer.channel = Bulolayer_ChannelBox:GetText();
		end
	end);

  Bulolayer_Options_CreateLabel(0, 120, "Invite Cooldown")
  Bulolayer_Options_CreateEditbox(160, 120, true, "Bulolayer_DelayBox")
	Bulolayer_DelayBox:SetScript("OnTextChanged", function()
		if(Bulolayer_DelayBox:IsNumeric()) then
			Bulolayer.delay = Bulolayer_DelayBox:GetNumber();
    else
      Bulolayer.delay = Bulolayer_DelayBox:GetText();
		end
	end);

  Bulolayer_Options_CreateCheckbutton(-5, 160, "Bulolayer_GuildCheck","Guild Chat Invite");
  Bulolayer_GuildCheck:SetScript("OnClick", function()
  			Bulolayer.guild = Bulolayer_GuildCheck:GetChecked();
		end);
  Bulolayer_Options_CreateCheckbutton(-5, 200, "Bulolayer_WhisperCheck","Whisper Invite");
  Bulolayer_WhisperCheck:SetScript("OnClick", function()
  			Bulolayer.whisper = Bulolayer_WhisperCheck:GetChecked();
		end);
  Bulolayer_Options_CreateCheckbutton(-5, 240, "Bulolayer_RaidInvite","Invite in Raid");
  Bulolayer_RaidInvite:SetScript("OnClick", function()
  			Bulolayer.inviteInRaid = Bulolayer_RaidInvite:GetChecked();
		end);

    Bulolayer_Options_CreateLabel(0, 280, "Invite Group Threshold");
    Bulolayer_Options_CreateThresholdMenu(180, 280)
end

function Bulolayer_Options_CreateLabel(xOffset, yOffset, text)
  local uiObject = Bulolayer_Options:CreateFontString(nil, "Overlay");
  uiObject:SetPoint("TOPLEFT", xOffset + 16, -yOffset - 16);
	uiObject:SetTextColor(1, 0.8, 0);
  uiObject:SetFont("Fonts\\FRIZQT__.TTF", 16);
  uiObject:SetText(text);
end

function Bulolayer_Options_CreateCheckbutton(xOffset, yOffset, name, text)
  local uiObject = CreateFrame("CheckButton", name, Bulolayer_Options, "ChatConfigCheckButtonTemplate");
  uiObject:SetPoint("TOPLEFT", xOffset + 16, -yOffset - 16);
  getglobal(name .. 'Text'):SetText(text);
end

function Bulolayer_Options_CreateThresholdMenu(xOffset, yOffset)
  local uiObject = CreateFrame("Frame", nil, Bulolayer_Options, "UIDropDownMenuTemplate");
  uiObject:SetPoint("TOPLEFT", xOffset + 16, -yOffset - 12);
  UIDropDownMenu_JustifyText(uiObject, "LEFT");
  UIDropDownMenu_Initialize(uiObject, MyDropDownMenu_OnLoad);
  UIDropDownMenu_SetWidth(uiObject, 60)
  UIDropDownMenu_SetText(uiObject, Bulolayer.inviteThreshold)
  UIDropDownMenu_Initialize(uiObject, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    for i = 0,4 do
     info.text = i
     info.func = self.SetValue
     info.checked = info.text == Bulolayer.inviteThreshold;
     if(info.checked) then
       UIDropDownMenu_SetText(uiObject, info.text)
     end
     info.arg1 = info.text;
     UIDropDownMenu_AddButton(info);
    end
  end)

  function uiObject:SetValue(newValue)
    Bulolayer.inviteThreshold = newValue
    UIDropDownMenu_SetText(uiObject, newValue)
    CloseDropDownMenus()
  end
end

function Bulolayer_Options_CreateEditbox(xOffset, yOffset, numeric, name, text)
  local uiObject = CreateFrame("EditBox", name, Bulolayer_Options, "InputBoxTemplate");
  uiObject:SetPoint("TOPLEFT", Bulolayer_Options, "TOPLEFT", xOffset, -yOffset + 13);
  uiObject:SetWidth(140);
  uiObject:SetHeight(80);
  uiObject:SetMaxLetters(25);
	uiObject:SetAutoFocus(false);
  if(numeric) then
	  uiObject:SetMaxLetters(4);
    uiObject:SetNumeric()
  end
	uiObject:SetScript("OnEnterPressed", function()
		uiObject:ClearFocus();
	end);
  return uiObject;
end
