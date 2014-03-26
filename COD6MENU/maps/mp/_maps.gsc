#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

buildMap( modName ){
	level.customSpawnPoints = [];
	level.customSpawnPoints["allies"] = [];
	level.customSpawnPoints["axis"] = [];
	level.customSpawnPoints["allies"]["origin"] = [];
	level.customSpawnPoints["allies"]["angles"] = [];
	level.customSpawnPoints["axis"]["origin"] = [];
	level.customSpawnPoints["axis"]["angles"] = [];

	map = getDvar("mapname");

	switch( map ){
		case "mp_checkpoint":
			karachi( modName );
			break;

		default:
			iPrintLn("Current map doesn't have any mods.");

	}
}

karachi( modName ){
	switch( modName ){
		case "karachi_0":
			removeAllObjects();

			thread CreateWalls( (1889.65, -3169.42, 121.985), (3982.07, -3188.19, -1.80945) ); // Right wall
			thread CreateWalls( (2764.23, -1959.54, 80), (3980.81, -1938.08, 0 ) ); // Left wall
			thread CreateWalls( (3210.22, -2268.57, 161.358), (3207.98, -2045.82, 10) ); // Wall in house near death hole

			thread CreateGrids( (3489.06, -2658.81, 30), (3331.13, -2833.57, 30), (0, 0, 0) ); // Hole at staircase
			thread CreateWalls( (2919.3, -2586.33, 355 ), (2922.57, -2821.57, 385 ) ); // Cover wall on roof

			thread CreateGrids( (3104.87, -2061.82, 338.575), (2950.14, -2173.56, 333.363), (0, 0, 0) ); // Hole on roof
			thread CreateRamps( (3583.05, -2775.29, 400), (3518.38, -2374.49, 179.784) ); // Ramp outside of house

			thread CreateGrids( (3169.13, -2868.17, 265), (3300.86, -3109.57, 265), (0, 0, 0) ); // Hole on 2nd floor

			thread CreateWalls( (3217.29, -2267.57, 211.625), (3208.97, -2093.84, 212.256) ); // Cover wall for first floor

			thread CreateWalls( (3233.13, -2009.57, 329.375), (3472.87, -2004.48, 164.942) ); // Outside wall first floor
			thread CreateWalls( (2945.13, -2005.57, 344.214), (3184.86, -2000.11, 473.517) ); // outside wall top floor

			thread CreateRamps( (3316.29, -2692.96, 191.92), (3484.88, -2699.66, 311.68) ); // Staircase

			thread CreateRamps( (3031.18, -2841.57, 398.849), (3028.01, -2737.89, 313.373) ); // Ramp on top floor

			level.customSpawnPoints["allies"]["origin"][0] = ( 3819, -2135, 22 );
			level.customSpawnPoints["allies"]["angles"][0] = ( 0, -178, 0 );
			level.customSpawnPoints["allies"]["origin"][1] = ( 3807, -2426, 18 );
			level.customSpawnPoints["allies"]["angles"][1] = ( 0, -178, 0 );
			level.customSpawnPoints["allies"]["origin"][2] = ( 3802, -2729, 13 );
			level.customSpawnPoints["allies"]["angles"][2] = ( 0, -178, 0 );
			level.customSpawnPoints["allies"]["origin"][3] = ( 2980, -2894, 36 );
			level.customSpawnPoints["allies"]["angles"][3] = ( 0, -89, 0 );
			level.customSpawnPoints["allies"]["origin"][4] = ( 2965, -2594, 60 );
			level.customSpawnPoints["allies"]["angles"][4] = ( 0, -89, 0 );
			level.customSpawnPoints["allies"]["origin"][5] = ( 3278, -2072, 60 );
			level.customSpawnPoints["allies"]["angles"][5] = ( 0, 0, 0 );
			level.customSpawnPoints["allies"]["origin"][6] = ( 3268, -2225, 60 );
			level.customSpawnPoints["allies"]["angles"][6] = ( 0, 0, 0 );
			level.customSpawnPoints["allies"]["origin"][7] = ( 3591, -3104, 417 );
			level.customSpawnPoints["allies"]["angles"][7] = ( 0, 180, 0 );
			level.customSpawnPoints["allies"]["origin"][8] = ( 3453, -2109, 364 );
			level.customSpawnPoints["allies"]["angles"][8] = ( 0, 180, 0 );
			level.customSpawnPoints["allies"]["origin"][9] = ( 3466, -2419, 364 );
			level.customSpawnPoints["allies"]["angles"][9] = ( 0, 180, 0 );
			level.customSpawnPoints["allies"]["origin"][9] = ( 3517, -2897, 298 );
			level.customSpawnPoints["allies"]["angles"][9] = ( 0, 180, 0 );

			level.customSpawnPoints["axis"]["origin"][0] = ( 1064, -3266, 132 );
			level.customSpawnPoints["axis"]["angles"][0] = ( 0, 90, 0 );
			level.customSpawnPoints["axis"]["origin"][1] = ( 1241, -2392, 53 );
			level.customSpawnPoints["axis"]["angles"][1] = ( 0, 90, 0 );
			level.customSpawnPoints["axis"]["origin"][2] = ( 1469, -2060, 30 );
			level.customSpawnPoints["axis"]["angles"][2] = ( 0, 130, 0 );
			level.customSpawnPoints["axis"]["origin"][3] = ( 1451, -2111, 26 );
			level.customSpawnPoints["axis"]["angles"][3] = ( 0, -99, 0 );
			level.customSpawnPoints["axis"]["origin"][4] = ( 1945, -2967, 43 );
			level.customSpawnPoints["axis"]["angles"][4] = ( 0, -90, 0 );
			level.customSpawnPoints["axis"]["origin"][5] = ( 783, -3297, 46 );
			level.customSpawnPoints["axis"]["angles"][5] = ( 0, 33, 0 );

			break;
	}
}

