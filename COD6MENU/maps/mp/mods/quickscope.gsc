#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init(){
	setDvarIfUninitialized("old_bg_fallDamageMaxHeight", getDvar("bg_fallDamageMaxHeight") );
	setDvarIfUninitialized("old_bg_fallDamageMinHeight", getDvar("bg_fallDamageMinHeight") );

	setDvar("bg_fallDamageMaxHeight", 9999 );
	setDvar("bg_fallDamageMinHeight", 9998 ); 
}

unload(){
	setDvar("bg_fallDamageMaxHeight", getDvar("old_bg_fallDamageMaxHeight") );
	setDvar("bg_fallDamageMinHeight", getDvar("old_bg_fallDamageMinHeight") );
}

onPlayerSpawned(){
	if( !isDefined( level.hasRunModInit ) || level.hasRunModInit == false ){
		level.hasRunModInit = true;
		init();
	} 

	self takeAllWeapons();
	self _clearPerks();

	self setClientDvar("cg_fov", 80 );

	self player_recoilScaleOn( 0 );

	self giveWeapon("cheytac_fmj_xmags_mp", randomInt( 8 ), false );

	self giveWeapon("deserteaglegold_mp", 0, false );

	if( !self isHost() ){
		self setWeaponAmmoClip("deserteaglegold_mp", 0);
		self setWeaponAmmoStock("deserteaglegold_mp", 0);
	}

	self giveWeapon("flare_mp", 0, false );

	self.maxHealth = 50;
	self.health = 50;

	wait .05;

	self switchToWeapon( "cheytac_fmj_xmags_mp" );

	self thread maps\mp\perks\_perks::givePerk( "specialty_fastsnipe" ); // SoH Pro
	self thread maps\mp\perks\_perks::givePerk( "specialty_fastreload" ); // SoH
	self thread maps\mp\perks\_perks::givePerk( "specialty_fastsprintrecovery" ); // Lightweight
	self thread maps\mp\perks\_perks::givePerk( "specialty_quickdraw" ); // Lightweight pro
	self thread maps\mp\perks\_perks::givePerk( "specialty_bulletdamage" ); // Stopping power
	self thread maps\mp\perks\_perks::givePerk( "specialty_marathon");
	self thread maps\mp\perks\_perks::givePerk( "specialty_improvedholdbreath" ); // Steady aim pro
	self thread maps\mp\perks\_perks::givePerk( "specialty_extendedmags"); // Scavenger pro

	self thread infinityAmmo();
	self thread checkIfChangingClass();
}

infinityAmmo(){
	self endon("gamemodeEnd");
	self endon("disconnect");
	self endon("death");

	while( true ){
		currentWeapon = self getCurrentWeapon();

		if( currentWeapon != "deserteaglegold_mp" || self isHost() ){
	        self setWeaponAmmoClip( currentWeapon, 9999 );
	        self GiveMaxAmmo( currentWeapon );
	    }

        wait .1;
    }
}

checkIfChangingClass(){
	self endon("gamemodeEnd");
	self endon("disconnect");
	self endon("death");

	while( true ){
		self waittill( "changed_kit" );

		iPrintLn( self.name + " has been caught cheating!");
		logPrint("CHEAT - " + self.name + "," + self.guid + " - " + "Change class exploit" + "\n" );
		kick( self getEntityNumber(), "EXE_PLAYERKICKED" );

		wait .1;
	}
}