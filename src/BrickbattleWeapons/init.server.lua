--!strict
local id = script.MainModule
-- Full settings not contained in this loader
local Settings = {
	-- GENERAL WEAPON SETTINGS --
	BombJump = false,
	SuperballJump = true,
	SuperballFly = true,
	SlingClimb = false,
	RocketRiding = true,
	
	MaxSafeWait = 0.25,

	-- DAMAGE SETTINGS -- 
	WeaponsDamageAfterDeath = true, -- You will never be able to shoot after you die.
	InstantDamage = true, -- Does not pair well with security deactivations
	TeamKill = false, -- Whether teammates can kill eachother
	AllowHumanoidChanges = false, -- Prevents admin abuse and exploiting

	-- TEAM SETTINGS --
	AutoTeamColors = true, -- Color projectiles and explosions to team colors
	ThemeOverrides = true, -- themes will override team colors if above is true
	IgnoreCertainTeams = true,
	TeamsFiltered = {"Gladiators","Practice"}, -- "neutral" teams
	TeamsFilterType = false,
	SpectatorTeamActive = true,   -- Spectators can't take or deal dmg.
	SpectatorTeamName = "Spectators", -- The name of the spectator team

	-- THEME SETTINGS --
	Themes = {
		ThemePacks = {game.ReplicatedStorage.CustomThemes};
		RandomSuperballColors = false; -- This overrides the Superball Colors setting below.	
		RandomPaintballColors = true;
		RandomWallColors = false;
		TrailsOmitted = {"Normal","Team Color"}; -- Add theme names for them to not have trails
		DefaultTheme = "Normal"; -- The default theme that all normal users have.
		TrailFilterType = true;
		WeaponsFiltered = {"Superball","PaintballGun","Sword"};
		ExplosionType = "Standard"; -- "Standard", "RedBall", or "Natural"
	},
	
	Explosions = {
		LimbRemoval = false;
		FlingYou = false; -- Will fling your body parts! 
	},
	
	WeaponsFiltered = {},
	WeaponsFilterType = false,

	-- DOOMSPIRE SETTINGS --
	Doomspire = {
		SlingFly = true;
		RocketCollisions = false;
		BombSpawnToCam = false;
	},

	-- MOBILE SETTINGS --
	Mobile = {
		DoubleJumpToSwordLunge = true;
		ShootMode = "InWorld"; --[[ Can be "InWorld" or "UserInput", case-sensitive
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
			Rocket = true;
			Bomb = true;
			--Test BBL/CR comparison
		}
	},

	-- SPECIFIC WEAPON SETTINGS -- 
	Bomb = {
		Damage = 101;
		ReloadTime = 5;
		BombJumpReloadTime = 15;
		MaxBombJumpPower = 200; -- Absolutely NOT in studs! power is approx. sqrt(2*Gravity*Height)
		BombJumpPosWindow = .15; -- click then jump timing, must be positive
		BombJumpNegWindow = -.01; -- jump then click window, must be negative
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
		MaxMassToDestroy = 75;
		ExplosionForce = 1000000;
		SelfDamage = true;
		TeleportOnExplode = false; -- Gameboy... (DOESNT WORK YET)
		Radius = 12;
	},
	Rocket = {
		Damage = 101;
		ReloadTime = 7;
		SpawnDistance = 6; -- increase to 6+ to shoot through walls
		InitialSpeed = 60;
		Speed = 60;
		RampUpDuration = 1;
		SelfDamage = true;
		ExplosionForce = 500000;
		MaxMassToDestroy = 25;
		Radius = 4;
		-- This is a ModuleScript that returns a function.
		-- The function returns a boolean (true/false).
		-- 
		--ShootInsideBricks = false
	},
	Slingshot = {
		Damage = 16;
		ReloadTime = 0.2;
		SpawnDistance = 3; -- increase to 4+ to shoot  through walls --Default 3
		Speed = 85;
		SelfDamage = false; -- (not recommended) if SelfKill == false will not deal self dmg
		Automatic = true;
		--ShootInsideBricks = false;
	},
	Superball = {
		Damage = 55;
		ReloadTime = 2;
		SpawnDistance = 4; -- increase to 5+ shoot through walls
		Speed = 200;
		SelfDamage = false; -- (not recommended) if SelfKill == false will not deal self dmg
		--ShootInsideBricks = false;
	},
	Sword = {
		LungeDamage = 30;
		SlashDamage = 10;
		IdleDamage = 5;
		ReloadTime = 0.01;
		DoubleClickTime = 0.2; -- lunge window
		FloatAmount = 5000;
		JumpHeight = 17;
		LungeDelayTime = 0;
		LungeExtensionTime = .8;
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
		--ShootInsideBricks = false;
	},

	MaxReportedTimeDelay = 1000, --In milliseconds. Always active even if Security = false. Whoops!
	CancelHitIfAboveTimeDelay = false,

	-- SECURIY SETTINGS --
	Security = {
		Master = false, -- If set to false, will have no security logs or repercussions
	},

	LocalSettingsDefaults = {
		RocketExplosion = "Classic";
		Hit = "Ping";
		Themes = true,
		ThemesHighGraphics = true
	},
	
	SendRemoteOnDelete = true,
	NativeCrosshair = true,
}
require(id)(Settings)
