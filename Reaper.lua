--[[
Filename: Reaper.lua
Author  : Smashed - Bladefist
]]--
RP_NUM_SPELLS=399999
------------------------------------------------------------------------
function rp_GetGameTime() local hour,minute=GetGameTime() return hour..":"..minute end
------------------------------------------------------------------------
function rp_SaveStuff() rpdb.MMX,rpdb.MMY=ReaperMinimapButton:GetCenter() end
------------------------------------------------------------------------
function RPrint(a) print(tostring(a)) DEFAULT_CHAT_FRAME:AddMessage(a) end
------------------------------------------------------------------------
function RDPrint(a)
  a=tostring(a)
  for i=0,10 do
	local name,fontSize,r,g,b,alpha,shown,locked,docked,uninteractable=GetChatWindowInfo(i)
	if(name~=nil) then
	  if(name=="Reaper") then
		if(rpdb) then
		  rpdb.rpChatFrame=getglobal("ChatFrame"..i)
		end
	  end
	end
  end
  if(rpdb) then
	if(rpdb.rpChatFrame==nil) then
	  rpdb.rpChatFrame=DEFAULT_CHAT_FRAME
	end
	if(rpdb.Debug==1) then
	  if(rpdb.rpChatFrame['AddMessage']~=nil) then
		rpdb.rpChatFrame:AddMessage(RFCC.."RPDEBUG>> "..YFCC..a)
	  else
		DEFAULT_CHAT_FRAME:AddMessage(RFCC.."RPDEBUG>> "..YFCC..a)
	  end
	end
  end
end
------------------------------------------------------------------------
function RInform(a) RPrint(RFCC..Reaper_Version..YFCC..tostring(a)) end
------------------------------------------------------------------------
function rp_RW(msg) if(IsInRaid("player")) then SendChatMessage(msg,"RAID_WARNING",GetDefaultLanguage("player"),UnitName("player")) else RInform(msg) end end
------------------------------------------------------------------------
function rp_RC(msg) if(IsInRaid("player")) then SendChatMessage(msg,"RAID",GetDefaultLanguage("player"),UnitName("player")) else RInform(msg) end end
------------------------------------------------------------------------
function rp_PC(msg) if(UnitInParty("player")) then SendChatMessage(msg,"PARTY",GetDefaultLanguage("player"),UnitName("player")) else RInform(msg) end end
------------------------------------------------------------------------
function rp_GC(msg) SendChatMessage(msg,"GUILD",GetDefaultLanguage("player"),UnitName("player")) end
------------------------------------------------------------------------
function RTell(player,msg) RMsg(player,msg,"WHISPER") end
------------------------------------------------------------------------
function RMsg(player,msg,where) SendChatMessage(msg,where,GetDefaultLanguage("player"),player) end
---------------------------------------------------[SPell Link Function]
function RP_GetSpellLink(izi) if(GetSpellLink==nil) then return ("SPELL LINK: ["..izi.."]") else return GetSpellLink(izi) end end
--------------------------------------------------------------[OnUpdate]
function Reaper_OnUpdate(self)
  if(rpdb.Engagement~="none") then
	local wboss=UnitName("boss1")
	if(wboss==nil) then
	  RInform(rpdb.Engagement.."combat ended"..rp_GetGameTime())
	  rpdb.Engagement="none"
	end
  end
end
----------------------------------------------------------------[OnLoad]
function Reaper_OnLoad(self)
  Reaper_Version="Reaper v"..GetAddOnMetadata("Reaper","Version")
  ReapMsg    ="[REAPER]"..Reaper_Version..": "
  ReapColorMsg=RFCC.."[REAPER]"..Reaper_Version..": "..YFCC
  SLASH_Reaper1="/reaper"
  SLASH_Reaper2="/rp"
  SlashCmdList["Reaper"]=function(msg) Reaper_CommandHandler(msg) end
  self:RegisterEvent("VARIABLES_LOADED")
  self:RegisterEvent("TRADE_SKILL_SHOW")
  self:RegisterEvent("CRAFT_SHOW")
  self:RegisterEvent("UNIT_INVENTORY_CHANGED")
  self:RegisterEvent("UNIT_HAPPINESS")
  self:RegisterEvent("CHAT_MSG_SYSTEM")
  self:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
  self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
  self:RegisterEvent("CHAT_MSG_COMBAT")
  self:RegisterEvent("DUEL_FINISHED")
  self:RegisterEvent("DUEL_REQUESTED")
  self:RegisterEvent("PLAYER_LEAVE_COMBAT")
  self:RegisterEvent("PLAYER_LEVEL_UP")
  self:RegisterEvent("PLAYER_LOGOUT")
  self:RegisterEvent("UI_INFO_MESSAGE")
  self:RegisterEvent("CHAT_MSG")
  self:RegisterEvent("CHAT_MSG_WHISPER")
  self:RegisterEvent("CHAT_MSG_GUILD")
  self:RegisterEvent("CHAT_MSG_PARTY")
  self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
  self:RegisterEvent("CHAT_MSG_COMBAT_MISC_INFO")
  self:RegisterEvent("PLAYER_DEAD")
  self:RegisterEvent("CHAT_MSG_COMBAT_LOG_ERROR")
  self:RegisterEvent("PLAYER_ENTER_COMBAT")
  self:RegisterEvent("PLAYER_LEAVE_COMBAT")
  self:RegisterEvent("COMBAT_LOG_EVENT")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:RegisterEvent("UNIT_TARGET")
  self:RegisterEvent("LF_GUILD_BROWSE_UPDATED")
  self:RegisterEvent("LF_GUILD_MEMBERSHIP_LIST_CHANGED")
  self:RegisterEvent("LF_GUILD_MEMBERSHIP_LIST_UPDATED")
  self:RegisterEvent("LF_GUILD_POST_UPDATED")
  self:RegisterEvent("LF_GUILD_RECRUITS_UPDATED")
  self:RegisterEvent("LF_GUILD_RECRUIT_LIST_CHANGED")
  self:RegisterEvent("ROLE_POLL_BEGIN")
  self:RegisterEvent("ROLE_CHANGED_INFORM")
