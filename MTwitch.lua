if Player.CharName ~= "Twitch" then return false end

module("MTwitch", package.seeall, log.setup)
clean.module("MTwitch", clean.seeall, log.setup)

local _SDK = _G.CoreEx
local ObjManager, EventManager, Input, Enums, Game, Geometry, Renderer = _SDK.ObjectManager, _SDK.EventManager, _SDK.Input, _SDK.Enums, _SDK.Game, _SDK.Geometry, _SDK.Renderer
local SpellSlots, SpellStates = Enums.SpellSlots, Enums.SpellStates
local Player = ObjManager.Player
local Prediction = _G.Libs.Prediction
local Orbwalker = _G.Libs.Orbwalker
local Spell, HealthPred = _G.Libs.Spell, _G.Libs.HealthPred
local DamageLib = _G.Libs.DamageLib

TS = _G.Libs.TargetSelector(Orbwalker.Menu)

-- NewMenu
local Menu = _G.Libs.NewMenu

-- Took from Thorn's AutoSmite
local JungleMonsters = {
	{Name = "SRU_Baron",        DisplayName = "Baron Nashor",   Enabled = true},
	{Name = "SRU_RiftHerald",   DisplayName = "Rift Herald",	Enabled = true},
	{Name = "SRU_Dragon_Air",   DisplayName = "Cloud Drake",	Enabled = true},
	{Name = "SRU_Dragon_Fire",  DisplayName = "Infernal Drake", Enabled = true},
	{Name = "SRU_Dragon_Earth", DisplayName = "Mountain Drake", Enabled = true},
	{Name = "SRU_Dragon_Water", DisplayName = "Ocean Drake",	Enabled = true},
	{Name = "SRU_Dragon_Elder", DisplayName = "Elder Drake",	Enabled = true},
	{Name = "SRU_Blue",         DisplayName = "Blue Buff",		Enabled = true},
	{Name = "SRU_Red",          DisplayName = "Red Buff",		Enabled = true},
	{Name = "SRU_Gromp",        DisplayName = "Gromp",			Enabled = false},
	{Name = "SRU_Murkwolf",     DisplayName = "Greater Wolf",	Enabled = false},
	{Name = "SRU_Razorbeak",    DisplayName = "Crimson Raptor", Enabled = false},
	{Name = "SRU_Krug",         DisplayName = "Ancient Krug",	Enabled = false},
	{Name = "Sru_Crab",         DisplayName = "Rift Scuttler",	Enabled = false},
}

