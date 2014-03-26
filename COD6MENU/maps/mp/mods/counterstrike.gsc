#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

CONST_MOVESPEED = 1.35;
CONST_SNEAKSPEED = 0.75;

init(){
	level.healthRegenDisabled = true;
	level.weaponRestrictionsEnabled = false;

	setDvar("g_hardcore", 1 );
	setDvar("g_teamname_allies", "Counter-Terrorists" );
	setDvar("g_teamname_axis", "Terrorists" );

	setDvar("player_footstepsThreshhold", 150 );

	level.radarMode["allies"] = "normal_radar";
	level.radarMode["axis"] = "normal_radar";
}

unload(){
	level.healthRegenDisabled = false;
	level.weaponRestrictionsEnabled = true;

	level.hasRunModInit = false;
}

onPlayerSpawned(){
	if( !defined( level.hasRunModInit ) || level.hasRunModInit == false ){
		level.hasRunModInit = true;
		init();
	}

	if( !defined( self.hasSetup ) ){
		self clientInit();

		self.hasSetup = true;
	}

	foreach( primary in self getWeaponsListPrimaries() ){
		iPrintLn( weaponClass( primary ) );
	}

	//self takeAllWeapons();
	self _clearPerks();
	
	setDvar("cg_drawCrosshair", 1 );

	self.armor = 100;
	self.maxarmor = 100;
	self.money = 16000;

	self allowADS( false );
	self allowSprint( false );
	self.moveSpeedScaler = CONST_MOVESPEED;
	self thread maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");

	self thread disableProne();

	self notifyOnPlayerCommand("sneak", "+breath_sprint");
	self thread watchSneak();

	self thread maps\mp\perks\_perks::givePerk( "specialty_fastsnipe" ); // SoH Pro
	self thread maps\mp\perks\_perks::givePerk( "specialty_fastreload" ); // SoH
	self thread maps\mp\perks\_perks::givePerk( "specialty_fastsprintrecovery" ); // Lightweight
	self thread maps\mp\perks\_perks::givePerk( "specialty_quickdraw" ); // Lightweight pro
	self thread maps\mp\perks\_perks::givePerk( "specialty_bulletdamage" ); // Stopping power
	self thread maps\mp\perks\_perks::givePerk( "specialty_marathon");
	self thread maps\mp\perks\_perks::givePerk( "specialty_improvedholdbreath" ); // Steady aim pro

	self thread doHUD();
}

clientInit(){
	level.radarMode[ self.guid ] = "normal_radar";
	self.radarMode = "normal_radar";
	self.hasRadar = true;
	self setClientDvar("compassRadarUpdateTime", 0 );
}

disableProne(){
	self endon("disconnect");
	self endon("death");

	while( true ){
		if( self getStance() == "prone"){
			self setStance("crouch");
		}

		wait .1;
	}
}

watchSneak(){
	self endon("disconnect");
	self endon("death");

	for( ;; ){
		self waittill("sneak");

		self.moveSpeedScaler = CONST_SNEAKSPEED;
		self thread maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");

		self waittill("sneak");
		self.moveSpeedScaler = CONST_MOVESPEED;
		self thread maps\mp\gametypes\_weapons::updateMoveSpeedScale("primary");
	}
}

doHUD(){
	self thread HPHUD();
	self thread armorHUD();
	self thread ammoHUD();
	self thread moneyHUD();
}

HPHUD(){
	self endon("disconnect");
	self endon("death");

	xPos = -40;
	yPos = 0;

	margin = 5;

	self.oldHealth = self.health;

	self.HPHUD = newClientHudElem( self );
	self.HPHUD.alignX = "noscale";
	self.HPHUD.alignY = "noscale";
	self.HPHUD.horzAlign = "left";
	self.HPHUD.vertAlign = "bottom";
	self.HPHUD.x = xPos + 16 + margin;
	self.HPHUD.y = yPos;
	self.HPHUD.foreground = true;
	self.HPHUD.fontScale = 1.5;
	self.HPHUD.font = "objective";
	self.HPHUD.alpha = 1;
	self.HPHUD.glow = 1;
	self.HPHUD.glowColor = ( 0, 1, 0 );
	self.HPHUD.glowAlpha = 0;
	self.HPHUD.color = ( 1.0, 1.0, 0 );
	self.HPHUD.hideWhenInMenu = true;
	self.HPHUD setText( self.health );

	self.HPShader = newClientHudElem( self );
	self.HPShader.alignX = "noscale";
	self.HPShader.alignY = "noscale";
	self.HPShader.horzAlign = "left";
	self.HPShader.vertAlign = "bottom";
	self.HPShader.x = xPos;
	self.HPShader.y = yPos + 1;
	self.HPShader.foreground = true;
	self.HPShader.alpha = 1;
	self.HPShader.hideWhenInMenu = true;
	self.HPShader setShader( "hint_health", 16, 16 );
	self.HPShader.shader = "hint_health";
	self.HPShader.color = ( 1, 1, 0 );

	margin = 5;

	self.HPBGShader = newClientHudElem( self );
	self.HPBGShader.alignX = "noscale";
	self.HPBGShader.alignY = "noscale";
	self.HPBGShader.horzAlign = "left";
	self.HPBGShader.vertAlign = "bottom";
	self.HPBGShader.x = xPos - margin;
	self.HPBGShader.y = yPos + 1 - margin;
	self.HPBGShader.foreground = false;
	self.HPBGShader.alpha = .6;
	self.HPBGShader.hideWhenInMenu = true;
	self.HPBGShader setShader( "black", 62, margin + 16 + margin );
	self.HPBGShader.shader = "black";

	self thread destroyOnDeath( self.HPShader );
	self thread destroyOnDeath( self.HPHUD );
	self thread destroyOnDeath( self.HPBGShader );

	self thread HPHUDThink();
}

