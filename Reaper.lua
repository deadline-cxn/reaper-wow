--[[
Filename: Reaper.lua
Author  : Smashed - Bladefist

TODO:

- Add Spell Link frame

]]--
RFCC="|cffff2020";
WFCC="|cffffffff";
NFCC="|cffffd200";
DFCC="|cff888888";
GFCC="|cff00ff00";
BFCC="|cff0000ff";
YFCC="|cffffff00";
OFCC="|cffff9900";
if(strlower==nil) then strlower=string.lower; end
------------------------------------
function round(what, precision)
   return math.floor(what*math.pow(10,precision)+0.5) / math.pow(10,precision)
end
------------------------------------
function RPrint(a)
    if(DEFAULT_CHAT_FRAME==nil) then
        print(a);
    else
        DEFAULT_CHAT_FRAME:AddMessage(a);
    end
end
------------------------------------
function RInform(a)
    RPrint(RFCC.."REAPER >> "..YFCC..a);
end
------------------------------------
function RTell(player,msg)
    RMsg(player,msg,"WHISPER");
end
------------------------------------
function RMsg(player,msg,where)
    if(SendChatMessage==nil) then
        print("SendChatMessage("..msg..", "..where..", (LANGUAGE), "..player);
    else
        SendChatMessage(msg, where, GetDefaultLanguage("player"), player);
    end
end
------------------------------------[SPell Link Function]
function RP_GetSpellLink(izi)
    if(GetSpellLink==nil) then
        return ("SPELL LINK: ["..izi.."]");
    else
        return GetSpellLink(izi);
    end
end
------------------------------------[OnLoad          ]
function Reaper_OnLoad(self)

    Reaper_Version = "v"..GetAddOnMetadata("Reaper", "Version");
    ReapMsg      = "[REAPER]"..Reaper_Version..": ";
    ReapColorMsg = RFCC.."[REAPER]"..Reaper_Version..": "..YFCC;

    -- Register Slash Commands
    SLASH_Reaper1 = "/reaper";
    SLASH_Reaper2 = "/rp";
    SlashCmdList["Reaper"] = function(msg) Reaper_CommandHandler(msg); end
    -- Register for Events
    self:RegisterEvent("VARIABLES_LOADED");
    self:RegisterEvent("TRADE_SKILL_SHOW");
    self:RegisterEvent("CRAFT_SHOW");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED");
    self:RegisterEvent("PET_ATTACK_START");
    self:RegisterEvent("PET_ATTACK_STOP");
    self:RegisterEvent("UNIT_HAPPINESS");
    self:RegisterEvent("CHAT_MSG_SYSTEM");
    self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN");
    self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
    self:RegisterEvent("CHAT_MSG_COMBAT");
    self:RegisterEvent("DUEL_FINISHED");
    self:RegisterEvent("DUEL_REQUESTED");
    self:RegisterEvent("PLAYER_LEAVE_COMBAT");
    self:RegisterEvent("PLAYER_LEVEL_UP");
    self:RegisterEvent("PLAYER_LOGOUT");
    self:RegisterEvent("UI_INFO_MESSAGE");
    self:RegisterEvent("CHAT_MSG");
    self:RegisterEvent("CHAT_MSG_WHISPER");
    self:RegisterEvent("CHAT_MSG_GUILD");
    self:RegisterEvent("CHAT_MSG_PARTY");
    self:RegisterEvent("CHAT_MSG_PARTY_LEADER");

    self:RegisterEvent("CHAT_MSG_COMBAT_MISC_INFO");
    self:RegisterEvent("PLAYER_DEAD");
    self:RegisterEvent("CHAT_MSG_COMBAT_LOG_ERROR");
    self:RegisterEvent("PLAYER_ENTER_COMBAT");
    self:RegisterEvent("PLAYER_LEAVE_COMBAT");

    self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS");
    self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES");
    self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS");
    self:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES");
    self:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS");
    self:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES");
    self:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE");
    self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
    -- self:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE");

	self:RegisterEvent("LF_GUILD_BROWSE_UPDATED");
	self:RegisterEvent("LF_GUILD_MEMBERSHIP_LIST_CHANGED");
	self:RegisterEvent("LF_GUILD_MEMBERSHIP_LIST_UPDATED");
	self:RegisterEvent("LF_GUILD_POST_UPDATED");
	self:RegisterEvent("LF_GUILD_RECRUITS_UPDATED");
	self:RegisterEvent("LF_GUILD_RECRUIT_LIST_CHANGED");