end
------------------------------------------------------------------------[Events          ]
function Reaper_OnEvent(self,event,...)
  narg,numarg=sml_nargify(...)
  ------------------------------------------------------------------------[Save Variables  ]
  if(event=="VARIABLES_LOADED") then
	if(not ReaperProfile) then ReaperProfile={} end
	if(not ReaperProfile[GetRealmName()]) then ReaperProfile[GetRealmName()]={} end
	if(not ReaperProfile[GetRealmName()][UnitName("player")]) then ReaperProfile[GetRealmName()][UnitName("player")]={} end
	if(not rpdb) then rpdb=ReaperProfile[GetRealmName()][UnitName("player")] end
	if(rpdb) then
	  rpdb.Boss={}
	  rpdb.Boss["none"]=rp_BossNone
	  rpdb["combat_timer"]=GetTime()
	  rpdb["encounter"]="none"
	  if(rpdb.Debug==nil) then rpdb.Debug=false end
	  rpdb["Version"]	=Reaper_Version
	  rpdb["Name"]		=UnitName("player")
	  rpdb["Server"]	=GetRealmName()
	  rpdb["Locale"]	=GetLocale()
	  rpdb["Race"],
	  rpdb["RaceEn"]   =UnitRace("player")
	  rpdb["Class"],
	  rpdb["ClassEn"]  =UnitClass("player")
	  rpdb["FactionEn"],
	  rpdb["Faction"]  =UnitFactionGroup("player")
	  rpdb.Enabled    =true
	  rpdb.Equipment  =true
	  rpdb.Items      =true
	  RPrint(Reaper_Version.." by Smashed (Bladefist - Alliance) loaded. For help type /rp help")
	  Reaper_Options_DisplayFrame_TitleText:SetText("Reaper "..Reaper_Version.." Smashed@Bladefist")
	  Reaper_Options_DisplayFrame_Ding:SetChecked(rpdb.Ding)
	  Reaper_Options_DisplayFrame_PxP:SetChecked(rpdb.PxP)
	  Reaper_Options_DisplayFrame_AutoFollow:SetChecked(rpdb.AutoFollow)
	  Reaper_Options_DisplayFrame_CheckToggleMinimapIcon:SetChecked(rpdb.MinimapIcon)
	  if(rpdb.MinimapIcon) then
		ReaperMinimapButton:Show()
	  else
		ReaperMinimapButton:Hide()
	  end
	  ReaperMinimapButton:SetPoint("CENTER","UIParent","BOTTOMLEFT",(rpdb.MMX or 512),(rpdb.MMY or 384))
	  guildName,guildRankName,guildRankIndex=GetGuildInfo("player")
	  if(guildName~=nil) then
		Reaper_Options_DisplayFrame_CheckGuildMOTD:SetChecked(rpdb.GuildMOTD)
		if(rpdb.GuildMOTD==0) then
		  message(GFCC.."Guild message of the day:\n"..GetGuildRosterMOTD())
		end
		Reaper_Options_DisplayFrame_CheckGuildMOTDGuildChat:SetChecked(rpdb.GuildMOTDGuildChat)
		if(rpdb.GuildMOTDGuildChat==0) then
		  rp_GC("Guild Message of the day >> "..GetGuildRosterMOTD())
		end
	  end
	end
	local zwat=0
	if(ReaperSpellLink==nil) then
	  ReaperSpellLink={}
	  for izi=1,RP_NUM_SPELLS do
		ReaperSpellLink[izi]=RP_GetSpellLink(izi)
		if(ReaperSpellLink[izi]~=nil) then zwat=zwat+1 end
	  end
	end
	Reaper_SpellListFrameSF.RealResultsSize=zwat
	Reaper_CreateSpellListButtons()
	if(rpdb.Mature==nil) then rpdb.Mature=1 end
	if(rpdb.Mature==true) then rpdb.Mature=1 end
	if(rpdb.Mature==1) then
	  RInform("Setting mature language filter off")
	  BNSetMatureLanguageFilter(false)
	end
  end
  ----------------------------------------------------------------------------
  if(event=="COMBAT_LOG_EVENT" or
	event=="COMBAT_LOG_EVENT_UNFILTERED") then
  end
  ------------------------------------------------------------------------
  if(event=="LF_GUILD_BROWSE_UPDATED" ) then RDPrint("LF_GUILD_BROWSE_UPDATED") end
  if(event=="LF_GUILD_MEMBERSHIP_LIST_CHANGED") then RDPrint("LF_GUILD_MEMBERSHIP_LIST_CHANGED") end
  if(event=="LF_GUILD_MEMBERSHIP_LIST_UPDATED") then RDPrint("LF_GUILD_MEMBERSHIP_LIST_UPDATED") end
  if(event=="LF_GUILD_POST_UPDATED") then RDPrint("LF_GUILD_POST_UPDATED") end
  if(event=="LF_GUILD_RECRUITS_UPDATED") then
	local x=GetNumGuildApplicants()
	local name=GetGuildApplicantInfo(x)
	if name~=nil then RDPrint("LF_GUILD_RECRUITS_UPDATED Number of applicants: "..x.." Name: ["..name.."]") end
	--[[
	PlaySoundFile("Interface\\AddOns\\reaper\\sounds\\TEST.MP3","MASTER")
	for index=1,x do
	  local name=GetGuildApplicantInfo(index)
	  GuildInvite(name)
	  RInform("Applicant: "..name)
	end
	]]--
  end
  if(event=="LF_GUILD_RECRUIT_LIST_CHANGED") then
	local x=GetNumGuildApplicants()
	local Name,Level,Class,bQuest,bDungeon,bRaid,bPvP,bRP,bWeekdays,bTank,bHealer,bDamage,comment,timeSince,timeLeft=GetGuildApplicantInfo(x)
	if(name~=nil) then
	  local tanktxt=" Tank: No"
	  if(bTank==1) then tanktxt=" Tank: Yes" end
	  local healtxt=" Heal: No"
	  if(bHealer==1) then healtxt=" Heal: Yes" end
	  local dpstxt=" DPS: No"
	  if(bDamage==1) then dpstxt=" DPS: Yes" end
	  local raidtxt=" RAID: No"
	  if(bRaid==1) then raidtxt=" RAID: Yes" end
	  if(comment==nil) then comment=" (no comment entered)" end
	  rp_GC("REAPER "..Reaper_Version.." > New guild applicant ["..name.."] ("..Level.." "..Class..")"..tanktxt..healtxt..dpstxt..raid.txt.." Comment:"..comment)
	  -- GuildInvite(name)
	  -- PlaySoundFile("Interface\\AddOns\\reaper\\sounds\\TEST.MP3","MASTER")
	end
	-- rpdb.NumGuildApps=x
  end
  ------------------------------------------------------------------------
  if((event=="ROLE_POLL_BEGIN") or
	(event=="ROLE_CHANGED_INFORM")) then
	rp_ShowRaidInfo()
  end
  ------------------------------------------------------------------------
  if(event=="PLAYER_LOGOUT") then rp_SaveStuff() end
  ------------------------------------------------------------------------
  if(event=="TRADE_SKILL_SHOW") then end
  ------------------------------------------------------------------------
  if(event=="CRAFT_SHOW") then end
  ------------------------------------------------------------------------
  if(event=="UNIT_INVENTORY_CHANGED") then end
  ------------------------------------------------------------------------
  if(event=="CHAT_MSG_SYSTEM") then
	if(string.find(narg[0],string.gsub(INSTANCE_RESET_SUCCESS,"%%s",""))) then
	  if(UnitInRaid("player")) then
		rp_RC(narg[0])
	  else
		if(UnitInParty("player")) then
		  rp_PC(narg[0])
		end
	  end
	end
	--[[
	  local wuname,wulvl
	  for wuname,wulvl in string.gmatch(argz[0],"\[(.+)\]: Level (%d+) (.+)") do
		  wuname=string.sub(wuname,,string.len(wuname)-1)
		  if(wuname~=nil) then
			  RInform("User is online: ("..wuname..") Level["..wulvl.."]")
		  end
	  end
	]]
  end
  ------------------------------------------------------------------------
  if(event=="CHAT_MSG_COMBAT_FACTION_CHANGE") then
  end
  ------------------------------------------------------------------------

  if(event=="CHAT_MSG_COMBAT_XP_GAIN") then
	--[[
	  local mode,submode=GetLFGMode()
	  if(mode==nil) then -- player is not in dungeon finder group
		  if(rpdb.PxP==1) then
			  if(event=="CHAT_MSG_COMBAT_XP_GAIN") then
				  for creatureName,xp in string.gmatch(argz[0],"(.+) dies,you gain (%d+) experience.") do
					  if(creatureName~=nil) then
						  RMsg(UnitName("player"),creatureName.." yields "..xp.." XP ","PARTY")
						  rpxpsession=rpxpsession+xp
						  rpxpmsg=rpxpmsg+1
						  if(rpxpmsg > 1) then
							  rpxpmsg=1
							  rpxppct=UnitXP("player")/UnitXPMax("player")*100
							  rpxppcts=strsplit(".",rpxppct)
							  rpxppctf=rpxppcts[0]
							  RMsg(UnitName("player")," ("..UnitXP("player").."/"..UnitXPMax("player")..") Total session XP:"..rpxpsession,"PARTY")
						  end
					  end
				  end
			  end
		  end
	  end

	mode,submode=GetLFGMode()
    Returns
	mode - Current LFG status (string)
	abandonedInDungeon - The party disbanded and player is still in the dungeon.
		lfgparty - LFG dungeon is in-progress.
		nil - Player is not in LFG
		proposal - LFG party formed,notifying matched players dungeon is ready.
		queued - Player is in LFG queue.
		rolecheck - Querying groupmates to select their LFG roles before queuing.
		submode - Your LFG sub-status. Used to indicate priority for filling party slots. (string)

		empowered - Indicates that your party has lost a player and is set to higher priority for finding a replacement
		nil - Not looking for more party members
		unempowered - Default priority in the LFG system.


	]]--
  end
  ------------------------------------------------------------------------
  if(event=="PLAYER_LEVEL_UP") then
	if(rpdb.Ding==nil) then rpdb.Ding=0 end
	if(rpdb.Ding==1) then msg="Ding! Level "..narg[0] rp_GC(msg) end
  end
  ------------------------------------------------------------------------
  if(event=="UNIT_TARGET") then
  end
  ------------------------------------------------------------------------
  if(event=="CHAT_MSG_WHISPER") then
	where="WHISPER"
	if(narg[0]=="follow") then
	  if(rpdb.AutoFollow==1) then
		FollowUnit(narg[1])
		--local canfollow=CheckInteractDistance(arg2,4)
		--[[

		canInteract=CheckInteractDistance("unit",distIndex) Arguments:
				unit - A unit to query (string,unitID)
				distIndex - Number identifying one of the following action types (number)
					1 - Inspect
					2 - Trade
					3 - Duel
					4 - Follow
		Returns: canInteract - 1 if the player is close enough to the other unit to perform the action
		otherwise nil (nil)

		]]--

		--if(canfollow==1) then
		--else 	RMsg(UnitName("player"),"(Reaper) Can not follow you are too far away. ")
		-- end

	  end
	end
  end
  ------------------------------------------------------------------------
  if(event=="CHAT_MSG_GUILD") then
    where="GUILD"
  end
  if((event=="CHAT_MSG_PARTY") or
	(event=="CHAT_MSG_PARTY_LEADER")) then
	where="PARTY"
	if(narg[0]=="pxp") then
	  if(event=="CHAT_MSG_PARTY") then
		if(narg[1]=="off") then
		  rpdb.PxP=0
		  RMsg(UnitName("player"),"(Reaper) Party XP gains turned off","PARTY")
		end
		if(narg[1]=="on") then
		  rpdb.PxP=1
		  RMsg(UnitName("player"),"(Reaper) Party XP gains turned on","PARTY")
		end
		Reaper_Options_DisplayFrame_PxP:SetChecked(rpdb.PxP)
	  end
	end
  end