function MTwitchMenu()
	Menu.NewTree("MTwitchCombo", "Combo", function ()
    Menu.Checkbox("Combo.CastQ","Cast Q",true)
		Menu.Slider("Combo.CastQMinMana", "Q % Min. Mana", 0, 1, 100, 1)
    Menu.Checkbox("Combo.CastW","Cast W",true)
	Menu.Slider("Combo.CastWHC", "W Hit Chance", 0.60, 0.05, 1, 0.05)
		Menu.Slider("Combo.CastWMinMana", "W % Min. Mana", 0, 1, 100, 1)
	Menu.Checkbox("Combo.CastE","Cast E",true)
	Menu.Slider("Combo.CastEMS", "E Min Stacks", 6, 1, 6, 1)
		Menu.Slider("Combo.CastEMinMana", "E % Min. Mana", 0, 1, 100, 1)
	Menu.Checkbox("Combo.CastR","Cast R on Hittable Enemies",true)
	Menu.Slider("Combo.CastRER", "R Hittable Enemies", 2, 1, 5, 1)
		Menu.Slider("Combo.CastRMinMana", "R % Min. Mana", 0, 1, 100, 1)
	end)
	Menu.NewTree("MTwitchHarass", "Harass", function ()
	Menu.Checkbox("Harass.CastW","Cast W",true)
	Menu.Slider("Harass.CastWHC", "W Hit Chance", 0.60, 0.05, 1, 0.05)
		Menu.Slider("Harass.CastWMinMana", "W % Min. Mana", 0, 1, 100, 1)
	Menu.Checkbox("Harass.CastE","Cast E",true)
	Menu.Slider("Harass.CastEMS", "E Min Stacks", 3, 1, 6, 1)
		Menu.Slider("Harass.CastEMinMana", "E % Min. Mana", 0, 1, 100, 1)
	end)
	Menu.NewTree("MTwitchWave", "Waveclear", function ()
		Menu.ColoredText("Wave", 0xFFD700FF, true)
		Menu.Checkbox("Waveclear.CastW","Cast W",true)
		Menu.Slider("Waveclear.CastWHC", "W Hit Count", 3, 1, 10, 1)
		Menu.Slider("Waveclear.CastWMinMana", "W % Min. Mana", 0, 1, 100, 1)
		Menu.Checkbox("Waveclear.CastE","Cast E on X Killable CS",true)
		Menu.Slider("Waveclear.CastEKCS", "E Killable CS", 3, 1, 6, 1)
		Menu.Slider("Waveclear.CastEMinMana", "E % Min. Mana", 0, 1, 100, 1)
		Menu.Separator()
		Menu.ColoredText("Jungle", 0xFFD700FF, true)
		Menu.Checkbox("Waveclear.CastWJg","Cast W",true)
		Menu.Slider("Waveclear.CastWHCJg", "W Hit Count", 3, 1, 10, 1)
		Menu.Slider("Waveclear.CastWMinManaJg", "W % Min. Mana", 0, 1, 100, 1)
		Menu.Checkbox("Waveclear.CastEJg","Cast E on X Killable CS",true)
		Menu.Slider("Waveclear.CastEKCSJg", "E Killable CS", 3, 1, 6, 1)
		Menu.Slider("Waveclear.CastEMinManaJg", "E % Min. Mana", 0, 1, 100, 1)
	end)
	Menu.NewTree("MTwitchMisc", "Misc.", function ()
		Menu.Keybind("Misc.StealthRecall", "Stealth Recall (Q+B)", string.byte('T'))
    Menu.Checkbox("Misc.CastEKS","Auto-Cast E Killable",true)
    Menu.Checkbox("Misc.CastEKSJg","Auto-Cast E Jungle Creeps",true)
		Menu.ColoredText("WhiteList", 0xFFD700FF, true)
		for k, v in pairs(JungleMonsters) do
			Menu.Checkbox(v.Name, v.DisplayName, v.Enabled)
		end
	end)
	Menu.NewTree("MTwitchDrawing", "Drawing", function ()
	Menu.Checkbox("Drawing.DrawW","Draw W Range",true)
    Menu.ColorPicker("Drawing.DrawWColor", "Draw W Color", 0x06D6A0FF)
	Menu.Checkbox("Drawing.DrawE","Draw E Range",true)
    Menu.ColorPicker("Drawing.DrawEColor", "Draw E Color", 0x118AB2FF)
	Menu.Checkbox("Drawing.DrawR","Draw R Range",true)
    Menu.ColorPicker("Drawing.DrawRColor", "Draw R Color", 0xFFD166FF)
	Menu.Checkbox("Drawing.DrawDamage","Draw Damage",true)
	end)
end

Menu.RegisterMenu("MTwitch","MTwitch",MTwitchMenu)

local spells = {
	Q = Spell.Active({
		Slot = Enums.SpellSlots.Q,
	}),
	W = Spell.Skillshot({
		Slot = Enums.SpellSlots.W,
		Range = 950,
		Speed = 1400,
		Delay = 0.65,
		Radius = 120,
		Type = "Circular",
	}),
	E = Spell.Active({
		Slot = Enums.SpellSlots.E,
		Range = 1200,
		Delay = 0.25,
	}),
	R = Spell.Active({
		Slot = Enums.SpellSlots.R,
		Range = 1100,
		Speed = 4000,
		Delay = 0.1,
		Radius = 60,
	}),
}

local lastTick = 0
local stealthRecall = false

local function ValidMinion(minion)
	return minion and minion.IsTargetable and minion.MaxHealth > 6 -- check if not plant or shroom
end

local function GameIsAvailable()
	return not (Game.IsChatOpen() or Game.IsMinimized() or Player.IsDead)
end

local function CastQ()
	if spells.Q:IsReady() then
		if spells.Q:Cast() then
			return
		end
	end
end

local function CastW(target, hitChance)
	if spells.W:IsReady() then
		if spells.W:CastOnHitChance(target, hitChance) then
			return
		end
	end
end

local function CastE()
	if spells.E:IsReady() then
		if spells.E:Cast() then
			return
		end
	end
end