end
------------------------------------[Events          ]
function Reaper_OnEvent(self, event, ...)
    local arg1, arg2 = ...;
    narg=nil; narg={};
    if(arg1~=nil) then
        numarg=0;
        for word in string.gmatch(arg1, "%w+") do
            narg[numarg]=strlower(word);
            if(narg[numarg]=="") then narg[numarg]=nil; numarg=numarg-1; end
            numarg=numarg+1;
        end
    end


------------------------------------[Save Variables  ]
    if(event=="VARIABLES_LOADED") then

        if( not ReaperProfile ) then ReaperProfile={}; end
	    if( not ReaperProfile[GetRealmName()] ) then ReaperProfile[GetRealmName()]={}; end
	    if( not ReaperProfile[GetRealmName()][UnitName("player")] ) then ReaperProfile[GetRealmName()][UnitName("player")]={}; end
    	if( not rpdb ) then rpdb = ReaperProfile[GetRealmName()][UnitName("player")]; end
	    if(rpdb) then

	        if(rpdb.debugreaper==nil) then rpdb.debugreaper = false; end

            rpdb["Version"]	= Reaper_Version;
            rpdb["Name"]		= UnitName("player");
            rpdb["Server"]	= GetRealmName();
            rpdb["Locale"]	= GetLocale();
            rpdb["Race"],
            rpdb["RaceEn"]    =UnitRace("player")
            rpdb["Class"],
            rpdb["ClassEn"]   =UnitClass("player");
            rpdb["FactionEn"],
            rpdb["Faction"]   =UnitFactionGroup("player");
            rpdb.Enabled      = true;
            rpdb.Equipment    = true;
            rpdb.Items        = true;

            rpxpmsg=1;
            rpxpsession=0;

            RPrint("REAPER by Smashed (Bladefist - Alliance) loaded. For help type /rp help");
            Reaper_Options_DisplayFrame_TitleText:SetText("Reaper "..Reaper_Version.." Smashed@Bladefist");
            Reaper_Options_DisplayFrame_Ding:SetChecked(rpdb.Ding);
            Reaper_Options_DisplayFrame_PxP:SetChecked(rpdb.PxP);
            Reaper_Options_DisplayFrame_AutoFollow:SetChecked(rpdb.AutoFollow);
            ReaperMinimapButton:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", (rpdb.MMX or 512), (rpdb.MMY or 384));

            guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
            if(guildName~=nil) then

                Reaper_Options_DisplayFrame_CheckGuildMOTD:SetChecked(rpdb.GuildMOTD);
                if(rpdb.GuildMOTD==0) then
                    message(GFCC.."Guild message of the day:\n"..GetGuildRosterMOTD());
                end

                Reaper_Options_DisplayFrame_CheckGuildMOTDGuildChat:SetChecked(rpdb.GuildMOTDGuildChat);
                if(rpdb.GuildMOTDGuildChat==0) then
                    RMsg(UnitName("player"),"Guild Message of the day >> "..GetGuildRosterMOTD(),"GUILD");
                end
            end
		end
		local zwat=0;
        if(ReaperSpellLink==nil) then
            ReaperSpellLink = {};
            for izi = 1,99999 do
                ReaperSpellLink[izi]=RP_GetSpellLink(izi);
                if(ReaperSpellLink[izi]~=nil) then zwat=zwat+1; end
            end
        end
        Reaper_SpellListFrameSF.RealResultsSize=zwat;-- Reaper_SpellLinkGetNumItems();
		Reaper_CreateSpellListButtons();


		if(rpdb.Mature==nil) then rpdb.Mature=1; end
		if(rpdb.Mature==true) then rpdb.Mature=1; end

		if(rpdb.Mature==1) then
			RInform("Setting mature language filter off");
			BNSetMatureLanguageFilter(false);
		end

    end


-- GetNumLootItems()
-- ConfirmLootSlot(1)



