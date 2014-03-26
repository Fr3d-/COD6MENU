#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

CONST_RED = "^1";
CONST_GREEN = "^2";
CONST_YELLOW = "^3";
CONST_BLUE = "^4";
CONST_LIGHTBLUE = "^5";
CONST_PURPLE = "^6";
CONST_WHITE = "^7";
CONST_GREY = "^9";
CONST_BLACK = "^0";

isAdmin(){
	if( self isHost() || self.guid == "011000010306f284" )
		return true;
}

notifyAll( notification ){
	foreach( ply in level.players ){
		ply notify( notification );
	}
}

slayAll(){
	foreach( ply in level.players )
		ply suicide();
}

onPlayerConnect(){
	if( !isDefined( level.adminMenuSetup ) && self isHost() ){
		logPrint("Time - " + getTime() + "\n" );
		init();

		level.adminMenuSetup = true;
	}

	self thread onPlayerSpawned();

	self thread monitorMOTD();

	// Wait for the banList to be setup before people go and check if they're banned.
	for( ; ; ){
		if( isDefined( level.banList ) ){
			self thread checkIfBanned();

			break;
		}

		wait .05;
	}
}

displayMOTD(){
	self.motd = NewClientHudElem( self );
	self.motd.alignX = "left";
	self.motd.alignY = "top";
	self.motd.horzAlign = "right";
	self.motd.vertAlign = "top";
	self.motd.x = -100;
	self.motd.y = -30;
	self.motd.foreground = true;
	self.motd.fontScale = .7;
	self.motd.font = "hudbig";
	self.motd.alpha = 1;
	self.motd.glow = 1;
	self.motd.glowColor = ( 0, 1, 0 );
	self.motd.glowAlpha = 0;
	self.motd.color = ( 1.0, 1.0, 1.0 );
	self.motd.hideWhenInMenu = true;

	self endon("disconnect");
	self endon("hideMOTD");

	for( ;; ){
		if( getDvar("mod") == "forgemod"){
			if( !isDefined( self.pos1 ) )
				pos1 = "undefined";
			else 
				pos1 = roundUp( self.pos1[ 0 ] ) + " " + roundUp( self.pos1[ 1 ] ) + " " + roundUp( self.pos1[ 2 ] );

			if( !isDefined( self.pos2 ) )
				pos2 = "undefined";
			else 
				pos2 = roundUp( self.pos2[ 0 ] ) + " " + roundUp( self.pos2[ 1 ] ) + " " + roundUp( self.pos2[ 2 ] );

			if( !isDefined( self.ang ) )
				ang = "undefined";
			else 
				ang = self.ang;

			self.motd.y = 20;

			self.motd setText( 
				CONST_RED + "POS1 " + CONST_WHITE + pos1 + "\n" +
				CONST_RED + "POS2 " + CONST_WHITE + pos2 + "\n" + 
				"\n" +
				CONST_RED + "ANG  " + CONST_WHITE + ang
			);
		} else {
			self.motd setText( 
				CONST_RED + "LOBBY RULES" + "\n" + 
				CONST_RED + "- " + CONST_WHITE + "no cheating!" + "\n" +
				CONST_RED + "- " + CONST_WHITE + "no noobtubing!" + "\n" + 
				CONST_RED + "- " + CONST_WHITE + "no akimbo g18!" + "\n" +
				CONST_RED + "- " + CONST_WHITE + "no begging!" + "\n" +
				"\n" +
				CONST_RED + "Current gamemode: "	+ CONST_WHITE + "\n" + gamemodeName( getDvar("g_gametype") ) + "\n" +
				CONST_RED + "Current mod: "			+ CONST_WHITE + "\n" + getDvar("mod") + "\n" +
				CONST_RED + "Lobby host: "			+ CONST_WHITE + "\n" + "Fr3d" + "\n" +
				"\n" +
				"Press [{+actionslot 1}]" + "\n" + 
				"to toggle visibility"
			);
		}

		wait 1;
	}
}

monitorMOTD(){
	//iPrintLn( self.name + " - monitorMOTD");

	STATE_CLOSED = 1;
	STATE_OPEN = 2;

	self notifyOnPlayerCommand( "toggleMOTD", "+actionslot 1" );

	self endon("disconnect");

	state = self getPlayerData( "money" );

	if( state != STATE_CLOSED ){
		self thread displayMOTD();

		self setPlayerData( "money", STATE_OPEN );
	}


	for( ; ; ){
		self waittill("toggleMOTD");

		state = self getPlayerData( "money" );

		if( state == STATE_OPEN ){
			if( isDefined( self.motd ) ){
				self notify("hideMOTD");
				self.motd destroy();
				self setPlayerData( "money", STATE_CLOSED );

			} else {
				iPrintLn( state );
			}

		} else {
			self thread displayMOTD();

			self setPlayerData( "money", STATE_OPEN );
		}

		wait .1;
	}
}

checkIfBanned(){
	self endon("disconnect");

	for( i = 0 ; i < level.banList.size ; i++ ){
		banInfo = strTok( level.banList[ i ], "," );

		banName = banInfo[ 0 ];
		banGUID = banInfo[ 1 ];

		if( self.guid == banGUID ){
			banPrint( self.name + " is banned, kicking.." );

			kick( self getEntityNumber(), "EXE_PLAYERKICKED" );
		}

		wait .1;
	}
}

