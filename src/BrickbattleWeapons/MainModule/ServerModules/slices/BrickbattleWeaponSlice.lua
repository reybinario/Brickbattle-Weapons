--!strict
local Reflex = require("Packages/reflex")
local Immut = require("Packages/immut")
local BrickbattleWeaponTables = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponTables")

export type BrickbattleWeaponStateActions = {
    setTotalProjectileStateForPlayer: (playerName: string, weapon: string, projectileData: any) -> (),
    setStatWeaponState: (playerName: string, weapon: string, weaponCount: number, Amount: any) -> (),
    removeSingleProjectileState: (playerName: string, weapon: string, projectileCount: number, newState: any) -> (),
}

type BrickbattlePlayerStateEntry = {
    [string]: BrickbattleWeaponTables.BrickbattlePlayerTable
}
local initialState: BrickbattlePlayerStateEntry = {}
local BrickbattlePlayerStateSlice = Reflex.createProducer(initialState, {
    setTotalProjectileStateForPlayer = function(state, playerName: string, weapon: string, projectileData: any)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then
                error("playerData for brickbattle player state is nil")
            end            
            playerData[weapon] = projectileData
            return draft
        end)
    end,
    setStatWeaponState = function(state, playerName: string, weapon: string, weaponCount: number, Amount: any)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then
                error("playerData for brickbattle player state is nil")
            end
            playerData[weapon][weaponCount] = Amount
            return draft
        end)
    end,
    removeSingleProjectileState = function(state, playerName: string, weapon: string, projectileCount: number, newState: any)
		return Immut.produce(state, function(draft) 
            local playerData = draft[playerName]
            if playerData == nil then
                error("playerData for brickbattle player state is nil")
            end            
            playerData[weapon][projectileCount] = newState
            return draft
        end)
    end
})

return {BrickbattlePlayerStateSlice = BrickbattlePlayerStateSlice}