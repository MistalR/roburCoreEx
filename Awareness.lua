require("common.log")
module("Awareness", package.seeall, log.setup)

local _SDK = _G.CoreEx
local ObjManager, EventManager, Renderer, Enums, Game = _SDK.ObjectManager, _SDK.EventManager, _SDK.Renderer, _SDK.Enums, _SDK.Game
local Player = ObjManager.Player

local function OnDraw()

	-- Turret Range
    local turrets = ObjManager.Get("enemy", "turrets")
    for handle, obj in pairs(turrets) do 
		if obj.IsVisible and not obj.IsDead then
			local turretRange = 750.0 + obj.BoundingRadius
			Renderer.DrawCircle3D(obj.Position, turretRange, 20, 1.0, 0xFF0000FF)
		end
	end
	
	-- Wards Drawing from ObjectCreation
    local wards = ObjManager.Get("enemy", "wards")
    for handle, ward in pairs(wards) do 
		if ward ~= nil then
			if ward.Name == "SightWard" then
				Renderer.DrawCircle3D(ward.Position, 50.0, 20, 1.0, 0xf0ff00ff)
			--elseif ward.Name == "Trinket" then
			--	Renderer.DrawCircle3D(ward.Position, 50.0, 20, 1.0, 0x0000ffff)
			elseif ward.Name == "JammerDevice" then
				Renderer.DrawCircle3D(ward.Position, 50.0, 20, 1.0, 0x963694ff)
			end
		end
	end
	
	-- Enemies Range
    local enemies = ObjManager.Get("enemy", "heroes")
    for handle, obj in pairs(enemies) do 
		local enemyHero = obj.AsHero
		local playerPos = Player.Position
		if playerPos:Distance(enemyHero.Position) < 1500
			and enemyHero.IsAlive and enemyHero.IsTargetable then
			local enemyHeroPos = enemyHero.Position
			local enemyHeroRange = enemyHero.AttackRange + enemyHero.BoundingRadius
			Renderer.DrawCircle3D(enemyHeroPos, enemyHeroRange, 30, 1.0, 0xffffffff)
		end
	end
	
	-- Enemies Waypoints
    local enemies = ObjManager.Get("enemy", "heroes")
    for handle, obj in pairs(enemies) do 
		local enemyHero = obj.AsAI
		local playerPos = Player.Position
		if playerPos:Distance(enemyHero.Position) < 1500
			and enemyHero.IsAlive and enemyHero.IsVisible then
			Renderer.DrawLine(Renderer.WorldToScreen(enemyHero.Pathing.StartPos), Renderer.WorldToScreen(enemyHero.Pathing.EndPos), 1.0, 0xf0ff00ff)
		end
	end
	
	
end

local function OnTeleport(obj, name, type, duration_secs, status)
	if obj.IsHero and obj.IsEnemy then
		local enemyHero = obj.AsHero
		if type == 6 then
			Game.PrintChat(enemyHero.CharName .. " Recalling: " .. status)
		elseif type == 16 then
			Game.PrintChat(enemyHero.CharName .. " Teleporting: " .. status)
		end
	end
end

function OnLoad()  
    EventManager.RegisterCallback(Enums.Events.OnDraw, OnDraw)     
    EventManager.RegisterCallback(Enums.Events.OnTeleport, OnTeleport)    
    Game.PrintChat("Awareness Loaded !")
    return true
end