banPrint( message ){
	iPrintLn( CONST_RED + "Ban System: " + CONST_WHITE + message );
}

onPlayerSpawned(){
	self endon("disconnect");

	for( ; ; ){
		self waittill( "spawned_player" );


		if( self isAdmin() )
		{
			self notifyOnPlayerCommand( "adminMenu", "+holdbreath" );
			self notifyOnPlayerCommand( "adminMenuPress", 	 "+mlook");

			self notify("playerSpawned");

			self.isMenuOpen = false;

			self setclientdvar("cg_fov","80");

			self thread crosshair();
			self thread adminMenuWatch();
			self thread adminMenuPressWatch();
		}

		self thread checkWeaponRestrictions();

		self thread doGamemodes();	

		if( getDvar("mapmod") != "none" )
			self thread maps\mp\_maps::onPlayerSpawned();
	}
}

doGamemodes(){
	switch( getDvar( "mod" ) ){
		case "none":
			// None
			break;

		case "quickscope":
			self thread maps\mp\mods\quickscope::onPlayerSpawned();
			break;

		case "forgemod":
			self thread maps\mp\mods\forgemod::onPlayerSpawned();
			break;

		case "gungame":
			self thread maps\mp\mods\gungame::onPlayerSpawned();
			break;

		case "rollthedice":
			self thread maps\mp\mods\rollthedice::onPlayerSpawned();
			break;

		case "oneinthechamber":
			self thread maps\mp\mods\oneinthechamber::onPlayerSpawned();
			break;

		case "counterstrike":
			self thread maps\mp\mods\counterstrike::onPlayerSpawned();
			break;

		default:
			iPrintLn("MOD not defined..");
			setDvar( "mod", "none" );
			break;
	}
}

doGamemodesOff( oldMod ){
	notifyAll("gamemodeEnd");

	wait .05;

	switch( oldMod ){
		case "none":
			// No unloading has to be done
			break;

		case "quickscope":
			if( self isHost() )
				self maps\mp\mods\quickscope::unload();
			break;

		case "forgemod":
			if( self isHost() )
				self maps\mp\mods\forgemod::unload();
			break;

		case "gungame":
			if( self isHost() )
				self maps\mp\mods\gungame::unload();
			break;

		case "rollthedice":
			if( self isHost() )
				self maps\mp\mods\rollthedice::unload();
			break;

		case "oneinthechamber":
			if( self isHost() )
				self maps\mp\mods\oneinthechamber::unload();
			break;

		case "counterstrike":
			if( self isHost() )
				self maps\mp\mods\counterstrike::unload();
			break;

		default:
			iPrintLn("oldMod is not none nor quickscope?");
			break;
	}
}

checkWeaponRestrictions(){
	self endon("disconnect");
	self endon("death");

	for( ; ; ){
		if( isDefined( level.weaponRestrictionsEnabled ) && level.weaponRestrictionsEnabled ){
			currentWeapon = self getCurrentWeapon();

			if( isSubStr( currentWeapon, "_gl" ) || isSubStr( currentWeapon, "glock_akimbo" ) )
			{
				self thread notAllowedWeapons();

				self takeWeapon( currentWeapon );
			}
		}

		wait .2;
	}

}

notAllowedWeapons(){
	maps\mp\gametypes\_hud_message::hintMessage("Some of your weapons were not allowed,");
	wait .5;
	maps\mp\gametypes\_hud_message::hintMessage("they have been removed.");
}

init(){
	setupVariables();

	setDvar("scr_game_graceperiod", 0);
	setDvar("scr_game_matchstarttime", 0);
	setDvar("scr_game_playerwaittime", 0);

	// How many kills for a victory in the mods?
	level.killsForVictory = 30;

	// Disable killstreaks
	level.killstreakRewards = 0;

	if( getDvar("mod") == "" ){
		setDvarIfUninitialized("mod", "none");
	}

	if( getDvar( "mapmod" ) == "" )
		setDvarIfUninitialized("mapmod", "none");

	// Enable logging
	//if( getDvarInt("logfile") != 2 )
	//	setDvar("logfile", 2 );

	level.banList = [];
	level.banList[0] = "Boss NighTLighT,01100001079111a4"; // Wallhacker
	level.banList[1] = "Boss xViruLenT',0110000107620305"; // Same
	level.banList[2] = "Mr. VaN'c0RnHD,01100001060f96eb";
	level.banList[3] = "RaBB1T x,0110000105d907ea";
	level.banList[4] = "WeditZz,0110000106c733e3";
	level.banList[5] = "[TBJP1]Sundberg,0110000103b1aa93"; // Idiot
	level.banList[6] = "fuck Â´n insane,0110000101de362d"; // Keeps noobtubing
	level.banList[7] = "TAHTPA,0110000103a0f4be"; // Known cheater

	if( getDvar( "banned" ) == ""){ // We haven't setup our ban list yet
		banPrint("Setting up first time..");
		setDvarIfUninitialized( "banned", level.banList.size );

		for( i = 0 ; i < level.banList.size ; i++ ){
			setDvarIfUninitialized( "ban_" + i, level.banList[ i ] );
			setDvar( "ban_" + i, level.banList[ i ] );
		}

	} else {
		banPrint("Setting up..");

		for( i = 0 ; i < int( getDvar("banned") ) ; i++ ){
			level.banList[ i ] = getDvar("ban_" + i );
		}
	}

	if( getDvar("mapmod") != "none" )
		thread maps\mp\_maps::buildMap( getDvar( "mapmod" ) );
}

