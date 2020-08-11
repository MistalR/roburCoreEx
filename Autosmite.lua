require("common.log")
module("autosmite", package.seeall, log.setup)

-- AutoSmite
-- Adapted from SoNiice previous release

local _SDK = _G.CoreEx
local ObjManager, EventManager, Input, Renderer, Enums, Game = _SDK.ObjectManager, _SDK.EventManager, _SDK.Input, _SDK.Renderer, _SDK.Enums, _SDK.Game
local SpellSlots, SpellStates = Enums.SpellSlots, Enums.SpellStates 
local Player = ObjManager.Player

_G.autoSmiteEnabled = true
local smiteSpell = nil

local smiteDamage = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}
local monstersList = {
    ["SRU_Baron12.1.1"] = {name = "Baron", smite = true},
    ["SRU_RiftHerald17.1.1"] = {name = "Rift Herald", smite = true},
    ["SRU_Dragon_Elder6.5.1"] = {name = "Elder Dragon", smite = true},
    ["SRU_Dragon_Water6.3.1"] = {name = "Ocean Dragon", smite = true},
    ["SRU_Dragon_Fire6.2.1"] = {name = "Infernal Dragon", smite = true},
    ["SRU_Dragon_Earth6.4.1"] = {name = "Mountain Dragon", smite = true},
    ["SRU_Dragon_Air6.1.1"] = {name = "Air Dragon", smite = true},
    ["SRU_Blue7.1.1"] = {name = "Blue", smite = true},
    ["SRU_Blue1.1.1"] = {name = "Blue", smite = true},
    ["SRU_Red10.1.1"] = {name = "Red", smite = true},
    ["SRU_Red4.1.1"] = {name = "Red", smite = true},
    ["Sru_Crab16.1.1"] = {name = "Crab", smite = false},
    ["SRU_Krug5.1.1"] = {name = "Krug", smite = false},
    ["SRU_Gromp13.1.1"] = {name = "Gromp", smite = false},
    ["SRU_Murkwolf2.1.1"] = {name = "Wolf", smite = false},
    ["SRU_Razorbeak3.1.1"] = {name = "Raptor", smite = false}
}

local function OnTick()		
	if _G.autoSmiteEnabled then
	
		local myPos, mySmiteRange = Player.Position, (500 + Player.BoundingRadius)
		local monsters = ObjManager.Get("neutral", "minions")
		
		for networkId, obj in pairs(monsters) do

			local objAsTarget = obj.AsAttackableUnit
            if
                objAsTarget.IsVisible and objAsTarget.IsAlive and objAsTarget.IsTargetable and
                myPos:Distance(objAsTarget.Position) <= mySmiteRange and
                monstersList[objAsTarget.Name]
                then
                    if smiteDamage[Player.Level] >= objAsTarget.Health and monstersList[objAsTarget.Name].smite then
                       Input.Cast(smiteSpell, objAsTarget)
                    end
            end
        end
	end
end

local function OnDraw()
	local smiteStatus = nil
	if _G.autoSmiteEnabled then 
		smiteStatus = "AutoSmite: Enabled"
	else
		smiteStatus = "AutoSmite: Disabled"
	end
    Renderer.DrawText(Renderer.WorldToScreen(Player.Position), {x=500,y=500}, smiteStatus, 0xFF0000FF)
end

function OnLoad() 

	-- Check if Player has smite
	if string.find(string.lower(Player:GetSpell(SpellSlots.Summoner1).Name), "smite") then
		smiteSpell = SpellSlots.Summoner1
	elseif string.find(string.lower(Player:GetSpell(SpellSlots.Summoner2).Name), "smite") then
		smiteSpell = SpellSlots.Summoner2
	end

	if smiteSpell ~= nil then
		EventManager.RegisterCallback(Enums.Events.OnTick, OnTick)
		EventManager.RegisterCallback(Enums.Events.OnDraw, OnDraw)
		EventManager.RegisterCallback(Enums.Events.OnKeyUp, function(keycode, char, lparam) 
			if char == "M" then
				if _G.autoSmiteEnabled then 
					_G.autoSmiteEnabled = false
				else
					_G.autoSmiteEnabled = true
				end
			end
		end)
		
		Game.PrintChat("AutoSmite Loaded !")
		return true
	end
	
end