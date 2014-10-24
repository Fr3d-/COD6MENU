#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init(){
	level.rolls = [];
	level.rolls[0] = "Pirate";
	level.rolls[1] = "Gamer";
	level.rolls[2] = "PewPew";
	level.rolls[3] = "Akimbo Thumpers";
	level.rolls[4] = "105mm";
	level.rolls[5] = "One Man Army";
	level.rolls[6] = "40mm";
	level.rolls[7] = "25mm";
	level.rolls[8] = "Claymore";
	level.rolls[9] = "C4";
	level.rolls[10] = "Semtex";
	level.rolls[11] = "Frag Grenade";
	level.rolls[12] = "Throwing Knife";
	level.rolls[13] = "Gangster";
	level.rolls[14] = "CounterStrike";
	level.rolls[15] = "EMP'd";
	level.rolls[16] = "Crippled";
	level.rolls[17] = "Juggernaut";
	level.rolls[18] = "Riot Control";
	level.rolls[19] = "Sniper";
	level.rolls[20] = "Wallhack";
	level.rolls[21] = "Thermal";

	level.weaponRestrictionsEnabled = false;
}

unload(){
}

onPlayerSpawned(){
	if( !isDefined( level.hasRunModInit ) || level.hasRunModInit == false ){
		level.hasRunModInit = true;
		init();
	}

	self.roll = randomInt( level.rolls.size );

	self takeAllWeapons();
	self _clearPerks();

	self thread giveLoadout();

	self thread doHUD();

	self thread infinityAmmo();

	self waittill("death");

	self.rtdHUD destroy();
	self.rtdShader destroy();
}

doHUD(){
	self.rtdHUD = newClientHudElem( self );
	self.rtdHUD.alignX = "left";
	self.rtdHUD.alignY = "top";
	self.rtdHUD.horzAlign = "left";
	self.rtdHUD.vertAlign = "bottom";
	self.rtdHUD.x = 32;
	self.rtdHUD.y = -50;
	self.rtdHUD.foreground = true;
	self.rtdHUD.fontScale = 1.5;
	self.rtdHUD.font = "objective";
	self.rtdHUD.alpha = 1;
	self.rtdHUD.glow = 1;
	self.rtdHUD.glowColor = ( 0, 1, 0 );
	self.rtdHUD.glowAlpha = 0;
	self.rtdHUD.color = ( 1.0, 1.0, 1.0 );
	self.rtdHUD.hideWhenInMenu = true;

	self.rtdHUD setText("^1" + level.rolls[ self.roll ] );

	self.rtdShader = newClientHudElem( self );
	self.rtdShader.alignX = "left";
	self.rtdShader.alignY = "top";
	self.rtdShader.horzAlign = "left";
	self.rtdShader.vertAlign = "bottom";
	self.rtdShader.x = 0;
	self.rtdShader.y = -55;
	self.rtdShader.foreground = true;
	self.rtdShader.alpha = 1;
	self.rtdShader.hideWhenInMenu = true;
	self.rtdShader setShader( "cardicon_snakeeyes", 32, 32 );
	self.rtdShader.shader = "cardicon_snakeeyes";
}

infinityAmmo(){
	self endon("gamemodeEnd");
	self endon("disconnect");
	self endon("death");

	while( true ){
		currentWeapon = self getCurrentWeapon();

        self setWeaponAmmoClip( currentWeapon, 9999 );
        self GiveMaxAmmo( currentWeapon );
	    
        wait .1;
    }
}

setWeapon( weapon, akimbo ){
	self giveWeapon( weapon, randomInt( 8 ), akimbo );

	wait .2;

	self switchToWeapon( weapon );	
}