local function CastR()
	if not spells.R:IsReady() then return end

	local enemies = ObjManager.Get("enemy", "heroes")
	local myPos, rRange, pointsR = Player.Position, spells.R.Range, {}

	for handle, obj in pairs(enemies) do
		local hero = obj.AsHero
		if hero and hero.IsTargetable then

			local posR = hero:FastPrediction(spells.R.Delay)

			if posR:Distance(myPos) < rRange and hero.IsTargetable then
				table.insert(pointsR, posR)
			end

		end
	end

	local bestPosR, hitCountR = Geometry.BestCoveringRectangle(pointsR, myPos, spells.R.Radius*2)
	if bestPosR and hitCountR >= Menu.Get("Combo.CastRER") then
		spells.R:Cast()
	end
end

function GetEDmg(target, buffCount)
	
	local playerBonusAD = Player.BonusAD
	local playerTotalAP = Player.TotalAP
	if buffCount > 0 and playerBonusAD then
		local twitchE = {20, 30, 40, 50, 60}
		local twitchEStack = {15, 20, 25, 30, 35}
		local dmgE = twitchE[Player:GetSpell(SpellSlots.E).Level]
		local dmgEStack = twitchEStack[Player:GetSpell(SpellSlots.E).Level]
		
		local totalDmgE = dmgE + (dmgEStack + playerBonusAD * 0.35 + playerTotalAP * 0.333) * buffCount
		
		return DamageLib.CalculatePhysicalDamage(Player, target, totalDmgE)
	else
		return 0
	end

end

local function GetDamage(target)
	local totalDmg = 0
	local eStacks = CountEStacks(target)

	if spells.E:IsReady() then
		totalDmg = totalDmg + GetEDmg(target, eStacks)
	end

	return totalDmg
end

function CountEStacks(target) 
	local targetAI = target.AsAI
    if targetAI and targetAI.IsValid then
		local twitchPoisonBuff = targetAI:GetBuff("TwitchDeadlyVenom")
		
		if twitchPoisonBuff then 
			return twitchPoisonBuff.Count
		end
	end

	return 0
end

local function IsPoisoned(target)
	local targetAI = target.AsAI
	local twitchPoisonBuff = targetAI:GetBuff("TwitchDeadlyVenom")

	if twitchPoisonBuff then
		return true
	end
	return false
end

local function CanEMob(minion)
	return minion and Menu.Get(minion.CharName, true)
end

local function Waveclear()

	if spells.W:IsReady() or spells.E:IsReady() then

		local pPos, pointsW, minionE = Player.Position, {}, nil
		local isJgCS = false
		local nrKillableCS = 0

		-- Enemy Minions
		for k, v in pairs(ObjManager.GetNearby("enemy", "minions")) do
			local minion = v.AsAI
			if ValidMinion(minion) then
				local posW = minion:FastPrediction(spells.W.Delay)
				if posW:Distance(pPos) < spells.W.Range and minion.IsTargetable then
					table.insert(pointsW, posW)
				end

				if minion:Distance(pPos) <= spells.E.Range then
					if IsPoisoned(minion) then
						local buffCountPoison = CountEStacks(minion)
						local healthPred = HealthPred.GetHealthPrediction(minion, spells.E.Delay)

						if buffCountPoison and GetEDmg(minion,buffCountPoison) >= healthPred then
							nrKillableCS = nrKillableCS + 1
						end
					end
				end
			end
		end

		-- Jungle Minions
		if #pointsW == 0 or not minionE then
			for k, v in pairs(ObjManager.GetNearby("neutral", "minions")) do
				local minion = v.AsAI
				if ValidMinion(minion) then
					local posW = minion:FastPrediction(spells.W.Delay)
					if posW:Distance(pPos) < spells.W.Range and minion.IsTargetable then
						isJgCS = true
						table.insert(pointsW, posW)
					end

					if minion:Distance(pPos) <= spells.E.Range then
						isJgCS = true
						if IsPoisoned(minion) then
							local buffCountPoison = CountEStacks(minion)
							local healthPred = HealthPred.GetHealthPrediction(minion, spells.E.Delay)

							if buffCountPoison and GetEDmg(minion,buffCountPoison) >= healthPred then
								nrKillableCS = nrKillableCS + 1
							end
						end
					end
				end
			end
		end


		local castWMenu = nil
		local castWHCMenu = nil
		local castWMinManaMenu = nil
		local castEMenu = nil
		local castEMinManaMenu = nil

		if not isJgCS then
			castWMenu = Menu.Get("Waveclear.CastW")
			castWHCMenu = Menu.Get("Waveclear.CastWHC")
			castWMinManaMenu = Menu.Get("Waveclear.CastWMinMana")
			castEMenu = Menu.Get("Waveclear.CastE")
			castEKCSMenu = Menu.Get("Waveclear.CastEKCS")
			castEMinManaMenu = Menu.Get("Waveclear.CastEMinMana")
		else
			castWMenu = Menu.Get("Waveclear.CastWJg")
			castWHCMenu = Menu.Get("Waveclear.CastWHCJg")
			castWMinManaMenu = Menu.Get("Waveclear.CastWMinManaJg")
			castEMenu = Menu.Get("Waveclear.CastEJg")
			castEKCSMenu = Menu.Get("Waveclear.CastEKCSJg")
			castEMinManaMenu = Menu.Get("Waveclear.CastEMinManaJg")
		end

		local bestPosW, hitCountW = spells.W:GetBestCircularCastPos(pointsW)

		if bestPosW and hitCountW >= castWHCMenu
				and spells.E:IsReady() and castWMenu
				and Player.Mana >= (castWMinManaMenu / 100) * Player.MaxMana then
			spells.W:Cast(bestPosW)
			return
		end
		if nrKillableCS >= castEKCSMenu and spells.E:IsReady() and castEMenu
				and Player.Mana >= (castEMinManaMenu / 100) * Player.MaxMana then
			CastE()
			return
		end
	end
