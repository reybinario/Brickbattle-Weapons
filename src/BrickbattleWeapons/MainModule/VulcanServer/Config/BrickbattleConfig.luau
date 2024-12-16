--!strict

local TableUtils = require(script.Parent.TableUtils)

export type PartConfig = {
    Shape: Enum.PartType,
    PhysicalProperties: PhysicalProperties,
    Size: Vector3,
}
export type ProjectileConfig = {
    Speed: number,
    SpawnDistance: number,
    ShootInsideBricks: boolean
}
export type ExplosionConfig = {
    PartConfig: PartConfig,
    ExplosionForce: number,
    MaxMassToDestroy: number
}
export type BrickbattleConfigWithOptionals = {
    SuperballJump: boolean?,
    SuperballFly: boolean?,
    SlingClimb: boolean?,
    RocketRide: boolean?,

    WeaponsDamageAfterDeath: boolean?,
    InstantDamage: boolean?,
    TeamKill: boolean?,
    AllowHumanoidChanges: boolean?,
    TagLifetime: number?,

    AutoTeamColors: boolean?,
    SpectatorTeams: boolean?,
    NeutralTeams: boolean?,

    SlingFly: boolean?,
    RocketCollisions: boolean?,
    BombSpawnToCam: boolean?,

    Destruction: {
        DestroyParts: boolean?,
        DestroyTrowelWalls: boolean?,
        FlingParts: boolean?,
        FlingBombs: boolean?,
        FlingEnemies: boolean?,
        FlingTeammates: boolean?,
        FlingYou: boolean?,
        ForceFactorOnSelf: number?,
        LimbRemoval: boolean?,
        ProtectTeammatesWalls: boolean?,
    }?,

    CursorIcon: string?,
    ReloadCursorIcon: string?,

    BombJump: {
        Enabled: boolean?,
        ReloadTime: number?,
        MaxPower: number?,
        PositiveWindow: number?,
        NegativeWindow: number?,
        CanDoWhileWalking: boolean?,
    }?,
    Bomb: {
        Damage: number?,
        SelfDamage: boolean?,

        ReloadTime: number?,

        PartConfig: PartConfig?,
        ExplosionConfig: ExplosionConfig?,

        SpawnsRelativeToCam: boolean?,
        Lifetime: number?,
    }?,
    Rocket: {
        Damage: number?,
        SelfDamage: boolean?,

        ReloadTime: number?,

        PartConfig: PartConfig?,
        ProjectileConfig: ProjectileConfig?,
        ExplosionConfig: ExplosionConfig?,

        Lifetime: number?,
    }?,
    Slingshot: {
        Damage: number?,
        SelfDamage: boolean?,

        Automatic: boolean?,
        ReloadTime: number?,

        PartConfig: PartConfig?,
        ProjectileConfig: ProjectileConfig?,

        Lifetime: number?,
    }?,
    Superball: {
        Damage: number?,
        SelfDamage: boolean?,
        RicochetDamage: boolean?,

        ReloadTime: number?,

        PartConfig: PartConfig?,
        ProjectileConfig: ProjectileConfig?,

        Lifetime: number?,
    }?,
    Sword: {
        LungeDamage: number?,
        SlashDamage: number?,
        IdleDamage: number?,

        ReloadTime: number?,
        DoubleClickTime: number?,

        FloatAmount: number?,
        JumpHeight: number?,

        LungeDelayTime: number?,
        LungeExtensionTime: number?,
    }?,
    Trowel: {
        ReloadTime: number?,
        PartConfig: PartConfig?,
        ServerBuildSpeed: number?,
        ClientBuildSpeed: number?,
        BricksPerColumn: number?,
        BricksPerRow: number?,
        Lifetime: number?,
    }?,
    PaintballGun: {
        Damage: number?,
        SelfDamage: boolean?,

        ReloadTime: number?,

        PartConfig: PartConfig?,
        ProjectileConfig: ProjectileConfig?,
        FloatForce: Vector3?,

        Lifetime: number?,
    }?,

    MaxSafeWait: number?,
    MaxReportedTimeDelay: number?,
}
export type BrickbattleConfig = {
    SuperballJump: boolean,
    SuperballFly: boolean,
    SlingClimb: boolean,
    RocketRide: boolean,

    WeaponsDamageAfterDeath: boolean,
    InstantDamage: boolean,
    TeamKill: boolean,
    AllowHumanoidChanges: boolean,
    TagLifetime: number,

    AutoTeamColors: boolean,
    SpectatorTeams: boolean,
    NeutralTeams: boolean,

    SlingFly: boolean,
    RocketCollisions: boolean,
    BombSpawnToCam: boolean,

    Destruction: {
        DestroyParts: boolean,
        DestroyTrowelWalls: boolean,
        FlingParts: boolean,
        FlingBombs: boolean,
        FlingEnemies: boolean,
        FlingTeammates: boolean,
        FlingYou: boolean,
        ForceFactorOnSelf: number,
        LimbRemoval: boolean,
        ProtectTeammatesWalls: boolean,
    },

    CursorIcon: string,
    ReloadCursorIcon: string,

    BombJump: {
        Enabled: boolean,
        ReloadTime: number,
        MaxPower: number,
        PositiveWindow: number,
        NegativeWindow: number,
        CanDoWhileWalking: boolean
    },
    Bomb: {
        Damage: number,
        SelfDamage: boolean,

        ReloadTime: number,

        PartConfig: PartConfig,
        ExplosionConfig: ExplosionConfig,

        SpawnsRelativeToCam: boolean,
        Lifetime: number
    },
    Rocket: {
		Damage: number,
        SelfDamage: boolean,

        ReloadTime: number,

        PartConfig: PartConfig,
        ProjectileConfig: ProjectileConfig,
        ExplosionConfig: ExplosionConfig,

        Lifetime: number
	},
    Slingshot: {
        Damage: number,
        SelfDamage: boolean,

        Automatic: boolean,
        ReloadTime: number,

        PartConfig: PartConfig,
        ProjectileConfig: ProjectileConfig,

        Lifetime: number
    },
    Superball: {
        Damage: number,
        SelfDamage: boolean,
        RicochetDamage: boolean,

        ReloadTime: number,

        PartConfig: PartConfig,
        ProjectileConfig: ProjectileConfig,

        Lifetime: number
    },
    Sword: {
        LungeDamage: number,
		SlashDamage: number,
		IdleDamage: number,

		ReloadTime: number,
		DoubleClickTime: number,

		FloatAmount: number,
		JumpHeight: number,

		LungeDelayTime: number,
		LungeExtensionTime: number
    },
    Trowel: {
		ReloadTime: number,
		PartConfig: PartConfig,
		ServerBuildSpeed: number,
		ClientBuildSpeed: number,
		BricksPerColumn: number,
		BricksPerRow: number,
		Lifetime: number
	},
    PaintballGun: {
        Damage: number,
        SelfDamage: boolean,

        ReloadTime: number,

        PartConfig: PartConfig,
        ProjectileConfig: ProjectileConfig,
        FloatForce: Vector3,

        Lifetime: number
    },

    MaxSafeWait: number,
    MaxReportedTimeDelay: number,
}

