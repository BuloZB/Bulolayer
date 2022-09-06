local blacklist = {}
local readyForInvite = false;
local outgoingInvite = nil;

function BulolayerEvent(self, event, arg1, arg2, arg3, arg4, ...)
  if(event == "ADDON_LOADED" and Bulolayer_MessageBox == nil) then
    Bulolayer_CreateOptions();
    Bulolayer_AddonLoadedOptions();
    return;
  end
  if(event == "CHAT_MSG_ADDON") then
    arg4, _ = strsplit("-", arg4);
    if(arg1 == "Bulolayer") then
      if(arg3 == "WHISPER") then
        blacklist[arg4] = tonumber(arg2) + GetTime();
        return;
      end
      Bulolayer_HandleRequest(arg4, false)
      return;
    else
      return
    end
  end
  if(event == "CHAT_MSG_CHANNEL") then
    if(strfind(arg4, Bulolayer.channel) and strlower(arg1) == strlower(Bulolayer.message)) then
      arg2, _ = strsplit("-", arg2);
      Bulolayer_HandleRequest(arg2, false);
    end
  elseif(event == "CHAT_MSG_WHISPER") then
      if(strlower(arg1) == strlower(Bulolayer.message)) then
        arg2, _ = strsplit("-", arg2);
        Bulolayer_HandleRequest(arg2, true);
      end
  else
    Bulolayer_PartyEvent(event, arg1);
  end
end

function Bulolayer_HandleRequest(unitName, whisper)
    if(unitName == UnitName("player") and not IsInGroup()) then
      readyForInvite = true;
    elseif(Bulolayer_PlayerCanInvite() and Bulolayer_GroupThresholdMet() and (Bulolayer_BlacklistTest(unitName) or whisper)) then
      InviteUnit(unitName);
      outgoingInvite = unitName;
      return;
    end
end

function Bulolayer_PartyEvent(event, name)
  if(event == "PARTY_INVITE_REQUEST") then
    name, _ = strsplit("-", name);
    Bulolayer_AcceptInvite(name);
  else
    Bulolayer_HandleBlacklist();
  end
end

function Bulolayer_BlacklistTest(name)
  if(blacklist[name] == nil or blacklist[name] <= GetTime()) then
    return true
  end
  return false
end

function Bulolayer_PlayerCanInvite()
  return ((IsInGroup() and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player"))) or not IsInGroup());
end

function Bulolayer_GroupThresholdMet()
  local members = GetNumGroupMembers();
  return (IsInRaid() and members < 40 and true and Bulolayer.inviteInRaid) or (IsInGroup() and members < Bulolayer.inviteThreshold)
    or (not IsInGroup() and Bulolayer.inviteThreshold ~= 0)
end

function Bulolayer_AcceptInvite(name)
  if(readyForInvite) then
    if(blacklist[name] ~= nil and blacklist[name] > GetTime()) then
      DeclineGroup();
      local payload = blacklist[name] - GetTime();
      C_ChatInfo.SendAddonMessage("Bulolayer", payload, "WHISPER", name);
      StaticPopup_Hide("PARTY_INVITE");
      return
    end
    AcceptGroup();
    StaticPopup_Hide("PARTY_INVITE");
    blacklist[name] = (GetTime() + Bulolayer.delay);
    readyForInvite = false;
  end
end

function Bulolayer_HandleBlacklist()
  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      if(UnitName("raid" .. i) ~= nil) then
        blacklist[UnitName("raid" .. i)] = (GetTime() + Bulolayer.delay);
      end
    end
  elseif IsInGroup() then
    for i = 1, GetNumGroupMembers() do
      if(UnitName("party" .. i) ~= nil) then
        blacklist[UnitName("party" .. i)] = (GetTime() + Bulolayer.delay);
      end
    end
  end
end

function TargetIsInvited(name)
  return name == outgoingInvite
end

function Bulolayer_FindGroup()
  if(Bulolayer.guild) then
    C_ChatInfo.SendAddonMessage("Bulolayer", "I" , "GUILD")
  end
  if(Bulolayer.channel ~= nil) then
    for i=1,15 do
      local id, name = GetChannelName(i);
      if(name ~= nil and string.lower(name) == string.lower(Bulolayer.channel)) then
        SendChatMessage(Bulolayer.message, "CHANNEL", nil, id);
      end
    end
  end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", BulolayerEvent);
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PARTY_INVITE_REQUEST")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("CHAT_MSG_CHANNEL")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("ADDON_LOADED")
C_ChatInfo.RegisterAddonMessagePrefix("Bulolayer");
SLASH_Bulolayer1 = "/l"
SLASH_Bulolayer2 = "/layer"
SlashCmdList["Bulolayer"] = Bulolayer_FindGroup;