end
----------------------------------------------------------[REAPER HELP]
function Reaper_ShowHelp(msg)
  RPrint("REAPER by Smashed @ Bladefist / US --- Help:")
  RPrint("/rp show.............displays interface")
  RPrint("/rp hide.............hides interface")
  RPrint("/rp minishow.........displays minimap button")
  RPrint("/rp minihide.........hides minimap button")
  RPrint("/rp <on|off>.........turn all replies on or off")
  RPrint("/rp rs...............restack items in backpacks")
  RPrint("/rp spell <keywords>..Find a spell link")
  RPrint("------------------------------------------------------------------------")
end
------------------------------------------------------------------------
function rp_cd(x)
  local y=0
  for i=1,120 do
	local start,duration,enable=GetActionCooldown(i)
	if start > 0 and enable==1 then
	  local actiontype,id,subtype=GetActionInfo(i)
	  local name
	  if actiontype=="spell" then
		name=GetSpellInfo(id)
		if(name==x) then
		  local timeLeft=math.floor((start + duration) - GetTime())
		  y=id
		  RPrint(x.."["..y.."] time left["..timeLeft.."]")
		end

	  end
	end
  end
  return y
end
------------------------------------------------------------------------
function rp_spellz()
  for i=1,120 do
	local start,duration,enable=GetActionCooldown(i)
	if start > 0 and enable==1 then
	  local actiontype,id,subtype=GetActionInfo(i)
	  local name
	  if actiontype=="spell" then
		name=GetSpellInfo(id)
		--GetSpellName(id,"spell")
		--GetSpellBookItemName
	  elseif actiontype=="item" then
		name=GetItemInfo(id)
	  elseif actiontype=="companion" then
		name=select(2,GetCompanionInfo(subtype,id))
	  end

	  local timeLeft=math.floor((start + duration) - GetTime())
	  local output=string.format("Cooldown on %s %s (%s seconds left)",actiontype,name,timeLeft)
	  ChatFrame1:AddMessage(output)
	end
  end
