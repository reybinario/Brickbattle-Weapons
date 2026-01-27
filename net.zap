opt write_checks = true
opt server_output = "./src/BrickbattleWeapons/MainModule/VulcanServer/Network/NetworkServer.luau"
opt client_output = "./src/BrickbattleWeapons/MainModule/VulcanClient/Network/NetworkClient.luau"
opt types_output = "./src/BrickbattleWeapons/MainModule/VulcanClient/Common/NetworkTypes.luau"
opt remote_scope = "VULCAN_BRICKBATTLE_WEAPONS"
opt remote_folder = "VULCAN_BRICKBATTLE_WEAPONS_ZAP"

type movingProjectileCreateData = struct {
    count: u16,
    position: Vector3,
    velocity: Vector3,
}
type movingProjectileCreateReplicateData = struct {
    count: u16,
    player: Instance,
    position: Vector3,
    velocity: Vector3,
}
type coloredMovingProjectileCreateData = struct {
    count: u16,
    position: Vector3,
    velocity: Vector3,
    color: Vector3,
}
type coloredMovingProjectileCreateReplicateData = struct {
    count: u16,
    player: Instance,
    position: Vector3,
    velocity: Vector3,
    color: Vector3
}
type movingProjectileUpdateData = struct {
    count: u16,
    position: Vector3,
    velocity: Vector3,
}
type movingProjectileReplicateData = struct {
    count: u16,
    player: Instance,
    position: Vector3,
    velocity: Vector3,
}
type hitData = struct {
    count: u16,
    hitPart: Instance?,
}
type positionalHitData = struct {
    count: u16,
    position: Vector3,
    hitPart: Instance?,
}
type positionalReplicateData = struct {
    count: u16,
    player: Instance,
    position: Vector3,
}

type superballCreateData = movingProjectileCreateData
event superballCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: superballCreateData,
}
type superballCreateReplicateData = movingProjectileCreateReplicateData
event superballCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: superballCreateReplicateData,
}
type superballUpdateData = movingProjectileUpdateData
event superballUpdate = {
    from: Client,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: superballUpdateData,
}
type superballReplicateData = movingProjectileReplicateData
event superballReplicate = {
    from: Server,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: superballReplicateData,
}
type superballHitData = hitData
event superballHit = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: superballHitData,
}
type pelletCreateData = movingProjectileCreateData
event pelletCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: pelletCreateData,
}
type pelletCreateReplicateData = movingProjectileCreateReplicateData
event pelletCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: pelletCreateReplicateData,
}
type pelletUpdateData = movingProjectileUpdateData
event pelletUpdate = {
    from: Client,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: pelletUpdateData,
}
type pelletReplicateData = movingProjectileReplicateData
event pelletReplicate = {
    from: Server,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: pelletReplicateData,
}
type pelletHitData = hitData
event pelletHit = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: pelletHitData,
}
type paintballCreateData = coloredMovingProjectileCreateData
event paintballCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: paintballCreateData,
}
type paintballCreateReplicateData = coloredMovingProjectileCreateReplicateData
event paintballCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: paintballCreateReplicateData,
}
type paintballUpdateData = movingProjectileUpdateData
event paintballUpdate = {
    from: Client,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: paintballUpdateData,
}
type paintballReplicateData = movingProjectileReplicateData
event paintballReplicate = {
    from: Server,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: paintballReplicateData,
}
type paintballHitData = positionalHitData
event paintballHit = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: paintballHitData,
}
type paintballExplodeReplicateData = positionalReplicateData
event paintballExplodeReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: paintballExplodeReplicateData,
}
type rocketCreateData = struct {
    count: u16,
    cFrame: CFrame,
}
event rocketCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: rocketCreateData,
}
type rocketCreateReplicateData = struct {
    count: u16,
    player: Instance,
    cFrame: CFrame,
}
event rocketCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: rocketCreateReplicateData,
}
type rocketUpdateData = struct {
    count: u16,
    distance: u16,
}
event rocketUpdate = {
    from: Client,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: rocketUpdateData,
}
type rocketReplicateData = struct {
    count: u16,
    player: Instance,
    distance: u16,
}
event rocketReplicate = {
    from: Server,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: rocketReplicateData,
}
type rocketExplodeData = struct {
    count: u16,
    distance: u16,
    explodedParts: Instance[]?
}
event rocketExplode = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: rocketExplodeData,
}
type rocketExplodeReplicateData = struct {
    count: u16,
    player: Instance,
    distance: u16,
}
event rocketExplodeReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: rocketExplodeReplicateData,
}
type bombCreateData = struct {
    count: u16,
    position: Vector3,
}
event bombCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: bombCreateData,
}
type bombCreateReplicateData = positionalReplicateData
event bombCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: bombCreateReplicateData,
}
type bombUpdateData = struct {
    count: u16,
    position: Vector3,
    velocity: Vector3,
    tickTime: f32 -- TODO: optimize this
}
event bombUpdate = {
    from: Client,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: bombUpdateData,
}
type bombReplicateData = struct {
    count: u16,
    player: Instance,
    position: Vector3,
    velocity: Vector3,
    tickTime: f32,
}
event bombReplicate = {
    from: Server,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: bombReplicateData,
}
type bombExplodeData = struct {
    count: u16,
    position: Vector3,
    explodedParts: Instance[]?,
}
event bombExplode = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: bombExplodeData,
}
type bombExplodeReplicateData = struct {
    count: u16,
    player: Instance,
    position: Vector3,
}
event bombExplodeReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: bombExplodeReplicateData,
}
type swordGripUpdateData = struct {
    grip: enum { Out, Up, Down }
}
event swordGripUpdate = {
    from: Client,
    type: OrderedUnreliable,
    call: SingleAsync,
    data: swordGripUpdateData,
}
type wallCreateData = struct {
    count: u16,
    cFrame: CFrame
}
event wallCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: wallCreateData,
}
type networkedProjectileType = enum { superball, pellet, paintball, rocket, bomb, wall }
type deleteProjectileData = struct {
    projectileType: networkedProjectileType,
    count: u16,
}
event deleteProjectile = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: deleteProjectileData,
}
type deleteProjectileReplicateData = struct {
    projectileType: networkedProjectileType,
    count: u16,
    player: Instance,
}
event deleteProjectileReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: deleteProjectileReplicateData,
}