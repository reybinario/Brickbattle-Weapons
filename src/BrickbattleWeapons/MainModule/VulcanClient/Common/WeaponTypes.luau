--!strict
export type WeaponType = "Bomb" | "PaintballGun" | "Rocket" | "Slingshot" | "Superball" | "Trowel" | "Sword"
export type ProjectilesType = "bombs" | "paintballs" | "rockets" | "pellets" | "superballs" | "walls"
export type ProjectileType = "bomb" | "paintball" | "rocket" | "pellet" | "superball" | "wall"


local WeaponTypes = {}

local Projectile = {
    bomb = "bomb",
    paintball = "paintball",
    rocket = "rocket",
    pellet = "pellet",
    superball = "superball",
    wall = "wall"
}
local Projectiles = {
    bombs = "bombs",
    paintballs = "paintballs",
    rockets = "rockets",
    pellets = "pellets",
    superballs = "superballs",
    walls = "walls"
}
local Weapons = {
    Bomb = "Bomb",
    PaintballGun = "PaintballGun",
    Rocket = "Rocket",
    Slingshot = "Slingshot",
    Superball = "Superball",
    Trowel = "Trowel",
    Sword = "Sword"
}
WeaponTypes.Projectiles = Projectiles
WeaponTypes.Projectile = Projectile
WeaponTypes.Weapons = Weapons

local projectileToWeaponMap = {
    bomb = "Bomb",
    paintball = "PaintballGun",
    rocket = "Rocket",
    pellet = "Slingshot",
    superball = "Superball",
    wall = "Trowel"
}

local weaponToProjectileMap = {
    Bomb = "bomb",
    PaintballGun = "paintball",
    Rocket = "rocket",
    Slingshot = "pellet",
    Superball = "superball",
    Trowel = "wall"
}

function WeaponTypes.fromProjectileToWeapon(projectile: ProjectileType): WeaponType
    return projectileToWeaponMap[projectile]
end

function WeaponTypes.fromWeaponToProjectile(weapon: WeaponType): ProjectileType
    if weapon == "Sword" then
        error("Impossible use of WeaponTypes.fromWeaponToProjectile: sword does not have a corresponding projectile type.")
    end
    return weaponToProjectileMap[weapon]
end

return WeaponTypes