end
------------------------------------------------------------------------
function rp_unit_has_buff(targx,buffcheck)
  for bx=1,5 do
	local buffname=UnitBuff(targx,bx)
	-- ,rnk,icn,cnt,dType,dur,expr,cstr,isSteal,cons,sid,canAA,isBD,v1,v2,v3
	-- if(buffname==nil) then  buffname=" " end
			--[[
			if(rnk==nil) then rnk=" " end
			if(icn==nil) then icn=" " end
			if(cnt==nil) then cnt=" " end
			if(dType==nil) then dType=" " end
			if(dur==nil) then dur=" " end
			if(expr==nil) then expr=" " end
			if(cstr==nil) then cstr=" " end
			if(isSteal==nil) then isSteal=" " end
			if(cons==nil) then cons=" " end
			if(sid==nil) then sid=" " end
			if(canAA) then canAA="1" else canAA="0" end
			if(canAA==nil) then canAA=" " end
			if(isBD==nil) then isBD=" " end
			if(v1) then v1="1" else v1="0" end
			if(v1==nil) then v1=" " end
			if(v2) then v2="1" else v2="0" end
			if(v2==nil) then v2=" " end
			if(v3) then v3="1" else v3="0" end
			if(v3==nil) then v3=" " end
	]]
	if(buffname~=nil) then
	  local dfp=strfind(buffname,buffcheck)
	  if(dfp~=nil) then
		--[[
			rp_RC(
			buffname
			.." rank:"..rnk
			.." count:"..cnt
			.." dispelType:"..dType
			.." duration:"..dur
			.." expires:"..expr
			.." caster:"..cstr
			.." stealable:"..isSteal
			.." consolidate:"..cons
			.." spell id:"..sid
			.." canApplyAura:"..canAA
			.." Boss Debuff:"..isBD
			.." v1:"..v1
			.." v2:"..v2
			.." v3:"..v3
			)
			local rpetbuffname=buffname
			local rct=count
		]]
		return 1
	  end
	end
  end
  return 0