HPHUDThink(){
	self endon("disconnect");
	self endon("death");


	for( ;; ){
		if( self.health != self.oldHealth ){
			spacing = "";

			if( self.health / 10 > 1 ){
				spacing += " ";
			} else {
				spacing += "  ";
			}

			self.HPHUD setText( spacing + self.health );
			self.HPHUD.color = ( 1, ( self.health / 100 ), 0 );
			self.HPShader.color = ( 1, ( self.health / 100 ), 0 );

			self.oldHealth = self.health;
		}
		
		wait .1;
	}
}

armorHUD(){
	self endon("disconnect");
	self endon("death");

	xPos = 100;
	yPos = 0;
	margin = 5;

	self.oldarmor = self.armor;

	self.armorHUD = newClientHudElem( self );
	self.armorHUD.alignX = "noscale";
	self.armorHUD.alignY = "noscale";
	self.armorHUD.horzAlign = "left";
	self.armorHUD.vertAlign = "bottom";
	self.armorHUD.x = xPos + 16 + margin;
	self.armorHUD.y = yPos;
	self.armorHUD.foreground = true;
	self.armorHUD.fontScale = 1.5;
	self.armorHUD.font = "objective";
	self.armorHUD.alpha = 1;
	self.armorHUD.glow = 1;
	self.armorHUD.glowColor = ( 0, 1, 0 );
	self.armorHUD.glowAlpha = 0;
	self.armorHUD.color = ( 1.0, 1.0, 0 );
	self.armorHUD.hideWhenInMenu = true;
	self.armorHUD setText( self.armor );

	self.armorShader = newClientHudElem( self );
	self.armorShader.alignX = "noscale";
	self.armorShader.alignY = "noscale";
	self.armorShader.horzAlign = "left";
	self.armorShader.vertAlign = "bottom";
	self.armorShader.x = xPos;
	self.armorShader.y = yPos + 1;
	self.armorShader.foreground = true;
	self.armorShader.alpha = 1;
	self.armorShader.hideWhenInMenu = true;
	self.armorShader setShader( "cardicon_helmet_army", 16, 16 );
	self.armorShader.shader = "cardicon_helmet_army";
	self.armorShader.color = ( 1, 1, 1 );

	margin = 5;

	self.ArmorBGShader = newClientHudElem( self );
	self.ArmorBGShader.alignX = "noscale";
	self.ArmorBGShader.alignY = "noscale";
	self.ArmorBGShader.horzAlign = "left";
	self.ArmorBGShader.vertAlign = "bottom";
	self.ArmorBGShader.x = xPos - margin;
	self.ArmorBGShader.y = yPos + 1 - margin;
	self.ArmorBGShader.foreground = false;
	self.ArmorBGShader.alpha = .6;
	self.ArmorBGShader.hideWhenInMenu = true;
	self.ArmorBGShader setShader( "black", 62, margin + 16 + margin );
	self.ArmorBGShader.shader = "black";

	self thread destroyOnDeath( self.armorShader );
	self thread destroyOnDeath( self.armorHUD );
	self thread destroyOnDeath( self.ArmorBGShader );

	self thread armorHUDThink();
}

armorHUDThink(){
	self endon("disconnect");
	self endon("death");


	for( ;; ){
		if( self.armor != self.oldarmor ){
			self.armorHUD setText( self.armor );

			self.oldarmor = self.armor;
		}
		
		wait .1;
	}
}

