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

startvote(){
	level.voteGameType = [];
	level.voteGameType[0] = "war";
	level.voteGameType[1] = "sd";
	level.voteGameType[2] = "sab";
	level.voteGameType[3] = "dom";
	level.voteGameType[4] = "koth";
	level.voteGameType[5] = "ctf";
	level.voteGameType[6] = "dd";
	level.voteGameType[7] = "arena";
	level.voteGameType[8] = "oneflag";
	level.voteGameType[9] = "gtnw";

	level.voteGameTypeName = [];
	level.voteGameTypeName[0] = "TDM";
	level.voteGameTypeName[1] = "S&D";
	level.voteGameTypeName[2] = "Sabotage";
	level.voteGameTypeName[3] = "Domination";
	level.voteGameTypeName[4] = "Headquarters";
	level.voteGameTypeName[5] = "CTF";
	level.voteGameTypeName[6] = "Demolition";
	level.voteGameTypeName[7] = "Team Defender";
	level.voteGameTypeName[8] = "OneFlag";
	level.voteGameTypeName[9] = "GTNW";

	level.voteableMaps = [];
	level.votesForMap = [];
	level.voteableGMs = [];
	level.votesForGM = [];
	level.nextMap = -1;
	level.nextGamemode = -1;
	level.currVoteTime = "";

	for( i = 0; i < 4; i++){
		while(true){
			goodMap = true;
			tempMap = randomInt(level.adminMenuMaps.size);

			if(level.voteableMaps[i] != getDvar("mapname")){
				foreach(map in level.voteableMaps){
					if(tempMap == map){
						goodMap = false;
					}
				}

				if(goodMap){
					level.voteableMaps[i] = tempMap;
					level.votesForMap[level.voteableMaps[i]] = 0;

					break;
				}
			}
		}
	}

	for( i = 0; i < 4; i++){
		while(true){
			goodGM = true;
			tempGM = randomInt(level.voteGameType.size);

			if(level.voteableGMs[i] != getDvar("g_gametype")){
				foreach(gm in level.voteableGMs){
					if(tempGM == gm){
						goodGM = false;
					}
				}
				if(goodGM){
					level.voteableGMs[i] = tempGM;
					level.votesForGM[level.voteableGMs[i]] = 0;

					break;
				}
			}
		}
	}

	level thread votething();

	foreach( ply in level.players ){
		ply thread vote();
	}
}

votething(){
	// REMEMBER: EVEN VOTES WILL SELECT THE LAST ENTRY FROM level.adminMenu*
	// TODO: EVEN VOTES WILL BE SELECTED RANDOMLY

	// MAP VOTE
	level.voteState = 0;
	foreach(ply in level.players){
		ply thread votebuttons();
	}
	level.currVoteTime = getTimeInSeconds() + 15;
	wait 15; // wait 10 seconds and select winner.

	highestvotes = 0;
	winner = 0;
	for( i = 0; i < level.adminMenuMaps.size; i++){
		if(!isdefined(level.votesForMap[i]))
			continue;

		if(level.votesForMap[i] >= highestvotes){
			highestvotes = level.votesForMap[i];
			winner = i;
		}
	}

	level.nextMap = winner;

	// GAMEMOD VOTE
	level.voteState = 1;
	foreach(ply in level.players){
		ply thread votebuttons();
	}
	level.currVoteTime = getTimeInSeconds() + 15;
	wait 15; // wait 10 seconds ..

	highestvotes = 0;
	winner = 0;
	for( i = 0; i < level.voteGameType.size; i++){
		if(!isdefined(level.votesForGM[i]))
			continue;

		if(level.votesForGM[i] >= highestvotes){
			highestvotes = level.votesForGM[i];
			winner = i;
		}
	}

	level.nextGamemode = winner;

	// DISPLAY WINNERS
	level.voteState = 2;
	wait 5; // display vote winners

	setDvar("g_gametype", level.voteGameType[level.nextGamemode]);
	map(level.adminMenuMaps[level.nextMap]);
}

vote(){
	self notify("beginvote");
	self notify("hideMOTD");
	self.motd destroy();
	self.showMOTD = false;

	self notifyOnPlayerCommand( "vote2", "weapnext" );
	self notifyOnPlayerCommand( "vote3", "+actionslot 3" );
	self notifyOnPlayerCommand( "vote4", "+actionslot 4" );
	self notifyOnPlayerCommand( "vote5", "+actionslot 2" );

	self thread votehud();
}