end
------------------------------------------------------------------------
function rp_TargetOfBoss(targx)
  --isTanking,status,scaledPercent,rawPercent,threatValue=UnitDetailedThreatSituation(unit,mobUnit)
  if(IsInRaid("player")) then
	for index=0,25 do
	  local name=GetRaidRosterInfo(index)
	  if(name~=nil) then
		if(targx~=nil) then
		  local tx=UnitDetailedThreatSituation(name,targx)
		  if(tx~=nil) then
			return name
		  end
		end
	  end
	end
  else
	name=UnitName("player")
	local tx=UnitThreatSituation(name,targx)
	if(tx~=nil) then
	  return name
	end
  end
  return	"unknown"
end
------------------------------------------------------------------------
function rp_getthreat(targx)
  if(IsInRaid("player")) then
	for index=0,25 do
	  local name,rank,subgroup,level,class,fileName,zone,online,isDead,role,isML=GetRaidRosterInfo(index)
	  if(name~=nil) then
		if(targx~=nil) then
		  tx=UnitThreatSituation(name,targx)
		  if tx==2 then return name end
		  if tx==3 then return name end
		end
	  end
	end
  else
	name=UnitName("player")
	tx=UnitThreatSituation(name,targx)
	if tx==2 then return name end
	if tx==3 then return name end
  end
  return "unknown"
end
------------------------------------------------------------------------
function rp_ShowRaidInfo()
  
  local rcolor=""
  
    for index=0,40 do
        local   name,
                rank,
                subgroup,
                level,
                class,
                fileName,
                zone,
                online,
                isDead,
                role,
                isML = GetRaidRosterInfo(index)
            
        if(name~=nil) then
    
            -- tx=UnitThreatSituation(name,targx)

            glequipped = Reaper_GetUnitGearLevel("raid"..index)
            role       = UnitGroupRolesAssigned(name)

            rcolor=RFCC
            dead=" "

            if(role==nil)       then role=" (NO ROLE CHOSEN) " end
            if(isDead==nil)     then isDead=" " end
            if(online==1)       then online=" " end
            if(online==0)       then online=RFCC.." OFFLINE " end
            if(role=="TANK")    then role="TANK" rcolor="{skull}"   end
            if(role=="DAMAGER") then role="DPS." rcolor="{diamond}" end
            if(role=="HEALER")  then role="HEAL" rcolor="{star}"    end
            if(isDead==1)       then dead=" (DEAD)" end
            RInform(rcolor..role.." "..name.." "..level.." "..class.." "..zone..dead)
            -- .." GEAR:"..glequipped)
        end
    end
