--!strict
local Reflex = require("Packages/reflex")
local Immut = require("Packages/immut")
local BrickbattleWeaponTables = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponTables")

export type BrickbattleWeaponStateActions = {
    setStatState: (playerName: string, numb: number, stat: string) -> (),
    removeStatState: (playerName: string, stat: string) -> (),
}

type BrickbattlePlayerStateEntry = {
    [string]: BrickbattleWeaponTables.BrickbattlePlayerTable
}
local initialState: BrickbattlePlayerStateEntry = {}
local BrickbattlePlayerStateSlice = Reflex.createProducer(initialState, {
    setTotalProjectileStateForPlayer = function(state, playerName: string, weapon: string, projectileData: any)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[weapon] = projectileData
            return draft
        end)
    end,
    setStatWeaponState = function(state, playerName: string, weapon: string, weaponCount: number, Amount: any)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[weapon][weaponCount] = Amount
            return draft
        end)
    end,
    removeSingleProjectileState = function(state, playerName: string, weapon: string, projectileCount: number, newState: any)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then return end
            playerData[weapon][projectileCount] = newState
            return draft
        end)
    end
})

return {BrickbattlePlayerStateSlice = BrickbattlePlayerStateSlice}