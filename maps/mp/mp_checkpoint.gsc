#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_maps;

main(){
	maps\mp\mp_checkpoint_precache::main();
	maps\createart\mp_checkpoint_art::main();
	// maps\mp\mp_checkpoint_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_checkpoint" );

	// raise up planes to avoid them flying through buildings
	level.airstrikeHeightScale = 1.5;

	// ambientPlay( "ambient_mp_urban" );

	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.27 );
	setdvar( "r_lightGridContrast", 1 );

	setdvar( "r_specularcolorscale", "2" );

	setdvar( "compassmaxrange", "1600" );

	if( getDvar( "mapmod" ) == "karachi_0"){
		level.customSpawnPoints = [];
		level.customSpawnPoints["allies"] = [];
		level.customSpawnPoints["axis"] = [];
		level.customSpawnPoints["allies"]["origin"] = [];
		level.customSpawnPoints["allies"]["angles"] = [];
		level.customSpawnPoints["axis"]["origin"] = [];
		level.customSpawnPoints["axis"]["angles"] = [];

		wait 1;

		thread CreateWalls( (2038.69, -3832.18, 95.8974), (2160.19, -3919.6, 194.058) ); // Right wall
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
	}
}