end

local function AutoE()
	local enemies = ObjManager.GetNearby("enemy", "heroes")
	local myPos, myRange = Player.Position, (Player.AttackRange + Player.BoundingRadius)

	if Player:GetSpellState(SpellSlots.E) ~= SpellStates.Ready then return end

	for handle, obj in pairs(enemies) do        
		local hero = obj.AsHero        
		if hero and hero.IsTargetable then
			local buffCountVenom = CountEStacks(hero)
			local dist = myPos:Distance(hero.Position)

			if dist <= spells.E.Range and buffCountVenom and GetEDmg(hero,buffCountVenom) >= hero.Health then
				CastE() -- E KS
			end
		end		
	end	
end

local function AutoEJg()
	local myPos = Player.Position

	for k, obj in pairs(ObjManager.GetNearby("neutral", "minions")) do
		local mob = obj.AsMinion
		if mob:EdgeDistance(myPos) <= spells.E.Range then
			if CanEMob(mob) and mob.IsTargetable then
				local buffCountPoison = CountEStacks(mob)
				if buffCountPoison
						and mob.Health <= GetEDmg(mob,buffCountPoison) then
					CastE()
					return
				end
			end
		end
	end
end

local function StealthRecall()
	if Player:GetSpellState(SpellSlots.Q) == SpellStates.Ready then
		Input.Cast(SpellSlots.Q)
	end
	if not Player.IsRecalling then
		stealthRecall = true
		Input.Cast(SpellSlots.Recall)
	end
	if Player.IsRecalling then
		stealthRecall = false
	end
end

local function OnDraw()

	-- Draw W Range
	if Player:GetSpell(SpellSlots.W).IsLearned and Menu.Get("Drawing.DrawW") then
		Renderer.DrawCircle3D(Player.Position, spells.W.Range, 30, 1.0, Menu.Get("Drawing.DrawWColor"))
	end
	-- Draw E Range
	if Player:GetSpell(SpellSlots.E).IsLearned and Menu.Get("Drawing.DrawE") then
		Renderer.DrawCircle3D(Player.Position, spells.E.Range, 30, 1.0, Menu.Get("Drawing.DrawEColor"))
	end
	-- Draw R Range
	if Player:GetSpell(SpellSlots.R).IsLearned and Menu.Get("Drawing.DrawR") then
		Renderer.DrawCircle3D(Player.Position, spells.R.Range, 30, 1.0, Menu.Get("Drawing.DrawRColor"))
	end

end

local function OnDrawDamage(target, dmgList)
	if Menu.Get("Drawing.DrawDamage") then
		table.insert(dmgList, GetDamage(target))
	end
end

