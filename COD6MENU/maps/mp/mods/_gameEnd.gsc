#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

freezePlayer(){
	self endon("stopFreezingAll");

	for( ;; ){
		self freezeControlsWrapper( true );
		self VisionSetNakedForPlayer( "black_bw", 0 );
		wait .05;
	}
}

gameEnd( winner ){
	if( !defined( winner ) ){
		notifyText = "It was a draw";
	} else {
		notifyText = "Winner: " + winner.name;
	}


	for( i = 0; i < level.players.size; i++ ){
		ply = level.players[i];

		ply thread freezePlayer();
	}

	wait 2;

	notifyData = spawnstruct();
	notifyData.titleText = "GAME OVER"; //Line 1
	notifyData.notifyText = notifyText; //Line 2
	notifyData.iconName = "cardicon_kinggorilla";
	notifyData.glowColor = (0.3, 0.6, 0.3); //RGB Color array divided by 100
	notifyData.duration = 6.0;

	for( i = 0; i < level.players.size; i++ ){
		ply = level.players[i];

		ply thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	}

	wait 8;

	restartGame();
}

restartGame(){
	map_restart( true );
	/*
	maps\mp\_mouse_menu::doGamemodesOff( getDvar( "mod" ) );
	setDvar("mod", getDvar( "mod" ) );

	for( i = 0; i < level.players.size; i++ ){
		ply = level.players[i];

		ply notify("stopFreezingAll");
		ply VisionSetNakedForPlayer( getDvar("mapname"), 0 );

		ply.currKills = "undefined";

		ply suicide();
	}
	*/
}