local DEFAULT_ROBLOX_PHYSICAL_PROPERTIES: PhysicalProperties = Instance.new("Part").CustomPhysicalProperties

local config: BrickbattleConfig = {
    SuperballJump = true,
    SuperballFly = false,
    SlingClimb = true,
    RocketRide = true,

    WeaponsDamageAfterDeath = true,
    InstantDamage = true,
    TeamKill = false,
    AllowHumanoidChanges = true,
    TagLifetime = 1,

    AutoTeamColors = true,
    SpectatorTeams = true,
    NeutralTeams = true,

    SlingFly = false,
    RocketCollisions = false,
    BombSpawnToCam = false,

    Destruction = {
        DestroyParts = false,
        DestroyTrowelWalls = false,
        FlingParts = true,
        FlingBombs = true,
        FlingEnemies = true,
        FlingTeammates = false,
        FlingYou = true,
        ForceFactorOnSelf = 1,
        LimbRemoval = false,
        ProtectTeammatesWalls = false
    },

    CursorIcon = "rbxassetid://507449825",
    ReloadCursorIcon = "rbxassetid://507449806",

    BombJump = {
        Enabled = true,
        ReloadTime = 15,
        MaxPower = 200,
        PositiveWindow = .25,
        NegativeWindow = -.10,
        CanDoWhileWalking = false
    },
    Bomb = {
        Damage = 101,
        SelfDamage = true,

		ReloadTime = 5;

        PartConfig = {
            PhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.6, 1, 1.1),
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(2, 2, 2)
        },
        ExplosionConfig = {
            ExplosionForce = 1000000,
            MaxMassToDestroy = 150,
            PartConfig = {
                PhysicalProperties = DEFAULT_ROBLOX_PHYSICAL_PROPERTIES,
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(24, 24, 24)
            }
        },

        SpawnsRelativeToCam = false,
        Lifetime = 5
    },
    Rocket = {
		Damage = 100,
        SelfDamage = true,

        ReloadTime = 7,

        PartConfig = {
            PhysicalProperties = DEFAULT_ROBLOX_PHYSICAL_PROPERTIES,
            Shape = Enum.PartType.Block,
            Size = Vector3.new(1, 1, 4)
        },
        ProjectileConfig = {
            ShootInsideBricks = false,
            SpawnDistance = 6,
            Speed = 60
        },
        ExplosionConfig = {
            ExplosionForce = 500000,
            MaxMassToDestroy = 75,
            PartConfig = {
                PhysicalProperties = DEFAULT_ROBLOX_PHYSICAL_PROPERTIES,
                Shape = Enum.PartType.Ball,
                Size = Vector3.new(8, 8, 8)
            }
        },

        Lifetime = 10
	},
    Slingshot = {
        Damage = 11,
        SelfDamage = false,

        Automatic = true,
        ReloadTime = 2,

        PartConfig = {
            PhysicalProperties = DEFAULT_ROBLOX_PHYSICAL_PROPERTIES,
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(1, 1, 1)
        },
        ProjectileConfig = {
            ShootInsideBricks = false,
            SpawnDistance = 3,
            Speed = 85
        },

        Lifetime = 7
    },
    Superball = {
        Damage = 55,
        SelfDamage = false,
        RicochetDamage = true,

        ReloadTime = 2,

        PartConfig = {
            PhysicalProperties = PhysicalProperties.new(0.7, 0, 1, 1, 1),
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(2, 2, 2)
        },
        ProjectileConfig = {
            ShootInsideBricks = false,
            SpawnDistance = 4,
            Speed = 200
        },

        Lifetime = 8
    },
    Sword = {
        LungeDamage = 30,
		SlashDamage = 10,
		IdleDamage = 5,
		ReloadTime = 0.01,
		DoubleClickTime = 0.2,
		FloatAmount = 5000,
		JumpHeight = 13,
		LungeDelayTime = 0,
		LungeExtensionTime = .95
    },
    Trowel = {
		ReloadTime = 4,
		PartConfig = {
            PhysicalProperties = DEFAULT_ROBLOX_PHYSICAL_PROPERTIES,
            Shape = Enum.PartType.Block,
            Size = Vector3.new(4, 1.2, 2.02)
        },
		ServerBuildSpeed = 0.045,
		ClientBuildSpeed = 0.04,
		BricksPerColumn = 4,
		BricksPerRow = 3,
		Lifetime = 24.54,
	},
    PaintballGun = {
        Damage = 11,
        SelfDamage = false, 

        ReloadTime = .5,

        PartConfig = {
            PhysicalProperties = DEFAULT_ROBLOX_PHYSICAL_PROPERTIES,
            Shape = Enum.PartType.Ball,
            Size = Vector3.new(1, 1, 1)
        },
        ProjectileConfig = {
            ShootInsideBricks = false,
            SpawnDistance = 3,
            Speed = 300
        },
        FloatForce = Vector3.new(0, 60, 0),

        Lifetime = 10
    },

    MaxSafeWait = 0.25,
    MaxReportedTimeDelay = math.huge,
}

local BrickbattleConfig = {}

function BrickbattleConfig.processRequestedConfiguration(requestedConfig: BrickbattleConfigWithOptionals): BrickbattleConfig
    TableUtils.overwriteTable(config, requestedConfig)
    TableUtils.printTable(config)
    return config
end

function BrickbattleConfig.serveClientConfig(remoteFunction: RemoteFunction)
    remoteFunction.OnServerInvoke = function(player: Player)
        print(player.Name, "requested configuration, serving...")
        return config
    end
end

function BrickbattleConfig.get(): BrickbattleConfig
    return config
end

return BrickbattleConfig


