-- OGSimple Target Selector
-- Based on the initial version from Lexx

require("common.log")
module("OGsimpleTS", package.seeall, log.setup)

local _Core = _G.CoreEx
local ObjectManager = _Core.ObjectManager
local Player = ObjectManager.Player
local BuffTypes = _Core.Enums.BuffTypes
local Renderer = _Core.Renderer
local EventManager = _Core.EventManager
local Game = _Core.Game
local Enums = _Core.Enums

local ts = {}
local selectedTarget = nil

ts.Priority = {
    LowestHealth = 1,
    LowestMaxHealth = 2,
    LowestArmor = 3,
    LowestMagicResist = 4,
    Closest = 5,
    CloseToMouse = 6,
    MostAD = 7,
    MostAP = 8,
	LowHPInRange = 9
}

local function HasBuffType(unit,buffType)
    local ai = unit.AsAI
    if ai.IsValid then
        for i = 0, ai.BuffCount do
            local buff = ai:GetBuff(i)
            if buff and buff.IsValid and buff.BuffType == buffType then
                return true
            end
        end
    end
    return false
end

function IsValidTarget(target,checkForRange)
	if checkForRange == nil or checkForRange == false then
		return target and target.IsVisible and target.IsAttackableUnit and target.IsTargetable and target.Health > 0
	else
		local playerPos = Player.Position
		local myRange = Player.AttackRange + Player.BoundingRadius
		return target and target.IsVisible and target.IsAttackableUnit and target.IsTargetable and target.Health > 0
			and playerPos:Distance(target.Position) < myRange
	end
end

function ts:GetTarget(range, mode, filterBuffs)
    if mode == nil then mode = ts.Priority.LowestHealth end
    if filterBuffs == nil then filterBuffs = false end
    local enemies = ObjectManager.Get("enemy", "heroes")
    local tempHero = nil
	if selectedTarget and IsValidTarget(selectedTarget) then
		tempHero = selectedTarget
	else
		--selectedTarget = nil
		for _, obj in pairs(enemies) do
			local hero = obj.AsHero
			if IsValidTarget(hero) and Player.Position:Distance(hero.Position) < range + Player.BoundingRadius + hero.BoundingRadius then
				local NEXT = false
				if filterBuffs then
					if HasBuffType(hero,BuffTypes.Invulnerability) or hero.IsDodgingMissiles then
						NEXT = true
					end
				end
				if not NEXT then
					if mode == ts.Priority.LowestHealth then
						if tempHero == nil or hero.Health < tempHero.Health then
							tempHero = hero
						end
					elseif mode == ts.Priority.LowestMaxHealth then
						if tempHero == nil or hero.MaxHealth < tempHero.MaxHealth then
							tempHero = hero
						end
					elseif mode == ts.Priority.LowestArmor then
						if tempHero == nil or hero.Armor  < tempHero.Armor  then
							tempHero = hero
						end
					elseif mode == ts.Priority.LowestMagicResist then
						if tempHero == nil or hero.FlatMagicReduction  < tempHero.FlatMagicReduction  then
							tempHero = hero
						end
					elseif mode == ts.Priority.Closest then
						local playerPos = Player.Position
						if tempHero == nil or playerPos:Distance(hero.Position)  < playerPos:Distance(tempHero.Position)  then
							tempHero = hero
						end
					elseif mode == ts.Priority.CloseToMouse then
						local mousePos = Renderer:GetMousePos()
						if tempHero == nil or mousePos:Distance(hero.Position)  < mousePos:Distance(tempHero.Position)  then
							tempHero = hero
						end
					elseif mode == ts.Priority.MostAD then
						if tempHero == nil or hero.TotalAD  > tempHero.TotalAD  then
							tempHero = hero
						end
					elseif mode == ts.Priority.MostAP then
						if tempHero == nil or hero.TotalAP  > tempHero.TotalAP  then
							tempHero = hero
						end
					elseif mode == ts.Priority.LowHPInRange then
						local playerPos = Player.Position
						local myRange = Player.AttackRange + Player.BoundingRadius
						if tempHero == nil or (hero.Health < tempHero.Health and playerPos:Distance(hero.Position) < playerPos:Distance(tempHero.Position)) then
							tempHero = hero
						end
					end
				end
			end
		end
	end
    return tempHero
