require("common.log")
module("Awareness", package.seeall, log.setup)

local _SDK = _G.CoreEx
local ObjManager, EventManager, Input, Renderer, Enums, Game = _SDK.ObjectManager, _SDK.EventManager, _SDK.Input, _SDK.Renderer, _SDK.Enums, _SDK.Game
local Player = ObjManager.Player

_G.AntiAFK = false
local lastActiveGameTime = 0

local function OnTick()
	if _G.AntiAFK then
		if (Game.GetTime() - lastActiveGameTime) > 15 then
			Input.MoveTo(Player.Position)
			lastActiveGameTime = Game.GetTime()
		end
	end
end

function OnLoad()  
	EventManager.RegisterCallback(Enums.Events.OnKeyDown, function(keycode, char, lparam) 
		if keycode == 78 then  -- N Key
			_G.AntiAFK = not _G.AntiAFK 
			lastActiveGameTime = Game.GetTime()
			Game.PrintChat("AntiAFK: " .. tostring(_G.AntiAFK))
		end 
	end)
	EventManager.RegisterCallback(Enums.Events.OnTick, OnTick) 
	Game.PrintChat("AntiAFK Loaded !")
    return true
end