giveLoadout(){
	self endon("disconnect");

	switch( self.roll ){
		case 0:
			self thread setWeapon( "model1887_akimbo_fmj_mp", true );
			break;

		case 1:
			self thread setWeapon( "killstreak_ac130_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_fastsprintrecovery" ); // Lightweight
			self thread maps\mp\perks\_perks::givePerk( "specialty_quickdraw" ); // Lightweight pro
			self thread maps\mp\perks\_perks::givePerk( "specialty_marathon");
			break;

		case 2:
			self thread setWeapon( "defaultweapon_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_bulletdamage");
			break;

		case 3:
			self thread setWeapon( "m79_mp", true );
			self thread maps\mp\perks\_perks::givePerk( "specialty_explosivedamage" );
			break;

		case 4:
			self thread setWeapon("ac130_105mm_mp", false );
			break;

		case 5:
			self thread setWeapon( "onemanarmy_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_fastsprintrecovery" ); // Lightweight
			self thread maps\mp\perks\_perks::givePerk( "specialty_quickdraw" ); // Lightweight pro
			self thread maps\mp\perks\_perks::givePerk( "specialty_marathon");
			break;

		case 6:
			self thread setWeapon( "ac130_40mm_mp", false );
			break;

		case 7:
			self thread setWeapon( "ac130_25mm_mp", false );
			break;

		case 8:
			self thread setWeapon( "claymore_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_explosivedamage" );
			break;

		case 9:
			self thread setWeapon( "c4_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_explosivedamage" );
			break;

		case 10:
			self thread setWeapon("semtex_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_explosivedamage" );
			break;

		case 11:
			self thread setWeapon("frag_grenade_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_explosivedamage" );
			break;

		case 12:
			self thread setWeapon("throwingknife_mp", false );
			self maps\mp\perks\_perks::givePerk( "throwingknife_mp" );
			break;

		case 13:
			self thread setWeapon("deserteaglegold_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_bulletdamage");
			break;

		case 14:
			self thread setWeapon("ak47_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_bulletdamage");
			self allowADS( false );
			self disableProne();

			self waittill("death");
			self allowADS( true );
			break;

		case 15:
			self thread setWeapon( "fn2000_heartbeat_mp", false );
			self setEMPJammed( true );

			self waittill("death");
			self setEMPJammed( false );
			break;

		case 16:
			self thread setWeapon("scar_silencer_mp", false );
			self thread forceProne();
			break;

		case 17:
			self thread setWeapon("rpd_fmj_grip_mp", false );
			self.maxhealth = 250;
			self.health = 250;
			self.moveSpeedScaler = .5;

			self allowJump( false );
			self allowSprint( false );

			self waittill("death");

			self allowJump( true );
			self allowSprint( true );
			break;

		case 18:
			self thread setWeapon("riotshield_mp", false );
			self.maxhealth = 500;
			self.health = 500;
			self.moveSpeedScaler = .8;

			self allowJump( false );
			self allowSprint( false );

			self waittill("death");

			self allowJump( true );
			self allowSprint( true );
			break;

		case 19:
			self thread setWeapon("cheytac_fmj_xmags_mp", false );
			self thread maps\mp\perks\_perks::givePerk( "specialty_fastsnipe" ); // SoH Pro
			self thread maps\mp\perks\_perks::givePerk( "specialty_fastreload" ); // SoH
			self thread maps\mp\perks\_perks::givePerk( "specialty_fastsprintrecovery" ); // Lightweight
			self thread maps\mp\perks\_perks::givePerk( "specialty_quickdraw" ); // Lightweight pro
			self thread maps\mp\perks\_perks::givePerk( "specialty_bulletdamage" ); // Stopping power
			self thread maps\mp\perks\_perks::givePerk( "specialty_marathon");
			self thread maps\mp\perks\_perks::givePerk( "specialty_improvedholdbreath" ); // Steady aim pro
			break;

		case 20:
			self thread setWeapon("tavor_fmj_silencer_mp", false );
			self ThermalVisionFOFOverlayOn();

			self waittill("death");

			self ThermalVisionFOFOverlayOff();
			break;

		case 21:
			self thread setWeapon("p90_silencer_mp", false );

			self VisionSetNakedForPlayer("thermal_mp", 0 );

			self waittill("death");

			self VisionSetNakedForPlayer( getDvar("mapname"), 0 );
			break;

		default:
			iPrintLn("Error?");
			break;
	}
}

forceProne(){
	self endon("disconnect");
	self endon("death");

	while( true ){
		if( self getStance() != "prone"){
			self setStance("prone");
		}

		wait .2;
	}
}

disableProne(){
	self endon("disconnect");
	self endon("death");

	while( true ){
		if( self getStance() == "prone"){
			self setStance("crouch");
		}

		wait .2;
	}
}

onPlayerKilled( eInflictor, attacker, victim, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, isFauxDeath ){
	if( isDefined( attacker ) ){
		if( isPlayer( attacker ) && attacker.guid != victim.guid ){
			if( !isDefined( attacker.currKills ) || attacker.currKills == 0 ){
				attacker.currKills = 1;
			} else {
				attacker.currKills = attacker.currKills + 1;
			}

			if( attacker.currKills >= level.killsForVictory ){
				thread maps\mp\mods\_gameEnd::gameEnd( attacker );
			}

			iPrintLn( attacker.currKills );
		}
	}
}