votehud(){
	self.votehud = NewClientHudElem( self );
	self.votehud.alignX = "left";
	self.votehud.alignY = "top";
	self.votehud.horzAlign = "right";
	self.votehud.vertAlign = "top";
	self.votehud.x = -150;
	self.votehud.y = -30;
	self.votehud.foreground = true;
	self.votehud.fontScale = .7;
	self.votehud.font = "hudbig";
	self.votehud.alpha = 1;
	self.votehud.glow = 1;
	self.votehud.glowColor = ( 0, 1, 0 );
	self.votehud.glowAlpha = 0;
	self.votehud.color = ( 1.0, 1.0, 1.0 );
	self.votehud.hideWhenInMenu = true;

	self endon("disconnect");

	for( ;; ){
		if(level.voteState == 0){
			self.votehud setText( 
				CONST_RED + "VOTE IN PROGRESS [" + (level.currVoteTime - getTimeInSeconds()) + "]" + "\n" + 
				"\n" +
				CONST_RED + "[" + CONST_WHITE + "[{weapnext}]" + CONST_RED + "]"		+ CONST_WHITE + " - " + level.votesForMap[level.voteableMaps[0]] + " - " + level.adminMenuMapsName[level.voteableMaps[0]] + "\n" +
				CONST_RED + "[" + CONST_WHITE + "[{+actionslot 3}]" + CONST_RED + "]"	+ CONST_WHITE + " - " + level.votesForMap[level.voteableMaps[1]] + " - " + level.adminMenuMapsName[level.voteableMaps[1]] + "\n" +
				CONST_RED + "[" + CONST_WHITE + "[{+actionslot 4}]" + CONST_RED + "]"	+ CONST_WHITE + " - " + level.votesForMap[level.voteableMaps[2]] + " - " + level.adminMenuMapsName[level.voteableMaps[2]] + "\n" +
				CONST_RED + "[" + CONST_WHITE + "[{+actionslot 2}]" + CONST_RED + "]"	+ CONST_WHITE + " - " + level.votesForMap[level.voteableMaps[3]] + " - " + level.adminMenuMapsName[level.voteableMaps[3]] + "\n" +
				"\n" +
				CONST_RED + "Selected map:" 		+ "\n" + CONST_WHITE + getNextMap(level.nextMap) + "\n" +
				CONST_RED + "Selected gamemode:"	+ "\n" + CONST_WHITE + getGamemode(level.nextGamemode) + "\n"
			);
		} else if(level.voteState == 1){
			self.votehud setText( 
				CONST_RED + "VOTE IN PROGRESS [" + (level.currVoteTime - getTimeInSeconds()) + "]" + "\n" + 
				"\n" +
				CONST_RED + "[" + CONST_WHITE + "[{weapnext}]" + CONST_RED + "]"		+ CONST_WHITE + " - " + level.votesForGM[level.voteableGMs[0]] + " - " + level.voteGameTypeName[level.voteableGMs[0]] + "\n" +
				CONST_RED + "[" + CONST_WHITE + "[{+actionslot 3}]" + CONST_RED + "]"	+ CONST_WHITE + " - " + level.votesForGM[level.voteableGMs[1]] + " - " + level.voteGameTypeName[level.voteableGMs[1]] + "\n" +
				CONST_RED + "[" + CONST_WHITE + "[{+actionslot 4}]" + CONST_RED + "]"	+ CONST_WHITE + " - " + level.votesForGM[level.voteableGMs[2]] + " - " + level.voteGameTypeName[level.voteableGMs[2]] + "\n" +
				CONST_RED + "[" + CONST_WHITE + "[{+actionslot 2}]" + CONST_RED + "]"	+ CONST_WHITE + " - " + level.votesForGM[level.voteableGMs[3]] + " - " + level.voteGameTypeName[level.voteableGMs[3]] + "\n" +
				"\n" +
				CONST_RED + "Selected map:" 		+ "\n" + CONST_WHITE + getNextMap(level.nextMap) + "\n" +
				CONST_RED + "Selected gamemode:"	+ "\n" + CONST_WHITE + getGamemode(level.nextGamemode) + "\n"
			);
		} else if(level.voteState == 2){
			self.votehud setText( 
				CONST_RED + "STARTING GAME" + "\n" + 
				"\n" +
				CONST_RED + "Selected map:" 		+ "\n" + CONST_WHITE + getNextMap(level.nextMap) + "\n" +
				CONST_RED + "Selected gamemode:"	+ "\n" + CONST_WHITE + getGamemode(level.nextGamemode) + "\n"
			);
		}
		wait .25;
	}
}

getNextMap(map){
	if(map == -1){
		return "";
	}

	return level.adminMenuMapsName[map];
}

getGamemode(gm){
	if(gm == -1){
		return "";
	}

	return level.voteGameTypeName[gm];
}

// Better way to do this?
votebuttons(){
	self endon("disconnect");
	self notify("voted");

	wait .1;

	self thread vote2();
	self thread vote3();
	self thread vote4();
	self thread vote5();
}

vote2(){
	self endon("disconnect");
	self endon("voted");

	self waittill("vote2");

	if(level.voteState == 0){
		level.votesForMap[level.voteableMaps[0]]++;
	} else {
		level.votesForGM[level.voteableGMs[0]]++;
	}

	self notify("voted");
}

vote3(){
	self endon("disconnect");
	self endon("voted");

	self waittill("vote3");

	if(level.voteState == 0){
		level.votesForMap[level.voteableMaps[1]]++;
	} else {
		level.votesForGM[level.voteableGMs[1]]++;
	}

	self notify("voted");
}

vote4(){
	self endon("disconnect");
	self endon("voted");

	self waittill("vote4");

	if(level.voteState == 0){
		level.votesForMap[level.voteableMaps[2]]++;
	} else {
		level.votesForGM[level.voteableGMs[2]]++;
	}

	self notify("voted");
}

vote5(){
	self endon("disconnect");
	self endon("voted");

	self waittill("vote5");

	if(level.voteState == 0){
		level.votesForMap[level.voteableMaps[3]]++;
	} else {
		level.votesForGM[level.voteableGMs[3]]++;
	}

	self notify("voted");
}

getTimeInSeconds(){
	return int(getTime()/1000);
}