onPlayerSpawned(){
	if( getDvar("g_gametype") != "dm" ) {
		randomPoint = randomInt( level.customSpawnPoints[ self.team ]["origin"].size );

		self SetOrigin( level.customSpawnPoints[ self.team ]["origin"][ randomPoint ] );
		self SetPlayerAngles( level.customSpawnPoints[ self.team ]["angles"][ randomPoint ] );
	} else {
		// If FFA
		if( randomInt( 100 ) > 49 ){
			team = "axis";
		} else {
			team = "allies";
		}

		randomPoint = randomInt( level.customSpawnPoints[ team ]["origin"].size );

		self SetOrigin( level.customSpawnPoints[ team ]["origin"][ randomPoint ] );
		self SetPlayerAngles( level.customSpawnPoints[ team ]["angles"][ randomPoint ] );
	}


	//iPrintLn("Spawnpoint " + randomPoint + " - Size: " +  level.customSpawnPoints[ self.team ]["origin"].size );


}

removeAllObjects(){
	models = GetEntArray("script_model","classname");
	for(i=0;i<models.size;i++)
	    models[i] delete();

	/*
	This is used for the crate collisions so nono removal
	smodels = GetEntArray("script_brushmodel","classname");
	for(i=0;i<smodels.size;i++)
	    smodels[i] delete();*/

	destructibles = GetEntArray("destructible","targetname");
	for(i=0;i<destructibles.size;i++)
	    destructibles[i] delete();

	animated_models = getentarray( "animated_model", "targetname" );
	for(i=0;i<animated_models.size;i++)
	    animated_models[i] delete();

	ents = getentarray("destructable", "targetname");
	for(i=0;i<ents.size;i++)
	    ents[i] delete();

	barrels = getentarray ("explodable_barrel","targetname");
	for(i=0;i<barrels.size;i++)
	    barrels[i] delete();

	radiationFields = getentarray("radiation", "targetname");
	for(i=0;i<radiationFields.size;i++)
	    radiationFields[i] delete();

	killzones = getentarray("trigger_hurt", "targetname");
	for(i=0;i<killzones.size;i++)
	    killzones[i] delete();

	level deletePlacedEntity("misc_turret");
}

CreateBlocks(pos, angle)
{
	block = spawn("script_model", pos );
	block setModel("com_plasticcase_friendly");
	block.angles = angle;
	block Solid();
	block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
	wait 0.01;
}

