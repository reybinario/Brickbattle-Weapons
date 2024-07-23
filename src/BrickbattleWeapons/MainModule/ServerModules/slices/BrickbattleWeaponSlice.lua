--!strict
local Reflex = require("Packages/reflex")
local Immut = require("Packages/immut")
local Table = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponTables")

export type BrickbattleWeaponStateActions = {
    setStatState: (playerName: string, numb: number, stat: string) -> (),
    removeStatState: (playerName: string, stat: string) -> (),
}

type Data = {
    [string]: Table.BrickbattleWeaponTable
}
local initialState: Data = {}
local BrickbattleWeaponsStateSlice = Reflex.createProducer(initialState, {
    setStatState = function(state, playerName: string, numb: number, stat: string)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[stat] = numb
            return draft
        end)
    end,
    removeStatState = function(state, playerName: string, stat: string)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[stat] = nil
            return draft
        end)
    end
})

return {BrickbattleWeaponsStateSlice = BrickbattleWeaponsStateSlice}