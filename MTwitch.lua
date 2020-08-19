require("common.log")
module("MTwitch", package.seeall, log.setup)

local Orbwalker = require("lol/Modules/Common/OGOrbWalker")

local _SDK = _G.CoreEx
local ObjManager, EventManager, Input, Enums, Game = _SDK.ObjectManager, _SDK.EventManager, _SDK.Input, _SDK.Enums, _SDK.Game
local SpellSlots, SpellStates = Enums.SpellSlots, Enums.SpellStates 
local Player = ObjManager.Player

function getEdmg(target, buffCount)
	
	if buffCount > 0 and Player.BonusAD then
		local twitchE = {20, 30, 40, 50, 60}
		local twitchEStack = {15, 20, 25, 30, 35}
		local dmgE = twitchE[Player:GetSpell(SpellSlots.E).Level]
		local dmgEStack = twitchEStack[Player:GetSpell(SpellSlots.E).Level]
		
		local totalDmgE = dmgE + (dmgEStack + Player.BonusAD * 0.35 + Player.TotalAP * 0.2) * buffCount
		
		return totalDmgE * (100.0 / (100 + target.Armor ) )
		
	else
		return 0
	end

end

function countEStacks(target) 
	local ai = target.AsAI
    if ai and ai.IsValid then
		for i = 0, ai.BuffCount do
			local buff = ai:GetBuff(i)
			if buff then
				if buff.Name == "TwitchDeadlyVenom" then
					if buff.Count ~= nil then
						return buff.Count
					end
				end
			end
		end
	end

	return 0
	
end

local function UseItems(target)	
	for i=SpellSlots.Item1, SpellSlots.Item6 do
		local _item = Player:GetSpell(i)
		if _item ~= nil and _item then
			local itemInfo = _item.Name

			if itemInfo == "ItemSwordOfFeastAndFamine" or itemInfo == "BilgewaterCutlass" then
				if Player:GetSpellState(i) == SpellStates.Ready then
					Input.Cast(i, target)
				end
				break
			end
		end
	end
end

local function Combo(target)
	if Player:GetSpellState(SpellSlots.E) == SpellStates.Ready then
		--local target = ts:GetTarget(1200,ts.Priority.LowestHealth)
		local buffCountVenom = countEStacks(target)

		if buffCountVenom > 5 then
			Input.Cast(SpellSlots.E	)
		end
	end
end

local function AutoE()
	local enemies = ObjManager.Get("enemy", "heroes")
	local myPos, myRange = Player.Position, (Player.AttackRange + Player.BoundingRadius)	
	
	if Player:GetSpellState(SpellSlots.E) ~= SpellStates.Ready then return end

	for handle, obj in pairs(enemies) do        
		local hero = obj.AsHero        
		if hero and hero.IsTargetable then
			local buffCountVenom = countEStacks(hero)
			local dist = myPos:Distance(hero.Position)

			if dist <= 1200 and buffCountVenom and getEdmg(hero,buffCountVenom) > (hero.Health) then				
				Input.Cast(SpellSlots.E) -- E KS        
			end
		end		
	end	
end 

local function OnTick()	

	AutoE()
	
	local target = Orbwalker.Mode == 1 and Orbwalker.CurrentTarget
	if target then 
		Combo(target)
		if Player.Position:Distance(target.Position) <= 550 then
			UseItems(target)
		end
	end
end

function OnLoad() 
	if Player.CharName ~= "Twitch" then return false end 
	
	EventManager.RegisterCallback(Enums.Events.OnTick, OnTick)
	Orbwalker.Initialize()
	
	Game.PrintChat("MTwitch Loaded !")
	return true
end

