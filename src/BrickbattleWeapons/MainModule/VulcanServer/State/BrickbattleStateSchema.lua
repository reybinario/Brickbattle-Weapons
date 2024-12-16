--!strict
export type SuperballState = { -- count value (incremented each time weapon is fired by this player)
    position: Vector3, 
    velocity: Vector3,
    hitCount: number, -- number of times the superball has ricocheted (we will use this calculate damaging halving)
    packetCount: number, -- the number of packets we've received and accepted for this projectile
    timestamp: number,
    originPosition: Vector3,
    originTimestamp: number,
    active: boolean,
    count: number
}
export type SlingshotState = {
    position: Vector3,
    velocity: Vector3, 
    hitCount: number,
    packetCount: number,
    timestamp: number,
    originPosition: Vector3,
    originTimestamp: number,
    active: boolean,
    count: number
}
export type PaintballState = {
    position: Vector3, 
    velocity: Vector3, 
    hasHit: boolean, 
    packetCount: number,
    timestamp: number,
    originPosition: Vector3,
    originTimestamp: number,
    active: boolean,
    count: number
}
export type RocketState = {
    distance: number,
    velocity: Vector3, 
    hasExploded: boolean,
    packetCount: number,
    timestamp: number,
    originCframe: CFrame,  -- using distance for updates and only cframe when we initially create the rocket
    originTimestamp: number,
    active: boolean,
    count: number
}
export type BombState = {
    position: Vector3, 
    velocity: Vector3, 
    tickTime: number,
    hasExploded: boolean, -- derivable from tick time but we can keep a bool here for convenience
    packetCount: number,
    timestamp: number,
    originPosition: Vector3,
    originTimestamp: number,
    active: boolean,
    count: number
}
export type WallState = Model
export type BrickbattleState = SuperballState | SlingshotState | PaintballState | RocketState | BombState | WallState
export type BrickbattlePlayerStateSlice = {
    lastUsed: {
        Superball: number,
        Slingshot: number,
        PaintballGun: number,
        Rocket: number,
        Bomb: number,
        Trowel: number,
        Sword: number
    },
    counts: {
        Superball: number,
        Slingshot: number,
        PaintballGun: number,
        Rocket: number,
        Bomb: number,
        Trowel: number
    },
    superballs: {
        [number]: SuperballState
    },
    pellets: {
        [number]: SlingshotState
    },
    paintballs: {
        [number]: PaintballState
    },
    rockets: {
        [number]: RocketState
    },
    bombs: {
        [number]: BombState
    },
    walls: {
        [number]: WallState
    }
}
export type GlobalBrickbattleState = {
    [Player]: BrickbattlePlayerStateSlice
}
return {}