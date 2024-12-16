opt write_checks = true
opt server_output = "./src/BrickbattleWeapons/MainModule/VulcanServer/Network/NetworkServer.luau"
opt client_output = "./src/BrickbattleWeapons/MainModule/VulcanClient/Network/NetworkClient.luau"

event superballCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        position: Vector3,
        velocity: Vector3,
        color: Vector3,
    },
}
event superballCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        position: Vector3,
        velocity: Vector3,
    },
}
event superballUpdate = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        position: Vector3,
        velocity: Vector3,
    },
}
event superballReplicate = {
    from: Server,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        player: Instance,
        position: Vector3,
        velocity: Vector3,
    },
}
event superballHit = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        hitPart: Instance?,
    },
}

event pelletCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        position: Vector3,
        velocity: Vector3,
    },
}
event pelletCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        position: Vector3,
        velocity: Vector3,
    },
}
event pelletUpdate = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        position: Vector3,
        velocity: Vector3,
    },
}
event pelletReplicate = {
    from: Server,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        player: Instance,
        position: Vector3,
        velocity: Vector3,
    },
}
event pelletHit = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        hitPart: Instance?,
    },
}

event paintballCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        position: Vector3,
        velocity: Vector3,
        color: Vector3,
    },
}
event paintballCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        position: Vector3,
        velocity: Vector3,
        color: Vector3,
    },
}
event paintballUpdate = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        position: Vector3,
        velocity: Vector3,
    },
}
event paintballReplicate = {
    from: Server,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        player: Instance,
        position: Vector3,
        velocity: Vector3,
    },
}
event paintballHit = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        position: Vector3,
        hitPart: Instance?,
    },
}
event paintballExplodeReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        position: Vector3,
    },
}

event rocketCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        cFrame: CFrame,
    },
}
event rocketCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        cFrame: CFrame,
    },
}
event rocketUpdate = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        distance: u16,
    },
}
event rocketReplicate = {
    from: Server,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        player: Instance,
        distance: u16,
    },
}
event rocketExplode = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        distance: u16,
        explodedParts: Instance?[],
    },
}
event rocketExplodeReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        distance: u16,
    },
}

event bombCreate = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        position: Vector3,
    },
}
event bombCreateReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        position: Vector3,
    },
}
event bombUpdate = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        position: Vector3,
        velocity: Vector3,
        tickTime: f32,
    },
}
event bombReplicate = {
    from: Server,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        packetCount: u16,
        player: Instance,
        position: Vector3,
        velocity: Vector3,
        tickTime: f32,
    },
}
event bombExplode = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        position: Vector3,
        explodedParts: Instance?[],
    },
}
event bombExplodeReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        count: u16,
        player: Instance,
        position: Vector3,
    },
}

event swordGripUpdate = {
    from: Client,
    type: Unreliable,
    call: SingleAsync,
    data: struct {
        grip: enum { Out, Up, Down }
    }
}

event trowelPlace = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        cFrame: CFrame
    }
}

event deleteProjectile = {
    from: Client,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        projectileType: enum { Superball, Pellet, Paintball, Rocket, Bomb, Wall },
        count: u16,
    }
}
event deleteProjectileReplicate = {
    from: Server,
    type: Reliable,
    call: SingleAsync,
    data: struct {
        projectileType: enum { Superball, Pellet, Paintball, Rocket, Bomb, Wall },
        count: u16,
        player: Instance,
    }
}
