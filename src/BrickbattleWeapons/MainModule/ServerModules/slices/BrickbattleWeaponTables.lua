--!strict
export type BrickbattlePlayerTable = {
  theme: number, -- we'll use enums
  superballs: {
      [number]: { -- count value (incremented each time weapon is fired by this player)
          position: Vector3, 
          velocity: Vector3,
          hitCount: number, -- number of times the superball has ricocheted (we will use this calculate damaging halving)
          packetCount: number, -- the number of packets we've received and accepted for this projectile
          timestamp: number
      }
  },
  pellets: {
      [number]: {
          position: Vector3,
          velocity: Vector3, 
          hitCount: number,
          packetCount: number,
          timestamp: number
      }
  },
  paintballs: {
      [number]: {
          position: Vector3, 
          velocity: Vector3, 
          hasHit: boolean, 
          packetCount: number,
          timestamp: number
      }
  },
  rockets: {
      [number]: {
          originCframe: CFrame,  -- using distance for updates and only cframe when we initially create the rocket, to set the origin position
          distance: number,
          velocity: Vector3, 
          hasExploded: boolean,
          packetCount: number,
          timestamp: number
      }
  },
  bombs: {
      [number]: {
          position: Vector3, 
          velocity: Vector3, 
          tickTime: number,
          hasExploded: boolean, -- derivable from tick time but we can keep a bool here for convenience
          packetCount: number,
          timestamp: number
      }
  },
  walls: {
      [Model]: any 
  }
}

return {}