--!strict
local function getCallback(Callback)
	return script:WaitForChild("Callbacks"):WaitForChild(Callback)
end
local Settings = {
	
	-- GENERAL WEAPON SETTINGS --
	BombJump = true,
	SuperballJump = true,
	SuperballFly = true,
	SlingClimb = false,
	RocketRiding = true,
	
	RocketsExplodeSBs = false,
	MaxSafeWait = 0.25,
	
	-- DAMAGE SETTINGS -- 
	WeaponsDamageAfterDeath = true, -- You will never be able to shoot after you die.
	InstantDamage = true, -- Does not pair well with security deactivations
	TeamKill = false, -- Whether teammates can kill eachother
	AllowHumanoidChanges = true, -- Prevents admin abuse and exploiting
	TagLifetime = 1,
	
	
	-- TEAM SETTINGS --
	AutoTeamColors = true, -- Color projectiles and explosions to team colors
	ThemeOverrides = true, -- themes will override team colors if above is true
	IgnoreCertainTeams = false,
	TeamsFiltered = {"Gladiators"}, -- "neutral" teams
	TeamsFilterType = false,
	SpectatorTeamActive = false,   -- Spectators can't take or deal dmg.
	SpectatorTeamName = "Spectators", -- The name of the spectator team
	
	
	-- THEME SETTINGS --
	Themes = {
		ThemePacks = {};
		RandomSuperballColors = true; -- This overrides the Superball Colors setting below.	
		RandomPaintballColors = true;
		RandomWallColors = true;
		TrailsOmitted = {"Normal"}; -- Add theme names for them to not have trails
		DefaultTheme = "Normal"; -- The default theme that all normal users have.
		TrailFilterType = true;
		WeaponsFiltered = {"Superball","PaintballGun","Sword"};
		UseRobloxExplosions = false;
	},
	
	
	-- DOOMSPIRE SETTINGS --
	Doomspire = {
		SlingFly = true;
		RocketCollisions = true;
		BombSpawnToCam = false;
	},
	
	
	-- EXPLOSION SETTINGS --
	Explosions = {
		DestroyParts = false;
		DestroyTrowelWallsOverride = false; --If true, overrides Explosions.DestroyParts
		FlingParts = true;
		FlingBombs = true;
		FlingEnemies = true; -- will fling others' dead body parts
		FlingYou = true; -- Will fling your body parts!
		ForceFactorOnSelf = 1; --How much stronger ExplosionForces are on yourself
		LimbRemoval = true;
		ProtectTeammateWalls = false; -- won't be able to blow ur teammates walls
		ExclusionTag = "BB_NonExplodable"; -- collection service
		DebrisTime = 0; -- must be >0 for parts to be added to debris collection
		BreakJointsOnClient = true; --if set to true, clients will break welds instantly. Can cause desync issues where a weld is broken only for one client. Best for singleplayer games.
	},
	
	
	-- RICOCHET SETTINGS --
	Ricochet = {
		HalfDamageDelay = 0, -- min is one frame
		ResetStateDelay = 1/30
	},
	
	
	-- TARGETING SETTINGS --
	Targeting = { -- whitelist has priority over blacklist
		RegularIcon = "rbxassetid://507449825";
		ReloadIcon = "rbxassetid://507449806";
		DefaultIcon = "";
	},
	
	
	-- MOBILE SETTINGS --
	Mobile = {
		DoubleJumpToSwordLunge = true;
		ShootMode = "InWorld"; 
		--[[ 
		Can be "InWorld" or "UserInput", case-sensitive
			
			What's the difference?
			
			- UserInput triggers weapons at any tap other than the jump button and 
			some GUI buttons.It has no input delay.
			
			- InWorld does not trigger weapons at taps on GUIs or the joystick, but it is
			slightly delayed.
		]]
	},
	
	
	-- EXTRAPOLATION SETTINGS --
	Extrapolation = {
		Updates = { -- send regular updates about the object's position and velocity
			Slingshot = false;
			PaintballGun = false;
			Superball = true;
			Rocket = false;
			Bomb = true;
		},
		PingCompensation = {
			Rocket = false;
		}
	},
	
	
	-- SPECIFIC WEAPON SETTINGS -- 
	Bomb = {
		Damage = 101;
		ReloadTime = 5;
		BombJumpReloadTime = 0;
		MaxBombJumpPower = 200; -- in studs
		BombJumpPosWindow = .25; -- click then jump timing, must be positive
		BombJumpNegWindow = -.1; -- jump then click window, must be negative
		--TODO switch these two
		--VariableBombJumpPower = true; --Bomb jump height depends on your timing.
		BombJumpPowerFormula = "Linear";
		WalkingBombJump = false; -- if you can bomb jump as you walk
		PhysicsProperties = PhysicalProperties.new(
			0.7, -- Density
			0.3, -- Friction
			0.6, -- Elasticity
			1,   -- Friction weight
			1.1  -- Elasticity weight
		);
		MaxMassToDestroy = 150;
		ExplosionForce = 1000000;
		SelfDamage = false;
		SelfDamageMultiplier = 1;
		TeleportOnExplode = false; -- Gameboy...
		Radius = 12;
		TouchExplode = false;
		TouchExplodeSelf = false; 
		DespawnTime = 5; -- despawns after x seconds
	},
	Rocket = {
		Damage = 101;
		ReloadTime = 7;
		SpawnDistance = 6; -- increase to 6+ to shoot through walls
		InitialSpeed = 60;
		Speed = 60;
		RampUpDuration = 1;
		SelfDamage = false;
		SelfDamageMultiplier = 1;
		--FlyThroughList = {
		--	"rocket",
		--	"handle",
		--	"effect",
		--	"water",
		--	"lava",
		--	"invisitouch",
		--	"explosion",
		--	"killbrick"
		--};
		ExplosionForce = 500000;
		MaxMassToDestroy = 75;
		Radius = 4;
		ShootInsideBricks = true;
		DespawnTime = 10; -- despawns after x seconds
	},
	Slingshot = {
		Damage = 16;
		ReloadTime = 0.2;
		SpawnDistance = 3; -- increase to 4+ to shoot  through walls --Default 3
		Speed = 85;
		SelfDamage = false; -- (not recommended) if SelfKill == false will not deal self dmg
		Automatic = true;
		SlingFlyCooldown = 0;
		RicochetDamage = true;
		ShootInsideBricks = true;
		DespawnTime = 7; -- despawns after x seconds
	},
	Superball = {
		Damage = 55;
		ReloadTime = 2;
		SpawnDistance = 4; -- increase to 5+ shoot through walls
		Speed = 200;
		SelfDamage = false; -- (not recommended) if SelfKill == false will not deal self dmg
		RicochetDamage = true;
		ShootInsideBricks = true;	
		DespawnTime = 10; -- despawns after x seconds
	},
	Sword = {
		LungeDamage = 30;
		SlashDamage = 10;
		IdleDamage = 5;
		ReloadTime = 0.01;
		DoubleClickTime = 0.2; -- lunge window
		FloatAmount = 5000;
		JumpHeight = 13;
		LungeDelayTime = 0;
		LungeExtensionTime = .95;
	},
	Trowel = {
		ReloadTime = 4;
		BrickSize = Vector3.new(4, 1.2, 2.02);
		ServerBuildSpeed = 0.045;
		ClientBuildSpeed = 0.04;
		BricksPerColumn = 4;
		BricksPerRow = 3;
		Lifetime = 24.54;
		Outlines = false--true; -- the local setting will be overriden by this
	},
	PaintballGun = {
		Damage = 20;
		ReloadTime = .5;
		SpawnDistance = 3; -- increase to 5+ shoot through walls
		Speed = 200;
		SelfDamage = false; -- (not recommended) if SelfKill == false will not deal self dmg
		VectorForce = Vector3.new(0, 60, 0);
		Shape = "Ball",
		Size = Vector3.new(1, 1, 1),
		Density = 0.7,
		DespawnTime = 10; -- despawns after x seconds
		MultiplierPartNames = {
			Head = true,
			Torso = true,
			UpperTorso = true,
			LowerTorso = true,
			HumanoidRootPart = true
		};
		ShootInsideBricks = true;
		ColorResetTime = 25; -- set to 0 for no color resetting
	},
	
	
	-- CHOOSE WEAPONS --
	WeaponsFiltered = {},
	WeaponsFilterType = false,
	CustomWeaponsDirectory = nil, -- can be game.ServerStorage.Weapons, for example

	MaxReportedTimeDelay = math.huge, --In milliseconds. Always active even if Security = false. Whoops!
	CancelHitIfAboveTimeDelay = false,
	
	
	-- SECURIY SETTINGS --
	Security = {
		-- Numbers are thresholds that, if surpassed, will deactivate projectile 
		--(cause no dmg and stop replication)
		Master = false, -- If set to false, will have no security logs or repercussions
		Webhook = nil, -- Change to a string of your Discord webhook URL to notify if someone was marked as exploiting
		Initial = { -- Spawn positions and velocities
			Deactivate = true; -- No possible damage and stop replication
			Warn = true; -- Warn in output
			Superball2D = 10; -- (SpawnPosition - Head.Position).Magnitude | X and Z axes
			Superball3D = 50; -- (SpawnPosition - Head.Position).Magnitude
			Rocket2D = 10; -- (SpawnPosition - Handle.Position).Magnitude | X and Z axes
			Rocket3D = 50; -- (SpawnPosition - Handle.Position).Magnitude 
			PaintballGun2D = 10;
			PaintballGun3D = 50;
			Bomb3D = 10;	
		},
		Update = { -- Physics updates sent from each client on regular intervals
			Deactivate = true; -- No possible damage and stop replication
			Warn = true; 
			Rocket = 75; -- NewDistanceFromOrigin-OldDistanceFromOrigin
			Bomb = 100; -- (UpdatePosition - CurrentPosition).Magnitude
			BombVelocity = 500; -- (UpdateVelocity - CurrentVelocity).Magnitude
			BombTime = .5; -- NewTime-OldTime+ DT
		},
		Hit = { -- Either when projectile explodes or hits humanoid (depending on type)
			Deactivate = true; -- No possible damage and stop replication
			Warn = true;
			RocketExplode = 75; -- ExplosionDistanceFromOrigin-OldDistanceFromOrigin
			BombExplode = 30; -- (ExplosionPos - PriorPosition).Magnitude
			BombTime = 2.8;
			SuperballHit = 100; -- (HitCharPart.Position-Superball.Position).Magnitude
			RadiusMultiplier = 5; -- (ExplosionPos-HitPos).Magnitude > RadiusMultiplier*Radius
			MaxSwordKillDistance = 12;

		},
		VerifyParabola = true;
		Fallout = {
			Slingshot = 0.2;
			Superball= 0.25;
			PaintballGun = 0.1;
		},
		PSPV = true; -- Hitbox verification
		FuturePositionApproval = true;
		Ricochet = true; -- secure ricochet damage
		AllowedTime = .2;
		AcceptableDistance = .5;
		ReloadTimeMultiplier = .7 --[[
			ServerReloadCheck = Tool.ReloadTime * ReloadTimeMultiplier
			if TimeSinceLastFire>=ServerReloadCheck then
		]]
	},
	
	
	-- LOCAL MISC SETTINGS --
	LocalSettingsDefaults = { -- mostly aesthetic
		NewIcons = false;
		MobileJump = true;
		SlingshotSound = "Modern";
		RocketExplosion = "Classic";
		BombExplosion = "Modern";
		Hit = "Minecraft"; -- None for no sound
		BlockedHit = "Tyzone";
		KillHit = "Robot"; -- NOT ACTIVE AT THE MOMENT
		Themes = true;
		ThemesHighGraphics = true;
		VisualHitIndicators = true;
	},
	
	
	-- DEVELOPER SETTINGS -- 
	NativeCrosshair = true,
	
	
	-- Callbacks must simply point to a module that returns a function
	Callbacks = {
		PaintballColor = getCallback("PaintballColor"),
		RocketExplode = getCallback("RocketExplode"),
		Targeting = getCallback("Targeting"),
		BreakJoints = getCallback("BreakJoints"),
		ExplodeMaster = getCallback("ExplosionMaster")
	}
}
return Settings