CreateRamps(top, bottom)
{
	D = Distance(top, bottom);
	blocks = roundUp(D/30);
	CX = top[0] - bottom[0];
	CY = top[1] - bottom[1];
	CZ = top[2] - bottom[2];
	XA = CX/blocks;
	YA = CY/blocks;
	ZA = CZ/blocks;
	CXY = Distance((top[0], top[1], 0), (bottom[0], bottom[1], 0));
	Temp = VectorToAngles(top - bottom);
	BA = (Temp[2], Temp[1] + 90, Temp[0]);
	for(b = 0; b < blocks; b++){
		block = spawn("script_model", (bottom + ((XA, YA, ZA) * b)));
		block setModel("com_plasticcase_friendly");
		block.angles = BA;
		block Solid();
		block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
		wait 0.01;
	}
	block = spawn("script_model", (bottom + ((XA, YA, ZA) * blocks) - (0, 0, 5)));
	block setModel("com_plasticcase_friendly");
	block.angles = (BA[0], BA[1], 0);
	block Solid();
	block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
	wait 0.01;
}

CreateGrids(corner1, corner2 )
{
	W = Distance((corner1[0], 0, 0), (corner2[0], 0, 0));
	L = Distance((0, corner1[1], 0), (0, corner2[1], 0));
	H = Distance((0, 0, corner1[2]), (0, 0, corner2[2]));
	CX = corner2[0] - corner1[0];
	CY = corner2[1] - corner1[1];
	CZ = corner2[2] - corner1[2];
	ROWS = roundUp(W/55);
	COLUMNS = roundUp(L/30);
	HEIGHT = roundUp(H/20);
	XA = CX/ROWS;
	YA = CY/COLUMNS;
	ZA = CZ/HEIGHT;
	center = spawn("script_model", corner1);
	for(r = 0; r <= ROWS; r++){
		for(c = 0; c <= COLUMNS; c++){
			for(h = 0; h <= HEIGHT; h++){
				block = spawn("script_model", (corner1 + (XA * r, YA * c, ZA * h)));
				block setModel("com_plasticcase_friendly");
				block.angles = (0, 0, 0);
				block Solid();
				block LinkTo(center);
				block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
				wait 0.01;
			}
		}
	}
	center.angles = ( 0, 0, 0 );
}

CreateWalls(start, end)
{
	D = Distance((start[0], start[1], 0), (end[0], end[1], 0));
	H = Distance((0, 0, start[2]), (0, 0, end[2]));
	blocks = roundUp(D/55);
	height = roundUp(H/30);
	CX = end[0] - start[0];
	CY = end[1] - start[1];
	CZ = end[2] - start[2];
	XA = (CX/blocks);
	YA = (CY/blocks);
	ZA = (CZ/height);
	TXA = (XA/4);
	TYA = (YA/4);
	Temp = VectorToAngles(end - start);
	Angle = (0, Temp[1], 90);
	for(h = 0; h < height; h++){
		block = spawn("script_model", (start + (TXA, TYA, 10) + ((0, 0, ZA) * h)));
		block setModel("com_plasticcase_friendly");
		block.angles = Angle;
		block Solid();
		block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
		wait 0.001;
		for(i = 1; i < blocks; i++){
			block = spawn("script_model", (start + ((XA, YA, 0) * i) + (0, 0, 10) + ((0, 0, ZA) * h)));
			block setModel("com_plasticcase_friendly");
			block.angles = Angle;
			block Solid();
			block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
			wait 0.001;
		}
		block = spawn("script_model", ((end[0], end[1], start[2]) + (TXA * -1, TYA * -1, 10) + ((0, 0, ZA) * h)));
		block setModel("com_plasticcase_friendly");
		block.angles = Angle;
		block Solid();
		block CloneBrushmodelToScriptmodel( level.airDropCrateCollision );
		wait 0.001;
	}
}


roundUp( floatVal )
{
	if ( int( floatVal ) != floatVal )
		return int( floatVal+1 );
	else
		return int( floatVal );
}