ammoHUD(){
	self endon("disconnect");
	self endon("death");

	xPos = -60;
	yPos = 0;

	margin = 5;

	self.currWep = self getCurrentWeapon();
	self.ammoClip = self getWeaponAmmoClip( self.currWep );
	self.ammoStock = self getWeaponAmmoStock( self.currWep );

	self.ammoHUD = newClientHudElem( self );
	self.ammoHUD.alignX = "noscale";
	self.ammoHUD.alignY = "noscale";
	self.ammoHUD.horzAlign = "right";
	self.ammoHUD.vertAlign = "bottom";
	self.ammoHUD.x = xPos + 16 + margin;
	self.ammoHUD.y = yPos;
	self.ammoHUD.foreground = true;
	self.ammoHUD.fontScale = 1.5;
	self.ammoHUD.font = "objective";
	self.ammoHUD.alpha = 1;
	self.ammoHUD.glow = 1;
	self.ammoHUD.glowColor = ( 0, 1, 0 );
	self.ammoHUD.glowAlpha = 0;
	self.ammoHUD.color = ( 1.0, 1.0, 0 );
	self.ammoHUD.hideWhenInMenu = true;
	self.ammoHUD setText( self.ammoClip + " |  " + self.ammoStock );

	self.ammoShader = newClientHudElem( self );
	self.ammoShader.alignX = "noscale";
	self.ammoShader.alignY = "noscale";
	self.ammoShader.horzAlign = "right";
	self.ammoShader.vertAlign = "bottom";
	self.ammoShader.x = xPos;
	self.ammoShader.y = yPos + 1;
	self.ammoShader.foreground = true;
	self.ammoShader.alpha = 1;
	self.ammoShader.hideWhenInMenu = true;
	self.ammoShader setShader( "cardicon_bullets_50cal", 16, 16 );
	self.ammoShader.shader = "cardicon_bullets_50cal";
	self.ammoShader.color = ( 1, 1, 0 );

	margin = 5;

	self.ammoBGShader = newClientHudElem( self );
	self.ammoBGShader.alignX = "noscale";
	self.ammoBGShader.alignY = "noscale";
	self.ammoBGShader.horzAlign = "right";
	self.ammoBGShader.vertAlign = "bottom";
	self.ammoBGShader.x = xPos - margin;
	self.ammoBGShader.y = yPos + 1 - margin;
	self.ammoBGShader.foreground = false;
	self.ammoBGShader.alpha = .6;
	self.ammoBGShader.hideWhenInMenu = true;
	self.ammoBGShader setShader( "black", 114, margin + 16 + margin );
	self.ammoBGShader.shader = "black";

	self thread destroyOnDeath( self.ammoShader );
	self thread destroyOnDeath( self.ammoHUD );
	self thread destroyOnDeath( self.ammoBGShader );

	self thread ammoHUDThink();
}

ammoHUDThink(){
	self endon("disconnect");
	self endon("death");


	for( ;; ){
		if( self.ammoClip != self getWeaponAmmoClip( self.currWep ) || self.ammoStock != self getWeaponAmmoStock( self.currWep ) || self.currWep != self getCurrentWeapon() ){
			self.currWep = self getCurrentWeapon();
			self.ammoClip = self getWeaponAmmoClip( self.currWep );
			self.ammoStock = self getWeaponAmmoStock( self.currWep );

			self.ammoHUD setText( self.ammoClip + " |  " + self.ammoStock );
		}

		wait .001;
	}
}

moneyHUD(){
	self endon("disconnect");
	self endon("death");

	self.oldMoney = self.money;

	xPos = -55;
	yPos = -30;

	margin = 5;

	self.moneyHUD = newClientHudElem( self );
	self.moneyHUD.alignX = "noscale";
	self.moneyHUD.alignY = "noscale";
	self.moneyHUD.horzAlign = "right";
	self.moneyHUD.vertAlign = "bottom";
	self.moneyHUD.x = xPos + 16 + margin;
	self.moneyHUD.y = yPos;
	self.moneyHUD.foreground = true;
	self.moneyHUD.fontScale = 1.5;
	self.moneyHUD.font = "objective";
	self.moneyHUD.alpha = 1;
	self.moneyHUD.glow = 1;
	self.moneyHUD.glowColor = ( 0, 1, 0 );
	self.moneyHUD.glowAlpha = 0;
	self.moneyHUD.color = ( 1.0, 1.0, 0 );
	self.moneyHUD.hideWhenInMenu = true;
	self.moneyHUD setText( "$  " + self.money );

	self thread destroyOnDeath( self.moneyHUD );

	self thread moneyHUDThink();
}

moneyHUDThink(){
	self endon("disconnect");
	self endon("death");


	for( ;; ){
		if( self.oldMoney != self.money ){
			self.moneyHUD setText( "$  " + self.money );

			self.oldMoney = self.money;
		}

		wait .05;
	}
}

onPlayerKilled( eInflictor, attacker, victim, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, isFauxDeath ){

}