end
-----------------------------------------------------------------------
function rp_uci(targx,buffcheck)
  -- RInform(string.format("Time: %.2f\n",os.clock()))
  local tname=UnitName(targx)
  -- un=UnitName(targx)
  if tname~=nil then
	-- rp_RC(tname.." "..rp_getthreat(targx) )
	local upw=UnitPower(targx)
	local upt=UnitPowerType(targx)
	uptn="unknown"
	if upt~=nil then
	  if(upt==0) then uptn="mana" end
	  if(upt==1) then uptn="rage" end
	  if(upt==2) then uptn="focus" end
	  if(upt==3) then uptn="energy" end
	  if(upt==6) then uptn="runic" end
	end
	local spellname,s,t,tx,st,et,its,cid,ni=UnitCastingInfo(targx)
	if spellname==nil then spellname="not casting" end
	for bx=1,5 do
	  local buffname,rnk,icn,cnt,dType,dur,expr,cstr,isSteal,cons,sid,
            canAA,isBD,v1,v2,v3=UnitBuff(targx,bx)
	  -- if(buffname==nil) then	buffname=" "  end
	  if(rnk==nil) then rnk=" " end
	  if(icn==nil) then icn=" " end
	  if(cnt==nil) then cnt=" " end
	  if(dType==nil) then dType=" " end
	  if(dur==nil) then dur=" " end
	  if(expr==nil) then expr=" " end
	  if(cstr==nil) then cstr=" " end
	  if(isSteal==nil) then isSteal=" " end
	  if(cons==nil) then cons=" " end
	  if(sid==nil) then sid=" " end
	  if(canAA) then canAA="1" else canAA="0" end
	  if(canAA==nil) then canAA=" " end
	  if(isBD==nil) then isBD=" " end
	  if(v1) then v1="1" else v1="0" end
	  if(v1==nil) then v1=" " end
	  if(v2) then v2="1" else v2="0" end
	  if(v2==nil) then v2=" " end
	  if(v3) then v3="1" else v3="0" end
	  if(v3==nil) then v3=" " end
	  if(buffname~=nil) then
		local dfp=strfind(buffname,buffcheck)
		if(dfp~=nil) then
		  rp_RC(
		  buffname
		  .." rank:"..rnk
		  .." count:"..cnt
		  .." dispelType:"..dType
		  .." duration:"..dur
		  .." expires:"..expr
		  .." caster:"..cstr
		  .." stealable:"..isSteal
		  .." consolidate:"..cons
		  .." spell id:"..sid
		  .." canApplyAura:"..canAA
		  .." Boss Debuff:"..isBD
		  .." v1:"..v1
		  .." v2:"..v2
		  .." v3:"..v3
		  )
		  local rpetbuffname=buffname
		  local rct=count
		end
	  end
	end
	if(rpetbuffname==nil) then rpetbuffname=" " end
	local out=tname.."-> ["..spellname.."] ("..uptn..":"..upw..") (target :"..rp_getthreat(targx)..") "
	rp_RC(out)
  end
end
------------------------------------------------------------------------
function rp_f1()
  if(rpdb.tb==nil) then rpdb.tb={} end
  rpdb.tb["C_BlackMarket"]={}
  for key,value in pairs(C_BlackMarket) do rpdb.tb["C_BlackMarket"][key]=value end
  rpdb.tb["C_LootHistory"]={} for key,value in pairs(C_LootHistory) do rpdb.tb["C_LootHistory"][key]=value end
  rpdb.tb["C_PetBattles"]={}
  for key,value in pairs(C_PetBattles) 	do rpdb.tb["C_PetBattles"][key]=value end
  rpdb.tb["C_PetJournal"]={}
  for key,value in pairs(C_PetJournal) 	do rpdb.tb["C_PetJournal"][key]=value end
  rpdb.tb["C_Scenario"]={}
  for key,value in pairs(C_Scenario) 	do rpdb.tb["C_Scenario"][key]=value end
  rpdb.tb["_G[1]"]={}
  if(_G[1]~=nil) then
	for key,value in pairs(_G[1]) do rpdb.tb["_G[1]"][key]=value end
  end
end
------------------------------------------------------[Command Handler]
function Reaper_CommandHandler(msg)
  narg,numarg=sml_nargify(msg)
  --------------------------------------------------------------------------------
  if(msg=="show") then Reaper_Options_DisplayFrame:Show() end
  --------------------------------------------------------------------------------
  if(msg=="help") or (msg=="") or (msg=="?") then Reaper_ShowHelp() end
  --------------------------------------------------------------------------------
    if(narg[0]=="spell") then
        if(narg[1]~=nil) then
            local spellsearch=""
            for nzar=1,(numarg-1) do
                spellsearch=spellsearch..tostring(narg[nzar]).." "
            end
            spellsearch=string.match(spellsearch,".*%S")
            RInform("Spell Link Search: ["..spellsearch.."]")
            for izi=1,RP_NUM_SPELLS do
                wsp=ReaperSpellLink[izi]
                if(wsp~=nil) then
                    if(string.find(string.lower(wsp),string.lower(spellsearch))) then
                        RInform("["..izi.."] "..wsp)
                    end
                end
            end
        end
    end
  --------------------------------------------------------------------------------
  if(cmd=="f1") then rp_f1() end
  --------------------------------------------------------------------------------
  if(cmd=="topcrit") then RPrint(rpdb.TopCrit) end
  --------------------------------------------------------------------------------
  if(cmd=="debug") then for tsname,tstable in pairs(MerchantFrame) do RPrint(tsname) end RPrint(MerchantFrame.selectedTab) end
  --------------------------------------------------------------------------------
  if(cmd=="hfi") then local curframe=GetMouseFocus():GetName() RPrint(curframe) end
  --------------------------------------------------------------------------------
  if(cmd=="fish") then
	FISHFORK=0
	local spell,_,_,_,_,endTime=UnitChannelInfo("player")
	if spell then
	  -- local finish=endTime/1000 - GetTime()
	  RPrint(spell)
	  if(spell=="Fishing") then
		FISHFORK=1
	  end
	end
	if(FISHFORK==0) then
	  PlaySound("RaidWarning")
	end
  end
  --------------------------------------------------------------------------------
  if(msg=="rs") then Reaper_Restack() RPrint("restacked your items.") return end