------------------------------------------------------



    if   ( event == "LF_GUILD_BROWSE_UPDATED"  ) then
		RInform("LF_GUILD_BROWSE_UPDATED");




	end


    if   ( event == "LF_GUILD_MEMBERSHIP_LIST_CHANGED") then

		RInform("LF_GUILD_MEMBERSHIP_LIST_CHANGED");


	end

    if   ( event == "LF_GUILD_MEMBERSHIP_LIST_UPDATED") then

		RInform("LF_GUILD_MEMBERSHIP_LIST_UPDATED");

	end


	if	( event == "LF_GUILD_POST_UPDATED") then

		RInform("LF_GUILD_POST_UPDATED");


	end

	if   ( event == "LF_GUILD_RECRUITS_UPDATED") then
		--RInform("LF_GUILD_RECRUITS_UPDATED");

		x=GetNumGuildApplicants();
		local name = GetGuildApplicantInfo(x);
		RInform("LF_GUILD_RECRUITS_UPDATED Number of applicants: "..x.." Name: ["..name.."]");

		-- PlaySoundFile("Interface\\AddOns\\reaper\\sounds\\TEST.MP3","MASTER");


		--[[for index = 1, x do--
			local name = GetGuildApplicantInfo(index);
				-- GuildInvite(name);

				-- RInform("Applicant: "..name);
		end ]]--



	end


    if   ( event == "LF_GUILD_RECRUIT_LIST_CHANGED" ) then

		if (rpdb.NumGuildApps==nil) then
			rpdb.NumGuildApps=0;
		end


		x=GetNumGuildApplicants();

		local name =GetGuildApplicantInfo(x);
		RInform("LF_GUILD_RECRUIT_LIST_CHANGED Number of applicants: "..x.." Name: ["..name.."]");
		-- GuildInvite(name);
		PlaySoundFile("Interface\\AddOns\\reaper\\sounds\\TEST.MP3","MASTER");

		rpdb.NumGuildApps=x;
	end




------------------------------------------------------

	if(event=="PLAYER_LOGOUT") then
		rpdb.MMX, rpdb.MMY = ReaperMinimapButton:GetCenter();
	end

----------------------------------------------

    if (event == "TRADE_SKILL_SHOW") then

    end

----------------------------------------------

    if (event == "CRAFT_SHOW") then

    end

----------------------------------------------

    if (event == "UNIT_INVENTORY_CHANGED") then

    end

----------------------------------------------

    if(event=="CHAT_MSG_SYSTEM") then



--		RInform("Hi a CHAT_MSG_SYSTEM event! ["..arg1.."]");

        if(string.find(arg1, string.gsub(INSTANCE_RESET_SUCCESS, "%%s", ""))) then
            if(UnitInRaid("player")) then
                RMsg(UnitName("player"),arg1,"RAID");
            else
                if(UnitInParty("player")) then
                    RMsg(UnitName("player"),arg1,"PARTY")
                end
            end
        end

--[[
		local wuname,wulvl;


		for wuname, wulvl in string.gmatch(arg1, "\[(.+)\]: Level (%d+) (.+)") do
			-- wuname=string.sub(wuname,,string.len(wuname)-1);
			if(wuname~=nil) then
				RInform("User is online: ("..wuname..") Level["..wulvl.."]" );
			end
		end
]]

    end

----------------------------------------------

    if (event=="CHAT_MSG_COMBAT_FACTION_CHANGE") then

    end

----------------------------------------------

    if (event=="CHAT_MSG_COMBAT_XP_GAIN") then
        local mode, submode = GetLFGMode();
        if (mode==nil) then -- player is not in dungeon finder group
            if(rpdb.PxP==1) then
                if(event=="CHAT_MSG_COMBAT_XP_GAIN") then
                    for creatureName, xp in string.gmatch(arg1, "(.+) dies, you gain (%d+) experience.") do
                        if(creatureName~=nil) then

                            RMsg(UnitName("player"),creatureName.." yields "..xp.." XP ","PARTY");

                            rpxpsession = rpxpsession+xp;

                            rpxpmsg = rpxpmsg+1;

                            if(rpxpmsg > 1) then
                                rpxpmsg=1;

                                rpxppct=UnitXP("player")/UnitXPMax("player")*100;

                                rpxppcts=strsplit(".",rpxppct); rpxppctf=rpxppcts[0];

                                RMsg(UnitName("player")," ("..UnitXP("player").."/"..UnitXPMax("player")..") Total session XP:"..rpxpsession,"PARTY");
                            end
                        end
                    end
                end
            end
        end
    end

--[[

mode,submode = GetLFGMode()
Returns:

mode - Current LFG status (string)

abandonedInDungeon - The party disbanded and player is still in the dungeon.
lfgparty - LFG dungeon is in-progress.
nil - Player is not in LFG
proposal - LFG party formed, notifying matched players dungeon is ready.
queued - Player is in LFG queue.
rolecheck - Querying groupmates to select their LFG roles before queuing.
submode - Your LFG sub-status. Used to indicate priority for filling party slots. (string)

empowered - Indicates that your party has lost a player and is set to higher priority for finding a replacement
nil - Not looking for more party members
unempowered - Default priority in the LFG system.

]]--