local function OnExtremePriority()

	if not spells.E:IsReady() then return end

	if Menu.Get("Misc.CastEKS") then
		AutoE()
	end

	if Menu.Get("Misc.CastEKSJg") then
		AutoEJg()
	end
end

local function OnNormalPriority()

	if not GameIsAvailable() then return end

	local gameTime = Game.GetTime()
	if gameTime < (lastTick + 0.25) then return end
	lastTick = gameTime

	if Orbwalker.GetMode() == "Combo" then
		if Menu.Get("Combo.CastQ") then
			if spells.Q:IsReady() then
				local target = Orbwalker.GetTarget() or TS:GetTarget(Player.AttackRange + Player.BoundingRadius, false)
				if target and Player.Mana >= (Menu.Get("Combo.CastQMinMana") / 100) * Player.MaxMana then
					CastQ()
					return
				end
			end
		end
		if Menu.Get("Combo.CastW") then
			if spells.W:IsReady() then
				local target = Orbwalker.GetTarget() or TS:GetTarget(spells.W.Range + Player.BoundingRadius, true)
				if target and target.Position:Distance(Player.Position) <= (spells.W.Range + Player.BoundingRadius)
						and Player.Mana >= (Menu.Get("Combo.CastWMinMana") / 100) * Player.MaxMana then
					CastW(target,Menu.Get("Combo.CastWHC"))
					return
				end
			end
		end
		if Menu.Get("Combo.CastE") then
			if spells.E:IsReady() then
				local target = Orbwalker.GetTarget() or TS:GetTarget(spells.E.Range + Player.BoundingRadius, true)
				if target and target.Position:Distance(Player.Position) <= (spells.E.Range + Player.BoundingRadius)
						and Player.Mana >= (Menu.Get("Combo.CastEMinMana") / 100) * Player.MaxMana then

					local buffCountVenom = CountEStacks(target)
					if buffCountVenom >= Menu.Get("Combo.CastEMS") then
						CastE()
						return
					end
				end
			end
		end
		if Menu.Get("Combo.CastR") then
			if spells.R:IsReady() then
				local target = Orbwalker.GetTarget() or TS:GetTarget(spells.R.Range + Player.BoundingRadius, true)
				if target and target.Position:Distance(Player.Position) <= (spells.R.Range + Player.BoundingRadius)
						and Player.Mana >= (Menu.Get("Combo.CastRMinMana") / 100) * Player.MaxMana then
					CastR()
					return
				end
			end
		end

		-- Waveclear
	elseif Orbwalker.GetMode() == "Waveclear" then

		Waveclear()

		-- Harass
	elseif Orbwalker.GetMode() == "Harass" then

		if Menu.Get("Harass.CastW") then
			if spells.W:IsReady() then
				local target = Orbwalker.GetTarget() or TS:GetTarget(spells.W.Range + Player.BoundingRadius, true)
				if target and target.Position:Distance(Player.Position) <= (spells.W.Range + Player.BoundingRadius)
						and Player.Mana >= (Menu.Get("Harass.CastWMinMana") / 100) * Player.MaxMana then
					CastW(target,Menu.Get("Harass.CastWHC"))
					return
				end
			end
		end
		if Menu.Get("Harass.CastE") then
			if spells.E:IsReady() then
				local target = Orbwalker.GetTarget() or TS:GetTarget(spells.E.Range + Player.BoundingRadius, true)
				if target and target.Position:Distance(Player.Position) <= (spells.E.Range + Player.BoundingRadius)
						and Player.Mana >= (Menu.Get("Harass.CastEMinMana") / 100) * Player.MaxMana then

					local buffCountVenom = CountEStacks(target)
					if buffCountVenom >= Menu.Get("Harass.CastEMS") then
						CastE()
						return
					end
				end
			end
		end

	end


	if Menu.Get("Misc.StealthRecall") or stealthRecall then
			StealthRecall()
	end
end

function OnLoad()
	if Player.CharName ~= "Twitch" then return false end

	EventManager.RegisterCallback(Enums.Events.OnExtremePriority, OnExtremePriority)
	EventManager.RegisterCallback(Enums.Events.OnNormalPriority, OnNormalPriority)
	EventManager.RegisterCallback(Enums.Events.OnDraw, OnDraw)
	EventManager.RegisterCallback(Enums.Events.OnDrawDamage, OnDrawDamage)

	return true
end
