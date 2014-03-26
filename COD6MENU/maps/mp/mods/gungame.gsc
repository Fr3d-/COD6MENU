#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init(){
	level.gungameLevels = [];
	level.gungameLevels[0] = "usp_silencer_mp";
	level.gungameLevels[1] = "coltanaconda_akimbo_fmj_mp";
	level.gungameLevels[2] = "deserteagle_akimbo_mp";
	level.gungameLevels[3] = "deserteaglegold_mp";
	level.gungameLevels[4] = "glock_mp";
	level.gungameLevels[5] = "pp2000_akimbo_mp";
	level.gungameLevels[6] = "ranger_mp";
	level.gungameLevels[7] = "striker_grip_mp";
	level.gungameLevels[8] = "spas12_silencer_xmags_mp";
	level.gungameLevels[9] = "model1887_akimbo_fmj_mp";
	level.gungameLevels[10] = "ump45_silencer_thermal_mp";
	level.gungameLevels[11] = "uzi_akimbo_mp";
	level.gungameLevels[12] = "ak47_mp";
	level.gungameLevels[13] = "m16_mp";
	level.gungameLevels[14] = "fn2000_heartbeat_thermal_mp";
	level.gungameLevels[15] = "fal_fmj_mp";
	level.gungameLevels[16] = "m79_mp";
	level.gungameLevels[17] = "rpg_mp";	
	level.gungameLevels[18] = "at4_mp";	
	level.gungameLevels[19] = "rpd_mp";	
	level.gungameLevels[20] = "sa80_mp";
	level.gungameLevels[21] = "m240_mp";
	level.gungameLevels[22] = "wa2000_mp";	
	level.gungameLevels[23] = "barrett_mp";	
	level.gungameLevels[24] = "cheytac_mp";
	level.gungameLevels[25] = "riotshield_mp";
	level.gungameLevels[26] = "ac130_25mm_mp";
	level.gungameLevels[27] = "ac130_40mm_mp";
	level.gungameLevels[28] = "ac130_105mm_mp";
	
	level.weaponRestrictionsEnabled = false;

	//registerTimeLimitDvar( level.gameType, 0, 0, 1440 );
	//registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
}

unload(){
}

destroyOn( hudElem, notification ){
	self endon("disconnect");
	self endon("death");

	self waittill( notification );

	hudElem destroy();
}

onPlayerSpawned(){
	if( !defined( level.hasRunModInit ) || level.hasRunModInit == false ){
		level.hasRunModInit = true;
		init();
	}

	if( !defined( self.gungameLevel ) ){
		self.gungameLevel = 0;
	}

	self takeAllWeapons();
	self _clearPerks();

	if( isSubStr( level.gungameLevels[ self.gungameLevel ], "akimbo" ) ){
		self giveWeapon( level.gungameLevels[ self.gungameLevel ], randomInt( 8 ), true );
	} else {
		self giveWeapon( level.gungameLevels[ self.gungameLevel ], randomInt( 8 ), false );
	}

	wait .05;

	self switchToWeapon( level.gungameLevels[ self.gungameLevel ] );

	self GiveMaxAmmo( level.gungameLevels[ self.gungameLevel ] );

	self.moveSpeedScaler = 1.1;

	self thread maps\mp\perks\_perks::givePerk( "specialty_fastsnipe" ); // SoH Pro
	self thread maps\mp\perks\_perks::givePerk( "specialty_fastreload" ); // SoH
	self thread maps\mp\perks\_perks::givePerk( "specialty_fastsprintrecovery" ); // Lightweight
	self thread maps\mp\perks\_perks::givePerk( "specialty_quickdraw" ); // Lightweight pro
	self thread maps\mp\perks\_perks::givePerk( "specialty_bulletdamage" ); // Stopping power
	self thread maps\mp\perks\_perks::givePerk( "specialty_marathon");
	self thread maps\mp\perks\_perks::givePerk( "specialty_improvedholdbreath" ); // Steady aim pro

	self thread checkIfUsingOtherWeapons();
	self thread doHUD();

	self waittill("death");

	self.gungameHud destroy();
}

doHUD(){
	self.gungameHud = NewClientHudElem( self );
	self.gungameHud.alignX = "left";
	self.gungameHud.alignY = "top";
	self.gungameHud.horzAlign = "left";
	self.gungameHud.vertAlign = "bottom";
	self.gungameHud.x = 0;
	self.gungameHud.y = -40;
	self.gungameHud.foreground = true;
	self.gungameHud.fontScale = 1.5;
	self.gungameHud.font = "objective";
	self.gungameHud.alpha = 1;
	self.gungameHud.glow = 1;
	self.gungameHud.glowColor = ( 0, 1, 0 );
	self.gungameHud.glowAlpha = 0;
	self.gungameHud.color = ( 1.0, 1.0, 1.0 );
	self.gungameHud.hideWhenInMenu = true;

	while( true ){
		self.gungameHud setText("LEVEL: " + self.gungameLevel + "/" + ( level.gungameLevels.size - 1 ) );

		self waittill("updateHUD");
	}
}


checkIfUsingOtherWeapons(){
	self endon("gamemodeEnd");
	self endon("WonGungame");
	self endon("disconnect");
	self endon("death");

	while( true ){
		currWep = self getCurrentWeapon();

		if( currWep != level.gungameLevels[ self.gungameLevel ] ){
			self takeAllWeapons();

			wait .05;

			if( isSubStr( level.gungameLevels[ self.gungameLevel ], "akimbo" ) ){
				self giveWeapon( level.gungameLevels[ self.gungameLevel ], randomInt( 8 ), true );
			} else {
				self giveWeapon( level.gungameLevels[ self.gungameLevel ], randomInt( 8 ), false );
			}

			wait .05;

			self switchToWeapon( level.gungameLevels[ self.gungameLevel ] );

			self GiveMaxAmmo( level.gungameLevels[ self.gungameLevel ] );
		}

		wait .2;
	}
}

onPlayerKilled( eInflictor, attacker, victim, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, isFauxDeath ){
	if( sMeansOfDeath == "MOD_MELEE" ){
		if ( IsSubStr( sWeapon, "riotshield" ) ){
			promotePlayer( attacker );
		}

		demotePlayer( victim );

		attacker thread maps\mp\gametypes\_hud_message::hintMessage("^1HUMILIATION!");
	} else {
		if( defined( attacker ) ){
			if( isPlayer( attacker ) && attacker.guid != victim.guid ){
				promotePlayer( attacker );
			} else {
				demotePlayer( victim );
			}
		}
	}
}

demotePlayer( ply ){
	ply thread maps\mp\gametypes\_hud_message::hintMessage("^1DEMOTED!");

	if( ply.gungameLevel <= 0 ){
		ply.gungameLevel = 0;
	} else {
		ply.gungameLevel = ply.gungameLevel - 1;
	}
}

promotePlayer( ply ){
	ply.gungameLevel = ply.gungameLevel + 1;

	if( ply.gungameLevel == level.gungameLevels.size ){
		thread maps\mp\mods\_gameEnd::gameEnd( ply );
	}

	ply notify("updateHUD");
}