end
------------------------------------------------------------------------
function Reaper_GetLink(item)
  if(item==nil) then return nil end
  for io,iw,ix in string.gmatch(item,"(.+)item:(.+):(.+)") do link="item:"..iw..":0" end
  return link
end
------------------------------------------------------------------------
function Reaper_Restack()
    local bag,ibag,slot,islot,ammo,tbag,tslot=0
    for bag=0,4 do
        tbag=bag
        for slot=1,20 do
            tslot=slot
            if(ammo~=bag) then
                iHi=GetContainerItemLink(bag,slot)
                if(iHi==nil) then
                    iHi="wot"
                else
                    link=Reaper_GetLink(iHi)
                    if(link~=nil) then
                        local itemName,itemLink,itemRarity,itemLevelReq,itemType,itemSubType,itemStackCount=GetItemInfo(link)
                        local duh,count,d2,quality,read=GetContainerItemInfo(bag,slot)
                        if(count==itemStackCount) then
                        else
                            for ibag=0,4 do
                                if(ammo~=ibag) then
                                    for islot=1,30 do
                                        if(ibag==bag) and (islot==slot) then
                                        else
                                            if(GetContainerItemLink(ibag,islot)==iHi) then
                                                link=Reaper_GetLink(iHi)
                                                if(link~=nil) then
                                                    local itemName,itemLink,itemRarity,itemLevelReq,itemMinLevel,itemType,itemSubType,itemStackCount,itemEquipLoc,itemTexture=GetItemInfo(link)
                                                    duh,count,d2,quality,read=GetContainerItemInfo(ibag,islot)
                                                    if(count==itemStackCount) then
                                                    else
                                                        RPrint("Combined item "..itemName)
                                                        PickupContainerItem(bag,slot)
                                                        a_temporary_variable=3
                                                        if(ibag==3) then a_temporary_variable=4 end
                                                        if(a_temporary_variable==ammo) then a_temporary_variable=ammo-1 end
                                                        Reaper_GoBag(a_temporary_variable)
                                                        jork=Reaper_GetSlot(iHi,a_temporary_variable)
                                                        if(jork~=nil) then
                                                            PickupContainerItem(a_temporary_variable,jork)
                                                            Reaper_GoBag(ibag)
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
    return false
end
------------------------------------------------------------------------
function Reaper_GoBag(bag)
    if(bag==0) then PutItemInBackpack() end
    if(bag==1) then PutItemInBag(20)    end
    if(bag==2) then PutItemInBag(21)    end
    if(bag==3) then PutItemInBag(22)    end
    if(bag==4) then PutItemInBag(23)    end
end
------------------------------------------------------------------------
function Reaper_GetSlot(itemZ,bag)
    for slot=1,20 do
        iHi=GetContainerItemLink(bag,slot)
        if(iHi~=nil) then
            if(iHi==itemZ) then
                return slot
            end
        end
    end
    return nil
end
------------------------------------------------------------------------
function Reaper_GetEquippedItem(slot)
    RPrint(slot)
    slotId,what=GetInventorySlotInfo(slot)
    if(slotId~=nil) then
        return GetInventoryItemLink("player",slotId)
    end
end
------------------------------------------------------------------------
function Reaper_CreateSpellListButtons()
    local index=0
    local createFrame = CreateFrame
    local parent      = Reaper_SpellListFrameSF
    local button      = createFrame("Button","Reaper_SpellListFrameSF_ItemButton1",parent, "Reaper_SpellListFrameSF_ItemButtonTemplate")
    button:SetID(1)
    button:SetPoint("TOPLEFT","Reaper_SpellListFrameSF","TOPLEFT",36,-75)
    button:RegisterForClicks("LeftButtonUp","RightButtonUp")
    for index=2,23 do
        button=createFrame("Button","Reaper_SpellListFrameSF_ItemButton"..index,parent,"Reaper_SpellListFrameSF_ItemButtonTemplate")
        button:SetID(index)
        button:SetPoint("TOPLEFT","Reaper_SpellListFrameSF_ItemButton"..(index-1),"BOTTOMLEFT",0,1)
        button:RegisterForClicks("LeftButtonUp","RightButtonUp")
    end
end
------------------------------------------------------------------------
function Reaper_Populate_SpellListFrame()
    for index=1,23 do
        local what=getglobal("Reaper_SpellListFrameSF_ItemButton"..index)
        if(what) then
            what:Hide()
        end
    end
    Reaper_SpellListFrame_TitleText:SetText("Spell Link List "..Reaper_SpellListFrameSF.RealResultsSize.." items")
    FauxScrollFrame_Update(Reaper_SpellListFrameSF,Reaper_SpellListFrameSF.RealResultsSize-1,22,16)
    local offset=Reaper_SpellListFrameSF.offset
    local index=1
    local grof=0
    for slid,astable in pairs (ReaperSpellLink) do
        if(grof<offset) then
            grof=grof+1
        else
            local zbutton=getglobal("Reaper_SpellListFrameSF_ItemButton"..index)
            if(zbutton~=nil) then
                zwhat=getglobal("Reaper_SpellListFrameSF_ItemButton"..index.."Text")
                zwhat:SetText(astable)
                zwhat=getglobal("Reaper_SpellListFrameSF_ItemButton"..index.."TxtId")
                zwhat:SetText(slid)
                zbutton:SetScript("OnClick",(function(self) Reaper_SpellLinkButtonPressed(slid) end))
                index=index+1
                zbutton:Show()
            end
        end
    end
