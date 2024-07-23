--!strict
local Reflex = require("Packages/reflex")
local Table = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponTables")
local State = require("src/BrickbattleWeapons/MainModule/ServerModules/slices/BrickbattleWeaponSlice")

export type RootProducer = Reflex.Producer<RootState, RootActions>
export type RootState = {
    BrickbattleWeaponState: Table.BrickbattleWeaponTable
}
type RootActions = State.BrickbattleWeaponStateActions

return Reflex.combineProducers({
    BrickbattleWeaponState = State.BrickbattlePlayerStateSlice,
}) :: RootProducer