----------------------------------------------

    if(event=="PLAYER_LEVEL_UP") then
        if(rpdb.Ding==1) then
			msg="Ding! Level "..arg1;
			RMsg(UnitName("player"),msg,"GUILD");
        end
    end

----------------------------------------------

	if(	event == "CHAT_MSG_COMBAT_SELF_HITS" or
		event == "CHAT_MSG_COMBAT_SELF_MISSES" or
		event == "CHAT_MSG_SPELL_SELF_DAMAGE" or
		event == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE" or
		event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"
		) then

        --RPrint("HIT!");
	end

----------------------------------------------

    if   ( event == "CHAT_MSG_WHISPER"  )
    or   ( event == "CHAT_MSG_GUILD"    )
    or   ( event == "CHAT_MSG_PARTY"    )
    or   ( event == "CHAT_MSG_PARTY_LEADER" ) then

        if(event=="CHAT_MSG_GUILD") then where="GUILD"; end
        if(event=="CHAT_MSG_WHISPER") then where="WHISPER"; end
        if(event=="CHAT_MSG_PARTY") then where="PARTY"; end
        if(event=="CHAT_MSG_PARTY_LEADER") then where="PARTY"; end

    ---------------------  follow

        if(narg[0]=="follow") then
            if( rpdb.AutoFollow == 1) then
                FollowUnit(arg2);
            end
        end

        --[[

        canInteract = CheckInteractDistance("unit", distIndex)
            Arguments:

            unit - A unit to query (string, unitID)
            distIndex - Number identifying one of the following action types (number)
            1 - Inspect
            2 - Trade
            3 - Duel
            4 - Follow
            Returns:

            canInteract - 1 if the player is close enough to the other unit to perform the action; otherwise nil (1nil)

        ]]--

    --------------------- pxp gains

        if(narg[0]=="pxp") then
            if(event == "CHAT_MSG_PARTY") then
                if(narg[1]=="off") then
                    rpdb.PxP=0;
                    RMsg(UnitName("player"),"(Reaper) Party XP gains turned off","PARTY");
                end
                if(narg[1]=="on") then
                    rpdb.PxP=1;
                    RMsg(UnitName("player"),"(Reaper) Party XP gains turned on","PARTY");
                end
                Reaper_Options_DisplayFrame_PxP:SetChecked(rpdb.PxP);
            end
        end

----------------------------------------------

    end
end
------------------------------------[REAPER HELP     ]
function Reaper_ShowHelp(msg)
    RPrint("REAPER by Smashed @ Bladefist / US --- Help:");
    RPrint("/rp show.............displays interface");
    RPrint("/rp hide.............hides interface");
    RPrint("/rp minishow.........displays minimap button");
    RPrint("/rp minihide.........hides minimap button");
    RPrint("/rp <on|off>.........turn all replies on or off");
    RPrint("/rp rs...............restack items in backpacks");
    RPrint("/rp spell <keyword>..Find a spell link");
    RPrint("------------------------------------------------------------------------");
end
------------------------------------[Handle functions]
function Reaper_CommandHandler(msg)
    cmd=msg;

    for mesg,arg2 in string.gmatch(msg, "(.+) (.+)") do
        msg=mesg;
        arg1=arg2;
    end
    narg=nil; narg={};
    if(msg~=nil) then
        numarg=0;
        for word in string.gmatch(cmd, "%w+") do
            narg[numarg]=word;
            if(narg[numarg]=="") then narg[numarg]=nil; numarg=numarg-1; end
			if(rpdb.debugreaper==true) then RPrint(numarg.." ["..narg[numarg].."]"); end
            numarg=numarg+1;
        end
    end

--------------------------------------------------------------------------------

    -- Print Help
    if ( msg == "help" ) or ( msg == "" ) or ( msg == "?" ) then
        Reaper_ShowHelp();
        return;
    end