end
------------------------------------------------------------------------
function Reaper_SpellLinkGetNumItems()
  local numitems=0
  for item,_ in pairs (ReaperSpellLink) do numitems=numitems+1 end
  return numitems
end
------------------------------------------------------------------------
function Reaper_SpellLinkButtonPressed(index)
  RInform(ReaperSpellLink[index])
end
------------------------------------------------------------------------
function Reaper_GetUnitGearLevel(unit)
    local count,total,avg=0
    for slot=1,20 do
        iHi=GetInventoryItemLink(unit,slotId)
        if(iHi~=nil) then
            link=Reaper_GetLink(iHi)
            -- local itemName,itemLink,itemRarity,itemLevelReq,itemType,itemSubType,itemStackCount=GetItemInfo(link)
            local name,link,quality,iLevel = GetItemInfo(link)
            if(iLevel~=nil) then
                count=count+1
                total=total+iLevel
            end
        end
    end
    if(count>0) then avg=total/count end
    return avg
end

    --[[ 
    -- gltotal,glequipped=GetAverageItemLevel(name)
    -- slotId,what=GetInventorySlotInfo(slot)
    -- if(slotId~=nil) then
    -- return GetInventoryItemLink("player",slotId)
    -- end
        
    slotName - Name of an inventory slot to query (string)
    AmmoSlot - Ranged ammunition slot
    BackSlot - Back (cloak) slot
    Bag0Slot - Backpack slot
    Bag1Slot - First bag slot
    Bag2Slot - Second bag slot
    Bag3Slot - Third bag slot
    ChestSlot - Chest slot
    FeetSlot - Feet (boots) slot
    Finger0Slot - First finger (ring) slot
    Finger1Slot - Second finger (ring) slot
    HandsSlot - Hand (gloves) slot
    HeadSlot - Head (helmet) slot
    LegsSlot - Legs (pants) slot
    MainHandSlot - Main hand weapon slot
    NeckSlot - Necklace slot
    RangedSlot - Ranged weapon or relic slot
    SecondaryHandSlot - Off-hand (weapon, shield, or held item) slot
    ShirtSlot - Shirt slot
    ShoulderSlot - Shoulder slot
    TabardSlot - Tabard slot
    Trinket0Slot - First trinket slot
    Trinket1Slot - Second trinket slot
    WaistSlot - Waist (belt) slot
    WristSlot - Wrist (bracers) slot

    unitID:
    
    player - The player him/herself
    pet - The player's pet
    vehicle - The vehicle currently controlled by the player
    target - The player's current target
    focus - The player's focused unit (as can be set by typing /focus name)
    mouseover - The unit currently under the mouse cursor (applies to both unit frames and units in the 3D world)
    none - A valid unit token that always refers to no unit. UnitName() will return "Unknown, nil" for this UnitID. Use to force a macro to not auto self-cast (/cast [target=none] Healing Wave).
    npc - The unit the player is currently interacting with (via the Merchant, Trainer, Bank, or similar UI); not necessarily an NPC (e.g. also used in the Trade UI)
    party1 to party4 - Another member of the player's party. Indices match the order party member frames are displayed in the default UI (party1 is at the top, party4 at the bottom), but not consistent among party members (i.e. if Thrall and Cairne are in the same party, the player Thrall sees as party2 may not be the same player Cairne sees as party2).
    partypet1 to partypet4 - A pet belonging to another member of the player's party
    raid1 to raid40 - A member of the player's raid group. Unlike with the party tokens, one of the raid unit IDs will belong to the player. Indices have no relation to the arrangement of units in the default UI.
    raidpet1 to raidpet40 - A pet belonging to a member of the player's raid group
    boss1 to boss5 - The active bosses of the current encounter if available
    arena1 to arena5 - A member of the opposing team in an Arena match
    
     -- Inventory slots
     INVSLOT_AMMO       = 0;
     INVSLOT_HEAD       = 1; INVSLOT_FIRST_EQUIPPED = INVSLOT_HEAD;
     INVSLOT_NECK       = 2;
     INVSLOT_SHOULDER   = 3;
     INVSLOT_BODY       = 4;
     INVSLOT_CHEST      = 5;
     INVSLOT_WAIST      = 6;
     INVSLOT_LEGS       = 7;
     INVSLOT_FEET       = 8;
     INVSLOT_WRIST      = 9;
     INVSLOT_HAND       = 10;
     INVSLOT_FINGER1    = 11;
     INVSLOT_FINGER2    = 12;
     INVSLOT_TRINKET1   = 13;
     INVSLOT_TRINKET2   = 14;
     INVSLOT_BACK       = 15;
     INVSLOT_MAINHAND   = 16;
     INVSLOT_OFFHAND    = 17;
     INVSLOT_RANGED     = 18;
     INVSLOT_TABARD     = 19;
     INVSLOT_LAST_EQUIPPED = INVSLOT_TABARD;

    ]]



