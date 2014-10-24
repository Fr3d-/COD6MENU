#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init(){
	foreach( ply in level.players ){
		ply setClientDvar( "lowAmmoWarningNoAmmoColor2", "0" );
		ply setClientDvar( "lowAmmoWarningNoAmmoColor1", "0" );			
		ply setClientDvar( "lowAmmoWarningNoReloadColor2", "0" );	
		ply setClientDvar( "lowAmmoWarningNoReloadColor1", "0" );
	}	

	thread watchForWinner();

	level.weaponRestrictionsEnabled = false;
}

unload(){
	foreach( ply in level.players ){
		ply setClientDvar( "lowAmmoWarningNoAmmoColor2", "1 0.25098 0.301961 1" );
		ply setClientDvar( "lowAmmoWarningNoAmmoColor1", "0.8 0.25098 0.301961 0.8" );			
		ply setClientDvar( "lowAmmoWarningNoReloadColor2", "0.701961 0.701961 0.301961 1" );	
		ply setClientDvar( "lowAmmoWarningNoReloadColor1", "0.701961 0.701961 0.301961 0.701961" );	
	}
}

changeClass(){
	self notify("menuresponse", game["menu_team"], "axis");
	wait .25;
	self notify("menuresponse", "changeclass", "class2" );
}

onPlayerSpawned(){
	if( ( !defined( level.hasRunModInit ) || level.hasRunModInit == false ) && self isHost() ){
		level.hasRunModInit = true;
		init();
	}

	if( !defined( self.lives ) ){		
		self.lives = 3;
	}

	self forceSpectator();



	self takeAllWeapons();
	self _clearPerks();

	self thread giveLoadout();

	self thread doHUD();	

	self waittill("death");

	self.OITCShader destroy();
	self.OITCShader2 destroy();
	self.OITCShader3 destroy();
}

watchForWinner(){
	self endon("disconnect");
	self endon("gamemodeEnd");

	wait 20;

	for( ;; ){
		level.alivePlayers = 0;

		foreach( ply in level.players ){
			if( defined( ply.lives ) && ply.lives > 0 ){
				level.alivePlayers++;
				level.winner = ply;
			}
		}

		if( level.alivePlayers < 2 ){
			thread maps\mp\mods\_gameEnd::gameEnd( level.winner );
			break;
		}

		wait 1;
	}
}

forceSpectator(){
	if( self.team != "spectator" && defined( self.lives ) && self.lives < 1 ){
		self thread maps\mp\gametypes\_hud_message::hintMessage("^1You are dead.");
		self notify("menuresponse", game["menu_team"], "spectator");
	}
}

doHUD(){
	if( self.lives > 2 ){
		self.OITCShader = newClientHudElem( self );
		self.OITCShader.alignX = "noscale";
		self.OITCShader.alignY = "noscale";
		self.OITCShader.horzAlign = "right";
		self.OITCShader.vertAlign = "bottom";
		self.OITCShader.x = -130;
		self.OITCShader.y = -60;
		self.OITCShader.foreground = true;
		self.OITCShader.alpha = 1;
		self.OITCShader.hideWhenInMenu = true;
		self.OITCShader setShader( "cardicon_skullaward", 32, 32 );
		self.OITCShader.shader = "cardicon_skullaward";
	}

	if( self.lives > 1 ){
		self.OITCShader2 = newClientHudElem( self );
		self.OITCShader2.alignX = "noscale";
		self.OITCShader2.alignY = "noscale";
		self.OITCShader2.horzAlign = "right";
		self.OITCShader2.vertAlign = "bottom";
		self.OITCShader2.x = -95;
		self.OITCShader2.y = -60;
		self.OITCShader2.foreground = true;
		self.OITCShader2.alpha = 1;
		self.OITCShader2.hideWhenInMenu = true;
		self.OITCShader2 setShader( "cardicon_skullaward", 32, 32 );
		self.OITCShader2.shader = "cardicon_skullaward";
	}

	if( self.lives > 0 ){
		self.OITCShader3 = newClientHudElem( self );
		self.OITCShader3.alignX = "noscale";
		self.OITCShader3.alignY = "noscale";
		self.OITCShader3.horzAlign = "right";
		self.OITCShader3.vertAlign = "bottom";
		self.OITCShader3.x = -60;
		self.OITCShader3.y = -60;
		self.OITCShader3.foreground = true;
		self.OITCShader3.alpha = 1;
		self.OITCShader3.hideWhenInMenu = true;
		self.OITCShader3 setShader( "cardicon_skullaward", 32, 32 );
		self.OITCShader3.shader = "cardicon_skullaward";
	}
}

setWeapon( weapon, akimbo ){
	self giveWeapon( weapon, randomInt( 8 ), akimbo );

	wait .2;

	self switchToWeapon( weapon );	
}

giveLoadout(){
	self endon("disconnect");

	self setWeapon( "coltanaconda_tactical_mp", false );

	self setWeaponAmmoClip("coltanaconda_tactical_mp", 1 );
	self setWeaponAmmoStock("coltanaconda_tactical_mp", 0 );

	self.moveSpeedScaler = 1.2;

	self thread maps\mp\perks\_perks::givePerk( "specialty_fastsprintrecovery" ); // Lightweight
	self thread maps\mp\perks\_perks::givePerk( "specialty_marathon");
	self thread maps\mp\perks\_perks::givePerk( "specialty_improvedholdbreath" ); // Steady aim pro
}

giveBullet(){
	currClip = self getWeaponAmmoClip( "coltanaconda_tactical_mp" );

	if( currClip < 6 )
		self setWeaponAmmoClip( "coltanaconda_tactical_mp", currClip + 1 );
}

onPlayerKilled( eInflictor, attacker, victim, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, isFauxDeath ){
	if( defined( attacker ) ){
		if( isPlayer( attacker ) ){
			if( attacker.guid != victim.guid ){
				attacker thread giveBullet();
			}
		}
	}

	if( defined( victim.lives ) )
		victim.lives = victim.lives - 1;
}

onPlayerDamaged( eInflictor, eAttacker, victim, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime ){
}