--------------------------------------------------------------------------------

    if (narg[0]=="spell") then

        for iji=0,(numarg-1) do
            RPrint(" ARG["..iji.."] = ["..narg[iji].."]");
        end

        if(narg[1]~=nil) then
            RInform("Spell Link Search: "..narg[1]);
            for izi=1,100000 do
                wsp=ReaperSpellLink[izi];
                if(wsp~=nil) then
                    if(string.find(strlower(wsp),strlower(narg[1]))) then
                        RInform("["..izi.."] "..wsp);
                    end
                end
            end
        end
    end

--------------------------------------------------------------------------------

    if(cmd=="topcrit") then
        RPrint(rpdb.TopCrit);
    end

--------------------------------------------------------------------------------

    if(cmd=="debug") then
        for tsname,tstable in pairs(MerchantFrame) do
            RPrint(tsname);
        end
            RPrint(MerchantFrame.selectedTab);
    end

--------------------------------------------------------------------------------

    if(cmd=="dbf") then
        local curframe=GetMouseFocus():GetName();
        RPrint(curframe);
    end

--------------------------------------------------------------------------------

    if(cmd=="fish") then
        FISHFORK=0;
        local spell, _, _, _, _, endTime = UnitChannelInfo("player")
            if spell then
            -- local finish = endTime/1000 - GetTime()
            RPrint(spell);
            if(spell=="Fishing") then FISHFORK=1; end
        end
        if(FISHFORK==0) then PlaySound("RaidWarning"); end
    end

--------------------------------------------------------------------------------

	-- Restack inventory items
	if ( msg == "rs" )
	then
		Reaper_Restack();
		RPrint("restacked your items.");
		return;
	end
--------------------------------------------------------------------------------

end
------------------------------------
function Reaper_GetLink(item)
    if(item==nil) then return nil; end
	for io,iw,ix in string.gmatch(item,"(.+)item:(.+):(.+)") do link="item:"..iw..":0"; end;
	return link;
end
------------------------------------
function Reaper_Restack()
    local bag=0;
    local ibag=0;
    local slot=0;
	local islot=0;
	local ammo=9;
	local tbag=0;
	local tslot=0;

	for bag = 0,4
	do
        if(GetBagName(bag)~=nil) then
		    if(string.find(GetBagName(bag),"ammo")~=nil) then ammo=bag; end
		    if(string.find(GetBagName(bag),"Ammo")~=nil) then ammo=bag; end
		    if(string.find(GetBagName(bag),"quiver")~=nil) then ammo=bag; end
		    if(string.find(GetBagName(bag),"Quiver")~=nil) then ammo=bag; end
        end
	end

	for bag = 0,4
	do
		tbag=bag;
		for slot = 1,20
		do
			tslot=slot;
			if(ammo~=bag) then
				iHi=GetContainerItemLink(bag,slot);
				if(iHi==nil) then iHi="wot";
				else

					link=Reaper_GetLink(iHi);
                    if(link ~=nil) then

					    local itemName, itemLink, itemRarity, itemLevelReq, itemType, itemSubType, itemStackCount = GetItemInfo(link);
					    duh,count,d2,quality,read = GetContainerItemInfo(bag,slot);
					    if (count == itemStackCount) then

					    else
						    for ibag = 0,4
						    do
							    if(ammo~=ibag) then
								    for islot = 1,30
								    do
									    if(ibag==bag) and (islot==slot) then

									    else
										    if(GetContainerItemLink(ibag,islot)==iHi) then

                                                link=Reaper_GetLink(iHi);
                                                if(link ~= nil) then

                                                    local    itemName, itemLink, itemRarity, itemLevelReq, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(link);

											        duh,count,d2,quality,read = GetContainerItemInfo(ibag,islot);

											        if(count==itemStackCount) then

											        else
												        RPrint("Combined item "..itemName);
												        PickupContainerItem(bag,slot);

												        a_temporary_variable=3;
												        if(ibag==3) then a_temporary_variable=4; end
												        if(a_temporary_variable==ammo) then a_temporary_variable=ammo-1; end
												        Reaper_GoBag(a_temporary_variable);
												        jork=Reaper_GetSlot(iHi,a_temporary_variable);
												        if(jork~=nil) then
													        PickupContainerItem(a_temporary_variable,jork);
													        Reaper_GoBag(ibag);
												        end
                                                    end
											    end
										    end
									    end
								    end
							    end
						    end
					    end
                    end
				end
			end
		end
	end

	return false;
end
------------------------------------
function Reaper_GoBag(bag)
	if (bag==0) then PutItemInBackpack(); end
	if (bag==1) then PutItemInBag(20); end
	if (bag==2) then PutItemInBag(21); end
	if (bag==3) then PutItemInBag(22); end
	if (bag==4) then PutItemInBag(23); end
