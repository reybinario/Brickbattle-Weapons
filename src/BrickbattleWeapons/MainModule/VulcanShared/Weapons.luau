--!strict
export type WeaponType = "Bomb" | "Paintball" | "Rocket" | "Slingshot" | "Superball" | "Trowel"
export type ProjectilesType = "bombs" | "paintballs" | "rockets" | "pellets" | "superballs" | "walls"
export type ProjectileType = "bomb" | "paintball" | "rocket" | "pellet" | "superball" | "wall"


local WeaponEnums = {}

local Projectiles = {
    bomb = "bomb",
    paintball = "paintball",
    rocket = "rocket",
    pellet = "pellet",
    superball = "superball",
    wall = "wall"
}
local Weapons = {
    Bomb = "Bomb",
    Paintball = "Paintball",
    Rocket = "Rocket",
    Slingshot = "Slingshot",
    Superball = "Superball",
    Trowel = "Trowel"
}
WeaponEnums.Projectiles = Projectiles
WeaponEnums.Weapons = Weapons

return WeaponEnums
