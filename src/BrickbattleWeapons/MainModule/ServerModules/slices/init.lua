--!strict
local Reflex = require("Packages/reflex")
local Table = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponTables")
local State = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponSlice")

export type RootProducer = Reflex.Producer<RootState, RootActions>
export type RootState = {
    BrickbattlePlayerState: Table.BrickbattlePlayerTable
}
type RootActions = State.BrickbattleWeaponStateActions

return Reflex.combineProducers({
    BrickbattlePlayerState = State.BrickbattlePlayerStateSlice,
}) :: RootProducer