end
------------------------------------
function Reaper_GetSlot(itemZ,bag)
	for slot=1,20
	do
		iHi=GetContainerItemLink(bag,slot);
		if(iHi~=nil) then
			if(iHi==itemZ) then
				return slot;
			end
		end
	end
	return nil;
end
------------------------------------
function Reaper_GetEquippedItem(slot)
	RPrint(slot);
	slotId,what=GetInventorySlotInfo(slot);
	if(slotId~=nil) then return GetInventoryItemLink("player",slotId);
	end
end
------------------------------------


function Reaper_CreateSpellListButtons()
    local index=0;
    local createFrame = CreateFrame;
    local parent      = Reaper_SpellListFrameSF;
    local button      = createFrame("Button", "Reaper_SpellListFrameSF_ItemButton1", parent,  "Reaper_SpellListFrameSF_ItemButtonTemplate");
    button:SetID(1);
    button:SetPoint("TOPLEFT","Reaper_SpellListFrameSF","TOPLEFT",36,-75);
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp");

    for index = 2, 23 do
        --bsDPrint("BUTTON CREATION: "..index);
        button = createFrame( "Button", "Reaper_SpellListFrameSF_ItemButton"..index, parent, "Reaper_SpellListFrameSF_ItemButtonTemplate");
        button:SetID(index);
        button:SetPoint( "TOPLEFT", "Reaper_SpellListFrameSF_ItemButton"..(index-1), "BOTTOMLEFT", 0, 1);
        button:RegisterForClicks( "LeftButtonUp", "RightButtonUp");
    end
end

function Reaper_Populate_SpellListFrame()

    for index = 1,23 do
        local what=getglobal("Reaper_SpellListFrameSF_ItemButton"..index);
        if (what) then
            what:Hide();
        end
    end

	--RPrint("Spell List Pop");

	Reaper_SpellListFrame_TitleText:SetText("Spell Link List "..Reaper_SpellListFrameSF.RealResultsSize.." items");
	FauxScrollFrame_Update(Reaper_SpellListFrameSF,Reaper_SpellListFrameSF.RealResultsSize-1,22,16);
	--RPrint("Reaper_SpellListFrameSF.RealResultsSize ["..Reaper_SpellListFrameSF.RealResultsSize.."]");
	local offset = Reaper_SpellListFrameSF.offset;
	--RPrint("Reaper_SpellListFrameSF.offset="..offset);
    local index=1;
    local grof=0;

	for slid,astable in pairs (ReaperSpellLink) do
		if(grof<offset) then
			grof=grof+1;
		else
            --RPrint("Reaper_SpellListFrameSF_ItemButton"..index.." RESULT :"..bsaslitem);
			local zbutton=getglobal("Reaper_SpellListFrameSF_ItemButton"..index);
			if(zbutton~=nil) then

                zwhat=getglobal("Reaper_SpellListFrameSF_ItemButton"..index.."Text");
                zwhat:SetText(astable);

                zwhat=getglobal("Reaper_SpellListFrameSF_ItemButton"..index.."TxtId");
                zwhat:SetText(slid);

				zbutton:SetScript("OnClick", (function(self) Reaper_SpellLinkButtonPressed(slid); end));
				index=index+1;
				zbutton:Show();
            else
                -- RPrint("ERROR: zbutton==nil");
            end

		end
	end
end

function Reaper_SpellLinkGetNumItems()
	local numitems=0;
	for item,_ in pairs (ReaperSpellLink) do
		numitems=numitems+1;
	end
	return numitems;

end

function Reaper_SpellLinkButtonPressed(index)
    -- bsRemoveExcludeItem(index);
    -- bsEXLPopulate();
    RInform(ReaperSpellLink[index]);
    --RMsg(UnitName("player"),"REAPER TEST >>"..ReaperSpellLink[index],"GUILD");

end

--[[
function bsEXLEditBoxAdd()
    if(BSEXLFrameAddItemBox:GetText()~="") then
        db.AutoSell["Exclude"][BSEXLFrameAddItemBox:GetText()] = 1;
        bsInform("Added "..BSEXLFrameAddItemBox:GetText().." to exclude list");
        bsEXLPopulate();
        BSEXLFrameAddItemBox:SetText("");
        BSEXLFrameAddItemBox:ClearFocus();
    end
end
]]--


