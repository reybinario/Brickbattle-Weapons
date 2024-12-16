--!strict
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
export type ConfigWithOptionals = {
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
export type Config = {
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

return {}