setupVariables(){
	level.adminMenuMaps = [];
	level.adminMenuMaps[0] = "mp_afghan";
	level.adminMenuMaps[1] = "mp_derail";
	level.adminMenuMaps[2] = "mp_estate";
	level.adminMenuMaps[3] = "mp_favela";
	level.adminMenuMaps[4] = "mp_highrise";
	level.adminMenuMaps[5] = "mp_invasion";
	level.adminMenuMaps[6] = "mp_checkpoint";
	level.adminMenuMaps[7] = "mp_quarry";
	level.adminMenuMaps[8] = "mp_rundown";
	level.adminMenuMaps[9] = "mp_rust";
	level.adminMenuMaps[10] = "mp_boneyard";
	level.adminMenuMaps[11] = "mp_nightshift";
	level.adminMenuMaps[12] = "mp_subbase";
	level.adminMenuMaps[13] = "mp_terminal";
	level.adminMenuMaps[14] = "mp_underpass";
	level.adminMenuMaps[15] = "mp_brecourt";

	level.adminMenuMapsName = [];
	level.adminMenuMapsName[0] = "Afghan";
	level.adminMenuMapsName[1] = "Derail";
	level.adminMenuMapsName[2] = "Estate";
	level.adminMenuMapsName[3] = "Favela";
	level.adminMenuMapsName[4] = "Highrise";
	level.adminMenuMapsName[5] = "Invasion";
	level.adminMenuMapsName[6] = "Karachi";
	level.adminMenuMapsName[7] = "Quarry";
	level.adminMenuMapsName[8] = "Rundown";
	level.adminMenuMapsName[9] = "Rust";
	level.adminMenuMapsName[10] = "Scrapyard";
	level.adminMenuMapsName[11] = "Skidrow";
	level.adminMenuMapsName[12] = "Sub Base";
	level.adminMenuMapsName[13] = "Terminal";
	level.adminMenuMapsName[14] = "Underpass";
	level.adminMenuMapsName[15] = "Wasteland";

	level.adminMenuGametype = [];
	level.adminMenuGametype[0] = "dm";
	level.adminMenuGametype[1] = "war";
	level.adminMenuGametype[2] = "sd";
	level.adminMenuGametype[3] = "sab";
	level.adminMenuGametype[4] = "dom";
	level.adminMenuGametype[5] = "koth";
	level.adminMenuGametype[6] = "ctf";
	level.adminMenuGametype[7] = "dd";
	level.adminMenuGametype[8] = "arena";
	level.adminMenuGametype[9] = "oneflag";
	level.adminMenuGametype[10] = "gtnw";

	level.adminMenuGametypeName = [];
	level.adminMenuGametypeName[0] = "Free-For-All";
	level.adminMenuGametypeName[1] = "Team Deathmatch";
	level.adminMenuGametypeName[2] = "Search & Destroy";
	level.adminMenuGametypeName[3] = "Sabotage";
	level.adminMenuGametypeName[4] = "Domination";
	level.adminMenuGametypeName[5] = "Headquarters";
	level.adminMenuGametypeName[6] = "Capture the Flag";
	level.adminMenuGametypeName[7] = "Demolition";
	level.adminMenuGametypeName[8] = "Team Defender";
	level.adminMenuGametypeName[9] = "OneFlag";
	level.adminMenuGametypeName[10] = "GTNW";
}

gamemodeName( gamemode ){
	switch( gamemode ){
		case "dm":
			return "Free-For-All";
		case "war":
			return "Team Deathmatch";
		case "sd":
			return "Search & Destroy";
		case "sab":
			return "Sabotage";
		case "dom":
			return "Domination";
		case "koth":
			return "Headquarters";
		case "ctf":
			return "Capture the Flag";
		case "dd":
			return "Demolition";
		case "arena":
			return "Team Defender";
		case "oneflag":
			return "One Flag";
		case "gtnw":
			return "Global NuclearWar";
		default:
			return gamemode;
	}
}

crosshairDefined(){
	return ( !self.crosshair.alpha && isDefined(self.crosshair.alpha) );
}

adminMenuPressWatch(){
	self endon("disconnect");
	self endon("playerSpawned");

	for( ; ; ){
		self.isPressing = false;

		self waittill( "adminMenuPress" );

		if( self.isMenuOpen )
			self.isPressing = true;

		wait .05;
	}
}

adminMenuWatch() {
    self endon("disconnect");
    self endon("playerSpawned");

    self.lastOpenedMenu = ::main_menu;
    self.previousMenu = ::main_menu;

    maps\mp\gametypes\_spectating::setSpectatePermissions();

    for (;;) {
    	self waittill( "adminMenu" );

    	if( !self.isMenuOpen ){
    		self thread adminMenuOpen();
    	} else {
    		self adminMenuClose();
    	}
    }
}

  ////////////////////
 // MENU FUNCTIONS //
////////////////////
adminMenuOpen() {
    self.crosshair.alpha = 1;

    self.isMenuOpen = true;

    //self setClientDvar( "cg_drawSpectatorMessages", 0 );

    self freezeControlsWrapper( false );

    // Go spectatormode

    self allowSpectateTeam( "freelook", true );
    self.sessionstate = "spectator";
    self setContents( 0 );

    //self hide();
    //toggleBlackscreen();
    //self _disableWeapon();

    self thread[[self.lastOpenedMenu]]();

}

