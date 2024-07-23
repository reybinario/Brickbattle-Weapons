--!strict
export type BrickbattleWeaponTable = {
  theme: number, -- we'll use enums
  superballs: {
      [number]: { -- count value (incremented each time weapon is fired by this player)
          position: any, 
          velocity: any,
          hitCount: number, -- number of times the superball has ricocheted (we will use this calculate damaging halving)
          packetCount: number, -- the number of packets we've received and accepted for this projectile
          timestamp: number
      }
  },
  pellets: {
      [number]: {
          position: any,
          velocity: any, 
          hitCount: number,
          packetCount: number,
          timestamp: number
      }
  },
  paintballs: {
      [number]: {
          position: any, 
          velocity: any, 
          hasHit: boolean, 
          packetCount: number,
          timestamp: number
      }
  },
  rockets: {
      [number]: {
          originCframe: any,  -- using distance for updates and only cframe when we initially create the rocket, to set the origin position
          distance: number,
          velocity: any, 
          hasExploded: boolean,
          packetCount: number,
          timestamp: number
      }
  },
  bombs: {
      [number]: {
          position: any, 
          velocity: any, 
          tickTime: number,
          hasExploded: boolean, -- derivable from tick time but we can keep a bool here for convenience
          packetCount: number,
          timestamp: number
      }
  },
  walls: {
      [number]: any 
  }
}

return {}