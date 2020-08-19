-- OG Orbwalker for Robur
-- Credits: SoNiice

require("common.log")
module("OGOrbwalker", package.seeall, log.setup)

winapi = require("utils.winapi")

local _SDK = _G.CoreEx
local Console, ObjManager, EventManager, Geometry, Input, Renderer, Enums, Game = _SDK.Console, _SDK.ObjectManager, _SDK.EventManager, _SDK.Geometry, _SDK.Input, _SDK.Renderer, _SDK.Enums, _SDK.Game
local Events = _SDK.Enums.Events
local Player = ObjManager.Player

local ts = require("lol/Modules/Common/OGsimpleTS")

local OrbwalkerModes = { 
    None = 0,
    Combo = 1,
    LastHit = 2,
    WaveClear = 3,
	Mixed = 4
}

local AutoAttackResets = {
    ["Sivir_1"] = true,
    ["Camille_0"] = true,
    ["Vi_2"] = true,
}

local DashAutoAttackResets = {
    ["Lucian_2"] = true,
    ["Vayne_0"] = true,
    ["Ekko_2"] = true,
}

local Orbwalker = {}

Orbwalker.Mode = OrbwalkerModes.None
Orbwalker.IsChatOpen = Game.IsChatOpen()
Orbwalker.LastAATick = 0
Orbwalker.CurrentTarget = nil

_G.OGOnCombo = false

local Keys = {
    [" "] = OrbwalkerModes.Combo,
    ["Z"] = OrbwalkerModes.WaveClear,
	["C"] = OrbwalkerModes.Mixed,
	["X"] = OrbwalkerModes.LastHit,
}

local minMoveDistance = 65
local isMelee = false;

local function CanMove()
    return winapi.getTickCount() > Orbwalker.LastAATick + Player.AttackCastDelay * 1000
end

local function CanAttack()
	return winapi.getTickCount() > Orbwalker.LastAATick + Player.AttackDelay * 1000
end

local function Move()
	local myPos = Player.Position
	local mousePos = Renderer:GetMousePos()
    if myPos:Distance(mousePos) >= minMoveDistance then
        Input.MoveTo(mousePos)
    end
end

local function FirePreAutoAttackEvent()
    EventManager.FireEvent(Events.OnPreAttack)
end

local function triggerOnAutoAttackEvent()
    --toadd EventManager.FireEvent(Events.OnAutoAttack)
end

local function triggerPostAutoAttackEvent()
    EventManager.FireEvent(Events.OnPostAttack)
end

local function ResetAutoAttack()
    Orbwalker.LastAATick = 0
end

local function Attack(target)
    FirePreAutoAttackEvent()
    Input.Attack(target)
end

local function OnProcessSpell(sender,spell)

    if sender.IsMe then

		local hero = sender.AsHero
        if spell.IsBasicAttack then

            Orbwalker.LastAATick = winapi.getTickCount() - Game:GetLatency()

            triggerOnAutoAttackEvent()
            delay(Player.AttackDelay * 1000, triggerPostAutoAttackEvent)
        else
            local key = string.format("%s_%d", hero.CharName, spell.Slot)
            if AutoAttackResets[key] or DashAutoAttackResets[key] then
                ResetAutoAttack()
            end
        end
    end
end

local function OnAutoAttack()
end

Orbwalker.Orbwalk = function(target)
	local hero = Player.AsAI
    if Player.Pathing.isDashing and Player.Pathing.isMoving then return end
	
    if target ~= nil and CanAttack() then
        Attack(target)
    elseif CanMove() then
        Move()
    end
end

local function OnTick()
	_G.OGOnCombo = false
    if Orbwalker.Mode == OrbwalkerModes.None then return end	
	
	local target
	if Orbwalker.Mode == OrbwalkerModes.Combo then
		_G.OGOnCombo = true
		target = ts:GetTarget(Player.AttackRange, ts.Priority.LowHPInRange)
		if target then
			local hero = target.AsHero
		end
	elseif Orbwalker.Mode == OrbwalkerModes.WaveClear then
		target = ts:GetTargetWaveClear()
	elseif Orbwalker.Mode == OrbwalkerModes.Mixed then
		target = ts:GetTargetMixed()
	elseif Orbwalker.Mode == OrbwalkerModes.LastHit then
		target = ts:GetTargetLastHit()
	end
	Orbwalker.CurrentTarget = target
    Orbwalker.Orbwalk(target)
end

local function OnDraw()
	-- Player Drawing
	local myPos = Player.Position
	local myRange = Player.AttackRange + Player.BoundingRadius
	Renderer.DrawCircle3D(myPos, myRange, 30, 1.0, 0xFFFFFFFF)
end

Orbwalker.Initialize = function ()
	EventManager.RegisterCallback(Enums.Events.OnDraw, OnDraw)
	EventManager.RegisterCallback(Enums.Events.OnProcessSpell, OnProcessSpell)
    EventManager.RegisterCallback(Enums.Events.OnTick, OnTick)
	EventManager.RegisterCallback(Enums.Events.OnKeyDown, 
		function(keycode, char, lparam) 
			if Keys[char] and not(Game.IsChatOpen()) then
				Orbwalker.Mode = Keys[char]
			end
		end)
    EventManager.RegisterCallback(Enums.Events.OnKeyUp, 
		function(keycode, char, lparam) 
			if Keys[char] then
				Orbwalker.Mode = OrbwalkerModes.None
    end
		end)   
end

return Orbwalker