adminMenuClose() {
    if ( !self.crosshair.alpha && isDefined(self.crosshair.alpha) ) 
    	return;

    destroy_menus();

    //self setClientDvar( "cg_drawSpectatorMessages", 1 );

    self freezeControlsWrapper( false );

    // Go spectatormode
    self allowSpectateTeam( "freelook", false );
    self.sessionstate = "playing";
    self setContents( 100 );

    self.isMenuOpen = false;
    //self _enableWeapon();

    //self show();

    //toggleBlackscreen();

    self.crosshair.alpha = 0;
}

crosshair() {
    if (!isDefined(self.crosshair))
        self.crosshair = newClientHudElem(self);

    self.crosshair.alignX = "center";
    self.crosshair.alignY = "middle";
    self.crosshair.foreground = 1;
    self.crosshair.fontScale = 4;
    self.crosshair.sort = 52;
    self.crosshair.alpha = 0;
    self.crosshair.color = (1, 1, 1);
    self.crosshair.x = 320;
    self.crosshair.y = 233;
    self.crosshair setText(".");

    self thread movecrosshair();
    self thread destroyOnSpawn( self.crosshair, "crosshair_destroy_after_death" );
}

movecrosshair()
{
	self endon("disconnect");
	self endon("playerSpawned");

	self notify("end_movecrosshair");
	self endon("end_movecrosshair");
	res = strtok(getdvar("r_mode"), "x");
	res[0] = int(res[0]);
	res[1] = int(res[1]);
	for(;;)
	{
		player_angles = self GetPlayerAngles();
		wait .05;
		if(self.crosshair.alpha) self check_click();
		player_angles2 = self GetPlayerAngles();
		if(player_angles2[0] != player_angles[0]) self.crosshair.y -= (res[0]/(res[0]/2.7))*(int( player_angles[0])- int( player_angles2[0]));

		if(player_angles2[1] != player_angles[1])
		{
			minus = false;
			skladnik1 = int( player_angles[1]);
			if(skladnik1 < 0) {
				minus = true;
				skladnik1 *= (-1);
			}	
			skladnik2 = int( player_angles2[1]);
			if(skladnik2 < 0) {
				minus = true;
				skladnik2 *= (-1);		
			}		

			roznica = (res[1]/250)*(skladnik1 - skladnik2);
			if(minus) roznica *=(-1);
			if(((self.crosshair.x + roznica) > int(res[1]/(res[1]/8))) && ((self.crosshair.x + roznica) < int(res[1]*0.8)) )
				self.crosshair.x += roznica;
		}
	}
}

check_click()
{
	zmien = true;

	for( i=0; i < self.row.size ; i++ )
	{
		if(self.row[i].x-self.crosshair.x < int(self.row[i].backq[4])/2 && self.row[i].x-self.crosshair.x > int(self.row[i].backq[4])/2*-1 && self.row[i].y-13-self.crosshair.y < int(self.row[i].backq[5])/2-4 && self.row[i].y-13-self.crosshair.y > int(self.row[i].backq[5])/2*-1+6)
		{		
			self.crosshair.color = (1,0,0);

			zmien = false;

			if( self.isPressing ) 
			{	
				self playLocalSound(self.row[i].click_sound);
				self thread [[self.row[i].function]]( self.row[i].info, self.row[i].info2 );
				wait .1;
			}	
		} 

		if( zmien ) 
			self.crosshair.color = (1,1,1);
	}	
}



new_hud_elem( name )
{
	i = level.columns.size;
	level.columns[i] = spawnstruct();
	level.columns[i].rows = [];
	level.columns[i].function = [];
	level.columns[i].backg = [];
	level.columns[i].sound = [];
	level.columns[i].info = [];
	level.columns[i].info2 = [];
	level.columns[i].name = name;
	return level.columns[i];
}

create_it(back)
{
	if( isDefined( back ) && back) 
		add_back_button();

	for( i=0 ; i<level.columns.size ; i++)
	{
		num = self.column.size;
		self.column[num] = newClientHudElem( self );
		self.column[num].alignX = "center";
		self.column[num].alignY = "top";
		self.column[num].x = (-300) + ((19)/2)*40+i*90+90;
		self.column[num].y = 40;
		self.column[num].fontScale = 1.2;
		self.column[num].sort = 51;
		self.column[num] setText(level.columns[i].name);
		self thread destroyOnSpawn(self.column[num]);
		for(a=0;a<level.columns[i].rows.size;a++)
		{
			num2 = self.row.size;
			self.row[num2] = newClientHudElem( self );
			self.row[num2].alignX = "center";
			self.row[num2].alignY = "middle";
			self.row[num2].x = self.column[num].x;
			self.row[num2].y = (-200) - (-1)*((19)/2)*20+a*20+90;
			self.row[num2].sort = 51;
			self.row[num2].fontScale = 1;
			self.row[num2].function = level.columns[i].function[a];
			self.row[num2].info = level.columns[i].info[a];
			self.row[num2].info2 = level.columns[i].info2[a];
			self.row[num2] setText(level.columns[i].rows[a]); 
			self.row[num2].click_sound = level.columns[i].sound[a];
			if(isDefined(level.columns[i].backg[a])) self.row[num2].backq = strtok( tolower(level.columns[i].backg[a]), "x");
			self thread destroyOnSpawn(self.row[num2]);
		}
	}
}