end

function ts:GetTargetWaveClear()

	-- Turrets
    local turrets = ObjectManager.Get("enemy","turrets")
    for _, obj in pairs(turrets) do
        local turret = obj.AsTurret
        if turret and IsValidTarget(turret,true) then
            return turret
        end
    end

	-- Inibs
    local inhibs = ObjectManager.Get("enemy","inhibitors")
    for _, obj in pairs(inhibs) do
        local inhib = obj.AsAttackableUnit
        if inhib and IsValidTarget(inhib,true) then
            return inhib
        end
    end

	-- HQs
    local hqs = ObjectManager.Get("enemy","hqs")
    for _, obj in pairs(hqs) do
        local hq = obj.AsAttackableUnit
        if hq and IsValidTarget(hq,true) then
            return hq
        end
    end

	-- Enemies
    local enemies = ObjectManager.Get("enemy", "heroes")
    local tempHero = nil
    for _, obj in pairs(enemies) do
        local hero = obj.AsHero
        if hero and IsValidTarget(hero,true) then
            if tempHero == nil or hero.Health < tempHero.Health then
                tempHero = hero
            end
        end
    end
    if tempHero ~= nil then return tempHero end

	-- Enemy Minions
    local minions = ObjectManager.Get("enemy", "minions")
    local tempMinion = nil
    for _, obj in pairs(minions) do
        local minion = obj.AsMinion
        if minion and IsValidTarget(minion,true) then
            if tempMinion == nil or minion.Health < tempMinion.Health then
                tempMinion = minion
            end
        end
    end
    if tempMinion ~= nil then return tempMinion end

	-- Enemy Wards
    local wards = ObjectManager.Get("enemy", "wards")
    local tempWard = nil
    for _, obj in pairs(wards) do
        local ward = obj.AsAttackableUnit
        if ward and IsValidTarget(ward,true) then
            if tempWard == nil or ward.Health < tempWard.Health then
                tempWard = ward
            end
        end
    end
    if tempWard ~= nil then return tempWard end

	-- Jungle Minions
    minions = ObjectManager.Get("neutral", "minions")
    tempMinion = nil
    for _, obj in pairs(minions) do
        local minion = obj.AsMinion
        if minion and IsValidTarget(minion,true) then
            if tempMinion == nil or minion.Health < tempMinion.Health then
                tempMinion = minion
            end
        end
    end
    if tempMinion ~= nil then return tempMinion end
    return nil
end

function ts:GetTargetLastHit()
	
	-- Enemy Minions 
    local minions = ObjectManager.Get("enemy", "minions")
    local tempMinion = nil
    for _, obj in pairs(minions) do
        local minion = obj.AsMinion
        if minion and IsValidTarget(minion,true) then
            local finalDmg = Player.TotalAD * (100.0 / (100 + minion.Armor ) ) -- still perc and pen to add
			if minion.Health < finalDmg then
				if tempMinion == nil then
					tempMinion = minion
				end
			end
        end
    end
	
    return tempMinion
	
end

function ts:GetTargetMixed()
	local target = ts:GetTarget(Player.AttackRange + Player.BoundingRadius, ts.Priority.LowHPInRange)
	
	if target == nil then
		target = ts:GetTargetLastHit()
	end
	
	return target
	
end

local function OnDraw()
	if selectedTarget ~= nil then
		Renderer.DrawCircle3D(selectedTarget.Position, 100, 20, 1.0, 0xFF0000FF)
	end
end

EventManager.RegisterCallback(Enums.Events.OnMouseEvent, 
	function(e, message, wparam, lparam)
		if message == 1 then 
			selectedTarget = nil
            local mousePos = Renderer:GetMousePos()
            for handle, obj in pairs(ObjectManager.Get("enemy", "heroes")  ) do
                local heroDist = mousePos:Distance(obj.Position)
                local distFromSelectedTarget = selectedTarget and mousePos:Distance(selectedTarget.Position) or 25000
				
                local hero = obj.AsHero         
                if IsValidTarget(hero) and heroDist < 100 and heroDist < distFromSelectedTarget then
                    selectedTarget = hero
                end
            end
		end 
	end)
	
EventManager.RegisterCallback(Enums.Events.OnDraw, OnDraw)

return ts
