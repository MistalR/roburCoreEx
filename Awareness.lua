require("common.log")
module("Awareness", package.seeall, log.setup)

local _SDK = _G.CoreEx
local ObjManager, EventManager, Renderer, Enums, Game = _SDK.ObjectManager, _SDK.EventManager, _SDK.Renderer, _SDK.Enums, _SDK.Game
local Player = ObjManager.Player

local function OnDraw()

	-- Turret Range
    local enemies = ObjManager.Get("enemy", "turrets")
    for handle, obj in pairs(enemies) do 
		if obj.IsVisible and not obj.IsDead then
			local turretRange = 750.0 + obj.BoundingRadius
			Renderer.DrawCircle3D(obj.Position, turretRange, 20, 1.0, 0xFF0000FF)
		end
	end
	
end

function OnLoad()  
    EventManager.RegisterCallback(Enums.Events.OnDraw, OnDraw)    
	Game.PrintChat("Awareness Loaded !")
    return true
end