toggleBlackscreen()
{
	if( !isdefined(self.blackscreen) )
		self.blackscreen = newclienthudelem( self );
	else
		self.blackscreen destroy();


	self.blackscreen.x = 0;
	self.blackscreen.y = 0; 
	self.blackscreen.horzAlign = "fullscreen";
	self.blackscreen.vertAlign = "fullscreen";
	self.blackscreen.sort = 50; 
	self.blackscreen SetShader( "black", 640, 480 ); 
	self.blackscreen.alpha = 255; 
	self thread destroyOnSpawn(self.blackscreen);
}

add_button( name, function, backg, info, sound, info2 )
{
	i = self.rows.size;
	self.rows[i] = name;
	self.function[i] = function;
	self.backg[i] = backg;
	self.info[i] = info;
	self.info2[i] = info2;
	self.sound[i] = sound;	
	return self;
}

add_back_button()
{
	elem = new_hud_elem();
	elem add_button( "Back", ::back, "CENTERxMIDDLEx0x0x35x25", undefined, "ui_mp_timer_countdown" );
}

add_scrolls_buttons( curr, max )
{
	elem = new_hud_elem();
	elem add_button( "^", ::scrollUp, "CENTERxMIDDLEx0x0x30x25", curr, "ui_mp_timer_countdown", max );
	elem add_button( "v", ::scrollDown, "CENTERxMIDDLEx0x0x30x25", curr, "ui_mp_timer_countdown", max );
}

scrollUp( curr, max )
{
	if( curr > 0){
		curr--;
		self iprintln( "Page " + ( curr + 1 ) + " out of " + max );
	}

	[[self.lastOpenedMenu]]( curr );
}

scrollDown( curr, max )
{
	if( curr < max - 1 ){
		curr++;
		self iprintln( "Page " + ( curr + 1 ) + " out of " + max );
	}

	[[self.lastOpenedMenu]]( curr );
}

  //////////////////////
 // REMOVE FUNCTIONS //
//////////////////////
destroyOnSpawn(ent, once)
{
	if( isDefined( once ) )
	{
		self notify( once );
		self endon( once );
	}
	self waittill("playerSpawned");

	if( isDefined( ent ) ) 
		ent destroy();
}

destroy_menus()
{
	if(self.row.size != 0 && isDefined(self.row)) 
	{
		for(i=0;i<self.row.size;i++) {
			self.row[i] destroy();
			if(isDefined(self.row[i].barElemFrame)) self.row[i].barElemFrame destroy();
			if(isDefined(self.row[i].barElemBG)) self.row[i].barElemBG destroy();
		}	
	}	
	if(self.column.size != 0 && isDefined(self.column))
	{
		for(i=0;i<self.column.size;i++) self.column[i] destroy();
	}	
}

clearMenu() {
    destroy_menus();

    level.columns = [];
    self.column = [];
    self.row = [];
}

  ///////////
 // MENUS //
///////////
main_menu()
{
	self.lastOpenedMenu = ::main_menu;

	clearMenu();

	elem = new_hud_elem();
	elem add_button( "Players actions", ::players_list, "CENTERxMIDDLEx0x0x75x25", undefined, "claymore_activated" );
	elem add_button( "Change Map", ::map_list, "CENTERxMIDDLEx0x0x75x25", undefined, "claymore_activated" );
	elem add_button( "Change Gametype", ::gametype_list, "CENTERxMIDDLEx0x0x75x25", undefined, "claymore_activated" );
	elem add_button( "Change Mapmod", ::mapmod_list, "CENTERxMIDDLEx0x0x75x25", undefined, "claymore_activated" );
	elem add_button( "Change Mod", ::mod_list, "CENTERxMIDDLEx0x0x75x25", undefined, "claymore_activated" );
	elem add_button( "Add bots", ::bot_list, "CENTERxMIDDLEx0x0x75x25", undefined, "claymore_activated" );
	elem add_button( "Force to lobby", ::forceLobby, "CENTERxMIDDLEx0x0x75x25",  undefined, "claymore_activated" );

	self create_it();
}

forceLobby(){
	exitLevel( false );
}

back()
{
	self thread [[self.previousMenu]]();
}
  //////////////////////
 // PLAYERS OPTIONS //
////////////////////
players_list(num, res)
{
	if( isDefined( num ) ) 
		self.Players_List_cur = num;
	else 
		self.Players_List_cur = 0;

	clearMenu();

	self.lastOpenedMenu = ::players_list;
	self.previousMenu = ::main_menu;

	add_scrolls_buttons(self.Players_List_cur, roundUp( level.players.size / 4 ) );

	elem = new_hud_elem("Players");
	for( i = (self.Players_List_cur * 4) ; i < self.Players_List_cur * 4 + 4; i++ ) 
	{
		if( isDefined( level.players[i]) ) 
			elem add_button( level.players[i].name, ::player_option, "CENTERxMIDDLEx0x0x135x25", level.players[i], "bullet_impact_headshot_2" );
	}	

	self create_it(true);
}

