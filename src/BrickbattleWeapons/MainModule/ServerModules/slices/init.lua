--!strict
local Reflex = require("Packages/reflex")
local BrickbattleWeaponTables = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponTables")
local BrickBattleWeaponsState = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponSlice")

export type RootProducer = Reflex.Producer<RootState, RootActions>
export type RootState = {
    BrickbattlePlayerState: BrickbattleWeaponTables.BrickbattlePlayerTable
}
type RootActions = BrickBattleWeaponsState.BrickbattleWeaponStateActions

return Reflex.combineProducers({
    BrickbattlePlayerState = BrickBattleWeaponsState.BrickbattlePlayerStateSlice,
}) :: RootProducer