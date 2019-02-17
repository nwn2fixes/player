// s04_a_army_spawn
/*
	Script to spawn in The Army of the Dead.
*/
// BN 5/27/08

#include "kinc_spawn"


void main()
{
	object oPC = GetFirstPC();
	object oArea = GetArea(oPC);
	
	SpawnIt("s04_skeleton_legionaire");
	SpawnIt("s04_skeleton_legionaire2");
	SpawnIt("s04_skeleton_legionaire3");
	SpawnIt("s04_skeleton_legionaire4");
	SpawnIt("s04_skeleton_legionaire5");
	SpawnIt("s04_skeleton_legionaire6");
	SpawnIt("s04_skeleton_legionaire7");
	SpawnIt("s04_skeleton_legionaire8");
	SpawnIt("s04_skeleton_legionaire9");
	SpawnIt("s04_skeleton_legionaire10");
	SetTime(20,0,0,0);
	SetGlobalInt("S_bArmyOfDeadRaised", 1);
	SetGlobalInt("S_bGothaladreumDone", 1);
	MusicBackgroundSetDelay(oArea,1);
	MusicBackgroundChangeDay(oArea,86);
	MusicBackgroundChangeNight(oArea,86);
	
}