#include maps\mp\_utility;
#include common_scripts\utility;

main(){
	maps\mp\mp_underpass_precache::main();
	maps\createart\mp_underpass_art::main();
	maps\mp\mp_underpass_fx::main();
	maps\mp\_load::main();

	maps\mp\_compass::setupMiniMap( "compass_map_mp_underpass" );
	setdvar( "compassmaxrange", "2800" );

	//setExpFog( 500, 3500, .5, 0.5, 0.45, 1, 0 );
	ambientPlay( "none" );

	setdvar( "r_specularcolorscale", "3.1" );
	setdvar( "r_diffusecolorscale", ".78" );
	setdvar( "r_lightGridEnableTweaks", 1 );
	setdvar( "r_lightGridIntensity", 1.3 );
	setdvar( "r_lightGridContrast", .5 );

	precacheModel("me_electricbox4");
	precacheModel("foliage_pacific_bushtree01_halfsize_animated");
	precacheModel("com_pipe_4x96_metal");
	precacheModel("utility_water_collector");
	precacheModel("com_plasticcase_green_big_us_dirt");
	precacheModel("com_propane_tank02");
	precacheModel("foliage_pacific_bushtree01_animated");
	precacheModel("foliage_pacific_fern01_animated");
	precacheModel("com_ex_airconditioner");
	precacheModel("me_electricbox2");
	precacheModel("me_lightfluohang");
	precacheModel("foliage_tree_oak_1_animated2");
	precacheModel("com_trashbin02");
	precacheModel("hanging_short_sleeve");
	precacheModel("hanging_sheet");
	precacheModel("hanging_long_sleeve");
	precacheModel("hanging_apron");
	precacheModel("vehicle_van_slate_destructible");
	precacheModel("com_locker_double");
	precacheModel("machinery_oxygen_tank01");
	precacheModel("prop_photocopier_destructible_02");
	precacheModel("usa_gas_station_trash_bin_02");
	precacheModel("cs_wallfan1");
	precacheModel("machinery_oxygen_tank02");
	precacheModel("com_filecabinetblackclosed");
	precacheModel("prop_flag_neutral");
	precacheModel("vehicle_pickup_destructible_mp");
	precacheModel("foliage_pacific_fern02_animated");
	precacheModel("foliage_desertbrush_1_animated");
	precacheModel("foliage_cod5_tree_jungle_03_animated");
	precacheModel("foliage_cod5_tree_jungle_02_animated");
	precacheModel("foliage_pacific_palms08_animated");
	precacheModel("foliage_pacific_bushtree02_halfsize_animated");
	precacheModel("chicken_black_white");
	precacheModel("utility_transformer_ratnest01");
	precacheModel("utility_transformer_small01");
	precacheModel("com_bomb_objective");
	precacheModel("com_bomb_objective_d");
	precacheModel("mil_tntbomb_mp");
	precacheModel("com_pipe_4x128_metal");
	precacheModel("com_pipe_4x32_metal");
	precacheModel("com_pipe_4x96_gas");
	precacheModel("com_plasticcase_beige_big");
	precacheModel("com_laptop_2_open");
	precacheModel("com_cellphone_on");
	precacheModel("vehicle_mig29_desert");
	precacheModel("projectile_cbu97_clusterbomb");
	precacheModel("tag_origin");
	precacheModel("vehicle_van_slate_destroyed");
	precacheModel("vehicle_van_slate_hood");
	precacheModel("vehicle_van_wheel_lf");
	precacheModel("vehicle_van_slate_door_rb");
	precacheModel("vehicle_van_slate_mirror_l");
	precacheModel("vehicle_van_slate_mirror_r");
	precacheModel("vehicle_pickup_destroyed");
	precacheModel("vehicle_pickup_hood");
	precacheModel("vehicle_pickup_door_lf");
	precacheModel("vehicle_pickup_door_rf");
	precacheModel("vehicle_pickup_mirror_l");
	precacheModel("vehicle_pickup_mirror_r");
	precacheModel("me_electricbox4_dest");
	precacheModel("me_electricbox4_door");
	precacheModel("utility_water_collector_base_dest");
	precacheModel("com_propane_tank02_des");
	precacheModel("com_propane_tank02_valve");
	precacheModel("com_propane_tank02_cap");
	precacheModel("com_ex_airconditioner_dam");
	precacheModel("com_ex_airconditioner_fan");
	precacheModel("me_electricbox2_dest");
	precacheModel("me_electricbox2_door");
	precacheModel("me_electricbox2_door_upper");
	precacheModel("me_lightfluohang_single_destroyed");
	precacheModel("com_trashbin02_dmg");
	precacheModel("com_trashbin02_lid");
	precacheModel("com_locker_double_destroyed");
	precacheModel("machinery_oxygen_tank01_dam");
	precacheModel("machinery_oxygen_tank01_des");
	precacheModel("prop_photocopier_destroyed");
	precacheModel("prop_photocopier_destroyed_left_feeder");
	precacheModel("prop_photocopier_destroyed_right_shelf");
	precacheModel("prop_photocopier_destroyed_top");
	precacheModel("usa_gas_station_trash_bin_02_base");
	precacheModel("usa_gas_station_trash_bin_02_lid");
	precacheModel("cs_wallfan1_dmg");

	level.models[0] = "me_electricbox4";
	level.models[1] = "foliage_pacific_bushtree01_halfsize_animated";
	level.models[2] = "com_pipe_4x96_metal";
	level.models[3] = "utility_water_collector";
	level.models[4] = "com_plasticcase_green_big_us_dirt";
	level.models[5] = "com_propane_tank02";
	level.models[6] = "foliage_pacific_bushtree01_animated";
	level.models[7] = "foliage_pacific_fern01_animated";
	level.models[8] = "com_ex_airconditioner";
	level.models[9] = "me_electricbox2";
	level.models[10] = "me_lightfluohang";
	level.models[11] = "foliage_tree_oak_1_animated2";
	level.models[12] = "com_trashbin02";
	level.models[13] = "hanging_short_sleeve";
	level.models[14] = "hanging_sheet";
	level.models[15] = "hanging_long_sleeve";
	level.models[16] = "hanging_apron";
	level.models[17] = "vehicle_van_slate_destructible";
	level.models[18] = "com_locker_double";
	level.models[19] = "machinery_oxygen_tank01";
	level.models[20] = "prop_photocopier_destructible_02";
	level.models[21] = "usa_gas_station_trash_bin_02";
	level.models[22] = "cs_wallfan1";
	level.models[23] = "machinery_oxygen_tank02";
	level.models[24] = "com_filecabinetblackclosed";
	level.models[25] = "prop_flag_neutral";
	level.models[26] = "vehicle_pickup_destructible_mp";
	level.models[27] = "foliage_pacific_fern02_animated";
	level.models[28] = "foliage_desertbrush_1_animated";
	level.models[29] = "foliage_cod5_tree_jungle_03_animated";
	level.models[30] = "foliage_cod5_tree_jungle_02_animated";
	level.models[31] = "foliage_pacific_palms08_animated";
	level.models[32] = "foliage_pacific_bushtree02_halfsize_animated";
	level.models[33] = "chicken_black_white";
	level.models[34] = "utility_transformer_ratnest01";
	level.models[35] = "utility_transformer_small01";
	level.models[36] = "com_bomb_objective";
	level.models[37] = "com_bomb_objective_d";
	level.models[38] = "mil_tntbomb_mp";
	level.models[39] = "com_pipe_4x128_metal";
	level.models[40] = "com_pipe_4x32_metal";
	level.models[41] = "com_pipe_4x96_gas";
	level.models[42] = "com_plasticcase_beige_big";
	level.models[43] = "com_laptop_2_open";
	level.models[44] = "com_cellphone_on";
	level.models[45] = "vehicle_mig29_desert";
	level.models[46] = "projectile_cbu97_clusterbomb";
	level.models[47] = "tag_origin";
	level.models[48] = "vehicle_van_slate_destroyed";
	level.models[49] = "vehicle_van_slate_hood";
	level.models[50] = "vehicle_van_wheel_lf";
	level.models[51] = "vehicle_van_slate_door_rb";
	level.models[52] = "vehicle_van_slate_mirror_l";
	level.models[53] = "vehicle_van_slate_mirror_r";
	level.models[54] = "vehicle_pickup_destroyed";
	level.models[55] = "vehicle_pickup_hood";
	level.models[56] = "vehicle_pickup_door_lf";
	level.models[57] = "vehicle_pickup_door_rf";
	level.models[58] = "vehicle_pickup_mirror_l";
	level.models[59] = "vehicle_pickup_mirror_r";
	level.models[60] = "me_electricbox4_dest";
	level.models[61] = "me_electricbox4_door";
	level.models[62] = "utility_water_collector_base_dest";
	level.models[63] = "com_propane_tank02_des";
	level.models[64] = "com_propane_tank02_valve";
	level.models[65] = "com_propane_tank02_cap";
	level.models[66] = "com_ex_airconditioner_dam";
	level.models[67] = "com_ex_airconditioner_fan";
	level.models[68] = "me_electricbox2_dest";
	level.models[69] = "me_electricbox2_door";
	level.models[70] = "me_electricbox2_door_upper";
	level.models[71] = "me_lightfluohang_single_destroyed";
	level.models[72] = "com_trashbin02_dmg";
	level.models[73] = "com_trashbin02_lid";
	level.models[74] = "com_locker_double_destroyed";
	level.models[75] = "machinery_oxygen_tank01_dam";
	level.models[76] = "machinery_oxygen_tank01_des";
	level.models[77] = "prop_photocopier_destroyed";
	level.models[78] = "prop_photocopier_destroyed_left_feeder";
	level.models[79] = "prop_photocopier_destroyed_right_shelf";
	level.models[80] = "prop_photocopier_destroyed_top";
	level.models[81] = "usa_gas_station_trash_bin_02_base";
	level.models[82] = "usa_gas_station_trash_bin_02_lid";
	level.models[83] = "cs_wallfan1_dmg";
	level.models[84] = "machinery_oxygen_tank02_dam";
	level.models[85] = "machinery_oxygen_tank02_des";
	level.models[86] = "com_filecabinetblackclosed_dam";
	level.models[87] = "com_filecabinetblackclosed_des";
	level.models[88] = "com_filecabinetblackclosed_drawer";
	level.models[89] = "utility_transformer_ratnest01_dest";
	level.models[90] = "utility_transformer_small01_dest";
}