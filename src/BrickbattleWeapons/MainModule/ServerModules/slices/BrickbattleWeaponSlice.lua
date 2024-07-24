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
local BrickbattlePlayerStateSlice = Reflex.createProducer(initialState, {
    setPlayerWeaponState = function(state, playerName: string,weapon: string, Data: {})
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[weapon] = Data
            return draft
        end)
    end,
    setStatWeaponState = function(state, playerName: string, weapon: string, weaponCount: number, Amount: number)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[weapon][weaponCount] = Amount
            return draft
        end)
    end,
    removeStatState = function(state, playerName: string, weapon: string, weaponCount: number)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[weapon][weaponCount] = nil
            return draft
        end)
    end
})

return {BrickbattlePlayerStateSlice = BrickbattlePlayerStateSlice}