--!strict

export type ReceivedProjectileData = {
    player: Player,
    count: number,
    position: Vector3?,
    velocity: Vector3?,
    cFrame: CFrame?,
    color: Vector3?,
    validated: boolean?, -- born-inert marker; absent for projectiles without validation
}

export type WorldApplier = {
    create: (ReceivedProjectileData) -> Part,
    applyInitialState: (Part, ReceivedProjectileData) -> (),
    getParent: (ReceivedProjectileData) -> Instance,
}

return nil
