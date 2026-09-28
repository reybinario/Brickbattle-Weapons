--!strict

export type ReceivedProjectileData = {
    player: Player,
    count: number,
    position: Vector3?,
    velocity: Vector3?,
    cFrame: CFrame?,
    color: Vector3?,
}

export type WorldApplier = {
    create: (ReceivedProjectileData) -> Part,
    applyInitialState: (Part, ReceivedProjectileData) -> (),
    getParent: (ReceivedProjectileData) -> Instance,
}

return nil