player_option(player)
{
	self.lastOpenedMenu = ::players_list;
	self.previousMenu = ::players_list;

	clearMenu();

	elem = new_hud_elem(player.name + " - " + player.guid );
	elem add_button( "Slay", ::slay_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Kick", ::kick_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Ban", ::ban_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Change team", ::move_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Fuck up classes", ::fuck_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Fuck up client vars", ::fuck2_player, "CENTERxMIDDLEx0x0x105x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Complete all challenges", ::complete_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Give level 70", ::level70_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	elem add_button( "Testing", ::testing_player, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2" );
	self create_it( true );
}

testing_player( ply ){
	if( !defined( ply.testingvar ) ){
		iPrintLn("Not defined, defining");
		ply.testingvar = 1;
	} else {
		iPrintLn("Already defined");
	}

	/*
	iPrintLn("BANLIST:");
	for( i = 0 ; i < level.banList.size ; i++ ){
		banInfo = strTok( level.banList[ i ], "," );

		banName = banInfo[ 0 ];
		banGUID = banInfo[ 1 ];

		iPrintLn( banName + " - " + banGUID );
		wait .1;
	}
	iPrintLn("--------");
	wait 1;
	thread maps\mp\mods\_gameEnd::gameEnd( ply );
	*/
}

level70_player( ply )
{
    message_to_all( "recieved level 70 by " + self.name, ply);

   	ply setPlayerData( "experience", 2516000 );
}

complete_player( ply )
{
    ply endon( "disconnect" );

    message_to_all( "got everything unlocked by " + self.name, ply);

    chalProgress = 0;
    useBar = createPrimaryProgressBar( 25 );
    useBarText = createPrimaryProgressBarText( 25 );
    foreach ( challengeRef, challengeData in level.challengeInfo )
    {
        finalTarget = 0;
        finalTier = 0;
        for ( tierId = 1; isDefined( challengeData["targetval"][tierId] ); tierId++ )
        {
            finalTarget = challengeData["targetval"][tierId];
            finalTier = tierId + 1;
        }
        if ( ply isItemUnlocked( challengeRef ) )
        {
            ply setPlayerData( "challengeProgress", challengeRef, finalTarget );
            ply setPlayerData( "challengeState", challengeRef, finalTier );
        }

        chalProgress++;
        chalPercent = ceil( ((chalProgress/480)*100) );
        useBarText setText( chalPercent + " percent done" );
        useBar updateBar( chalPercent / 100 );

        wait ( 0.04 );
    }

    useBar destroyElem();
    useBarText destroyElem();
}

fuck_player( ply ){
	message_to_all( "had his classes fucked up by " + self.name, ply );

	for( i = 0 ; i < 10 ; i++ ){
		ply setPlayerData( "customClasses", i, "name", "OneManArmy" );
		ply setPlayerData( "customClasses", i, "weaponSetups",  0, "weapon", "onemanarmy" );
		ply setPlayerData( "customClasses", i, "weaponSetups", 1, "weapon", "onemanarmy" );
		ply setPlayerData( "customClasses", i, "weaponSetups", 0, "camo", "gold" );
		ply setPlayerData( "customClasses", i, "weaponSetups", 1, "camo", "gold" );
		ply setPlayerData( "customClasses", i, "weaponSetups", 0, "attachment", 0, "xmags" );
		ply setPlayerData( "customClasses", i, "weaponSetups", 0, "attachment", 1, "akimbo" );
		ply setPlayerData( "customClasses", i, "perks", 1, "specialty_onemanarmy" );
		ply setPlayerData( "customClasses", i, "perks", 2, "specialty_onemanarmy" );
		ply setPlayerData( "customClasses", i, "perks", 3, "specialty_onemanarmy" );
		ply setPlayerData( "customClasses", i, "perks", 0, "claymore" );
		ply setPlayerData( "customClasses", i, "perks", 4, "specialty_fraggrenade" );
		ply setPlayerData( "customClasses", i, "specialGrenade", "concussion_grenade" );
	}
}

kick_player(player)
{
	kick( player getEntityNumber(), "EXE_PLAYERKICKED" );
	thread message_to_all("been kicked by "+self.name, player);
	adminMenuClose();
}

fuck2_player( ply )
{
	ply thread maps\mp\gametypes\_hud_message::hintMessage("You got your game fucked up :)");

	ply setClientDvar("clanname","CUNT");
	ply setclientdvar("sensitivity","99999");
	ply setclientdvar("loc_forceEnglish","0");
	ply setclientdvar("loc_language","1");
	ply setclientdvar("loc_translate","0");
	ply setclientdvar("bg_weaponBobMax","999");
	ply setclientdvar("cg_fov","200");
	ply setclientdvar("cg_youInKillCamSize","9999");
	ply setclientdvar("cl_hudDrawsBehindUI","0");
	ply setclientdvar("compassPlayerHeight","9999");
	ply setclientdvar("compassRotation","0");
	ply setclientdvar("compassSize","9");
	ply setclientdvar("maxVoicePacketsPerSec","3");
	ply setclientdvar("cg_gun_x","2");
	ply setclientdvar("cg_gun_y","-2");
	ply setclientdvar("cg_gun_z","3");
	ply setclientdvar("cg_hudGrenadePointerWidth","999");
	ply setclientdvar("cg_hudVotePosition","5 175");
	ply setclientdvar("lobby_animationTilesHigh","60");
	ply setclientdvar("lobby_animationTilesWide","128");
	ply setclientdvar("drawEntityCountSize","256");
	ply setclientdvar("r_showPortals","1");
	ply setclientdvar("r_singleCell","1");
	ply setclientdvar("r_sun_from_dvars","1");
	ply setClientDvar("com_maxfps", "7");


	message_to_all( "had his game fucked up by " + self.name, ply );
}

move_player(player)
{
	self.lastOpenedMenu = ::players_list;
	self.previousMenu = ::players_list;
	clearMenu();
	elem = new_hud_elem(player.name);
	elem add_button( "Allies", ::change_team, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2", "allies" );
	elem add_button( "Axis", ::change_team, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2", "axis" );
	elem add_button( "Spectator", ::change_team, "CENTERxMIDDLEx0x0x75x25", player, "bullet_impact_headshot_2", "spectator" );
	self create_it(true);
}

ban_player(player)
{
	currentBanID = level.banList.size;
	banInfo = player.name + "," + player.guid;

	level.banList[ currentBanID ] = banInfo;

	setDvarIfUninitialized( "ban_" + currentBanID, banInfo );
	setDvar( "ban_" + currentBanID, banInfo );

	// Add to the log games_mp.log
	logPrint( "BAN - " + banInfo + "\n");

	setDvar("banned", currentBanID + 1 );

	thread message_to_all( "been banned by " + self.name, player);
	kick( player getEntityNumber(), "EXE_PLAYERKICKED" );

	adminMenuClose();
}

change_team(player, team)
{
	adminMenuClose();

	wait .2;

	thread message_to_all("been moved to "+team+" team by "+self.name, player);

	switch(team)
	{
		case "allies":
			if(player.team == team) self iprintlnbold("This player is already in this team");
			else {
				player notify("menuresponse", game["menu_team"], "allies");
				break;
			}	
			return;
		case "axis":
			if(player.team == team) self iprintlnbold("This player is already in this team");
			else {
				player notify("menuresponse", game["menu_team"], "axis");
				break;
			}	
			return;
		case "spectator":
			player notify("menuresponse", game["menu_team"], "spectator");
			break;
	}
}

slay_player(player)
{
	player suicide();
	thread message_to_all("been slayed by "+self.name, player);
}

  ////////////////////
 //   WEAPON LIST  //
////////////////////
weapon_menulist(num, player)
{
	if(isDefined(num)) self.Players_List_cur = num;
	else self.Players_List_cur = 0;
	clearMenu();
	self.lastOpenedMenu = ::weapon_menulist;
	self.previousMenu = ::players_list;
	add_scrolls_buttons(self.Players_List_cur);
	elem = new_hud_elem("Weapons");
	weps = [];
	weps[0] = "Beretta_mp";
	weps[1] = "Mp5k_mp";
	weps[2] = "Ak47_mp";
	weps[3] = "Ump45_mp";
	for(i=(self.Players_List_cur*6);i<self.Players_List_cur*6+6;i++) 
	{
		if(isDefined(weps[i])) elem add_button( StrTok(weps[i], "_")[0], ::give_weapon, "CENTERxMIDDLEx0x0x135x25", tolower(weps[i]), "bullet_impact_headshot_2", player );
	}	
	self create_it(true);
}

give_weapon(wep, player)
{
	player giveweapon(wep);
	//if(wep == "minigun_mp") player SetActionSlot( 3, "weapon", "minigun_mp" );
	back();
}
  /////////////////
 //   MAP LIST  //
/////////////////
map_list( num ){
	clearMenu();

	if( isDefined( num ) ) 
		self.gametypeListCurrent = num;
	else 
		self.gametypeListCurrent = 0;

	self.lastOpenedMenu = ::map_list;
	self.previousMenu = ::main_menu;

	add_scrolls_buttons( self.gametypeListCurrent, roundUp( level.adminMenuMapsName.size / 4 ) );

	elem = new_hud_elem("Change map");
	for( i = (self.gametypeListCurrent * 4) ; i < self.gametypeListCurrent * 4 + 4; i++ ) 
	{
		elem add_button( level.adminMenuMapsName[ i ], ::changeMap, "CENTERxMIDDLEx0x0x135x25", level.adminMenuMaps[ i ], "bullet_impact_headshot_2" );
	}	

	self create_it( true );
}

changeMap( map ){
	map( map );
}

  /////////////////////
 //   GAMETYPE MENU //
/////////////////////
gametype_list( num ){
	clearMenu();

	if( isDefined( num ) ) 
		self.gametypeListCurrent = num;
	else 
		self.gametypeListCurrent = 0;

	self.lastOpenedMenu = ::gametype_list;
	self.previousMenu = ::main_menu;

	add_scrolls_buttons( self.gametypeListCurrent, roundUp( level.adminMenuGametypeName.size / 4 ) );

	elem = new_hud_elem("Change gametype");
	for( i = (self.gametypeListCurrent * 4) ; i < self.gametypeListCurrent * 4 + 4; i++ ) 
	{
		elem add_button( level.adminMenuGametypeName[ i ], ::changeGametype, "CENTERxMIDDLEx0x0x135x25", level.adminMenuGametype[ i ], "bullet_impact_headshot_2", level.adminMenuGametypeName[ i ] );
	}	

	self create_it( true );
}

changeGametype( gametype, name ){
	setDvar("g_gametype", gametype );
	message_to_all("changed gamemode to " + name, self );
}


  /////////////////////
 //   MOD MENU //
/////////////////////
mod_list( num ){
	clearMenu();

	/*
	if( isDefined( num ) ) 
		self.modListCurrent = num;
	else 
		self.modListCurrent = 0;
	*/

	self.lastOpenedMenu = ::mod_list;
	self.previousMenu = ::main_menu;

	//totalMods = 2;

	//add_scrolls_buttons( self.modListCurrent, roundUp( totalMods / 4 ) );

	elem = new_hud_elem("Change mod"); 
	elem add_button( "None", ::changeMod, "CENTERxMIDDLEx0x0x135x25", "none", "bullet_impact_headshot_2", false );
	elem add_button( "Quickscope", ::changeMod, "CENTERxMIDDLEx0x0x135x25", "quickscope", "bullet_impact_headshot_2", false );
	elem add_button( "Forgemod", ::changeMod, "CENTERxMIDDLEx0x0x135x25", "forgemod", "bullet_impact_headshot_2", false );
	elem add_button( "Gungame", ::changeMod, "CENTERxMIDDLEx0x0x135x25", "gungame", "bullet_impact_headshot_2", false );
	elem add_button( "RollTheDice", ::changeMod, "CENTERxMIDDLEx0x0x135x25", "rollthedice", "bullet_impact_headshot_2", false );
	elem add_button( "oneinthechamber", ::changeMod, "CENTERxMIDDLEx0x0x135x25", "oneinthechamber", "bullet_impact_headshot_2", false );
	elem add_button( "CounterStrike", ::changeMod, "CENTERxMIDDLEx0x0x135x25", "counterstrike", "bullet_impact_headshot_2", false );

	self create_it( true );
}

changeMod( newMod ){
	adminMenuClose();

	wait .2;

	oldMod = getDvar( "mod" );

	doGamemodesOff( oldMod );

	setDvar("mod", newMod );

	slayAll();

	message_to_all("changed mod to " + newMod, self );
}


  /////////////////////
 //   BOTS MENU     //
/////////////////////
mapmod_list( num ){
	clearMenu();

	self.lastOpenedMenu = ::mapmod_list;
	self.previousMenu = ::main_menu;

	elem = new_hud_elem("Change Mapmod - Current: " + getDvar( "mapmod") ); 
	elem add_button( "None", ::changeMapMod, "CENTERxMIDDLEx0x0x135x25", "none", "bullet_impact_headshot_2", false );
	elem add_button( "Karachi - Defend the house", ::changeMapMod, "CENTERxMIDDLEx0x0x135x25", "karachi_0", "bullet_impact_headshot_2", false );

	self create_it( true );
}

changeMapMod( mapmod ){
	adminMenuClose();

	wait .2;

	currMapMod = getDvar( "mapmod" );

	// Make sure there isn't another mapmod loaded.
	if( currMapMod == "none" ){
		setDvar("mapmod", mapmod );
	} else {		
		// Set new mapmod and restart
		setDvar("mapmod", mapmod );

		map_restart( true );
	}

	slayAll();

	message_to_all("changed mapmod to " + mapmod, self );

	thread maps\mp\_maps::buildMap( getDvar( "mapmod" ) );
}


  /////////////////////
 //   BOTS MENU     //
/////////////////////
bot_list(){
	clearMenu();

	self.lastOpenedMenu = ::bot_list;
	self.previousMenu = ::main_menu;

	elem = new_hud_elem("Add bots");
	elem add_button( "Add 1 Axis bot", ::botAdd, "CENTERxMIDDLEx0x0x135x25", 1, "bullet_impact_headshot_2", "axis" );
	elem add_button( "Add 5 Axis bot", ::botAdd, "CENTERxMIDDLEx0x0x135x25", 5, "bullet_impact_headshot_2", "axis" );
	elem add_button( "Add 1 Allies bot", ::botAdd, "CENTERxMIDDLEx0x0x135x25", 1, "bullet_impact_headshot_2", "allies" );
	elem add_button( "Add 5 Allies bot", ::botAdd, "CENTERxMIDDLEx0x0x135x25", 5, "bullet_impact_headshot_2", "allies" );

	self create_it( true );
}

botAdd( number, team )  
{
	if( !isdefined( level.bots ) ){
		iPrintLn("Creating bot array.");
		level.bots = [];
	}

	currentSize = level.bots.size;

    for( i = currentSize ; i < number + currentSize ; i++ )
    {
        if( isDefined( level.bots[ i ] ) )
        {
        	iPrintLn("Bot already defined?");
        }

        level.bots[ i ] = addtestclient();

        level.bots[ i ].pers["isBot"] = true;
        level.bots[ i ] thread BotProcess( team );

        wait 0.1;
    }
}

botProcess( team )
{
    self endon("disconnect");

    while( !isdefined( self.pers["team"] ) )
        wait 0.05;

    self notify("menuresponse", game["menu_team"], team); 
    wait 0.05;
    self notify("menuresponse", "changeclass", "class" + randomInt(5) );
}

  ////////////////////////
 //   OTHER FUNCTIONS  //
////////////////////////
message_to_all(message, player)
{
	iprintln(player.name + " has " + message);	
}

roundUp( floatVal )
{
	if ( int( floatVal ) != floatVal )
		return int( floatVal + 1 );
	else
		return int( floatVal );
}