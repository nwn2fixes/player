// 20_inc_cyran
//
// Functions for the stop the blacklake murderer quest
//
// EPF 2/13/06

#include "ginc_journal"
#include "ginc_effect"
#include "ginc_group"
#include "ginc_ai"
//#include "nw_i0_2q4luskan"
	
const string GROUP_WAVE1 = "20grpwave1";
const string GROUP_WAVE2 = "20grpwave2";
const string GROUP_SOLDIERS = "20grpsoldiers";
const string GROUP_WAVE3 = "20grpwave3";
const string GROUP_WAVE4 = 	"20grpwave4";
const string GROUP_CYRAN_KILLERS = "20grpcyrankill";
const string GROUP_QAGGOTH = "20grpqaggoth";
const string FX_MIST = "fx_black_cloud_big";
const string FX_MIST_SMALL = "fx_black_cloud_small";

const string TAG_PATRON = "20_mask_patron";
const string TAG_ENTERTAINER = "20_mask_entertainer";
const string TAG_MASK_DEMONS = "20_mask_demon";

const int WAVE3_ROUND_DELAY = 6;
	
//sort of a makeshift enum for the spawning functions.
const int MEPHIT = 1;
const int SUCCUBUS = 2;
const int ERINYES = 3;
const int NUM_MEPHIT_SPAWNS = 10;
const int NUM_SUCCUBUS_SPAWNS = 3;
const int NUM_ERINYES_SPAWNS = 2;

void SpawnCreatureTypeForWave(string sGroup,int nCreature, int nToSpawn, int nWave)
{
	PrettyDebug("Spawning wave " + IntToString(nWave));
	object oWP, oCreature;
	string sRR, sWP, sTag;
	int i = 0, nSpawns;
	
	sTag = "20_wave" + IntToString(nWave);
	switch(nCreature)
	{
	case MEPHIT:
		sRR = "20_fire_mephit";
		sWP = "2080_wp_mephit_sp";
		nSpawns = NUM_MEPHIT_SPAWNS;
		break;
	case SUCCUBUS:
		sRR = "20_succubus";
		sWP = "2080_wp_succubus_sp";
		nSpawns = NUM_SUCCUBUS_SPAWNS;
		break;
	case ERINYES:
		sRR = "20_erinyes";
		sWP = "2080_wp_erinyes_sp";
		nSpawns = NUM_ERINYES_SPAWNS;
		break;
	}
	
	
	oWP = GetObjectByTag(sWP,i);
	while(i < nToSpawn && GetIsObjectValid(oWP))
	{
		oCreature = CreateObject(OBJECT_TYPE_CREATURE, sRR, GetLocation(oWP),FALSE,sTag);
		GroupAddMember(sGroup,oCreature);
		i++;
		//distribute evenly over the spawn points
		oWP = GetObjectByTag(sWP,i % nSpawns);
		
	}	
}

// Guff and Wetherly appear outside the Tavorick estate	
int GetIsReadyForCyranDoorGuards()
{
	object oPC = GetFactionLeader(GetFirstPC());
	int nEntry = GetJournalQuestEntry("20_tavorick",oPC);
	return  (nEntry > 0 && nEntry < 20);
}

int GetSpawnQaggoth()
{
	object oMod = GetModule();
	int nEntry = GetJournalEntry("20_tavorick",GetOwnedCharacter(GetFactionLeader(GetFirstPC())));
		
	if(nEntry == 40 && !GetLocalInt(oMod,"bFoughtQaggoth"))
	{
		return TRUE;
	}
	return FALSE;
}

//this is for the Moonstone Mask demons
int GetIsReadyForDemons(object oPC)
{
	return (GetJournalQuestEntry("20_tavorick",oPC) >= 40 && GetJournalQuestEntry("20_tavorick",oPC) < 70);
}

//this is for the Moonstone Mask demons
int GetIsReadyForPostDemonCleanup(object oPC)
{
	return (GetJournalQuestEntry("20_tavorick",oPC) >= 70 && !GetLocalInt(GetModule(), "bCleanedMask"));
}

//True if the henchmen should be removed from the party when the player exits 2080
int GetClearHenchmen()
{

	object oMod = GetModule();
	return (GetLocalInt(oMod, "bCyranDead") || GetLocalInt(oMod,"bFoughtQaggoth"));
}

void MyCreateObjectVoid(int nObjectType, string sTemplate, location lLocation, string sNewTag)
{
	CreateObject(nObjectType, sTemplate, lLocation, FALSE, sNewTag);
}

void MyGroupDetermineCombatRound(string sGroup)
{
	object oMem = GetFirstInGroup(sGroup);
	while(GetIsObjectValid(oMem))
	{
		AssignCommand(oMem, ActionDoCommand(DetermineCombatRound()));
		oMem = GetNextInGroup(sGroup);
	}
}

void MyGroupSetScriptHidden(string sGroup, int bHide)
{
	object oMem = GetFirstInGroup(sGroup);

	while(GetIsObjectValid(oMem))
	{
		SetScriptHidden(oMem,bHide);
		oMem = GetNextInGroup(sGroup);
	}
}


void InitTorches(object oNear)
{
	int i = 1;
	object oWP = GetNearestObjectByTag("20_wp_cyran_torch" + IntToString(i),oNear);
	while(GetIsObjectValid(oWP))
	{
		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "20_fx_torch", GetLocation(oWP), FALSE,"20_fx_torch" + IntToString(i));
//		CreateObject(OBJECT_TYPE_LIGHT, "20_lt_torch", GetLocation(oWP), FALSE, "20_lt_torch" + IntToString(i));	
		i++;
		oWP = GetNearestObjectByTag("20_wp_cyran_torch" + IntToString(i),oNear);
	}
	
	i = 1;
	oWP = GetNearestObjectByTag("20_wp_cyran_torch", oNear, i);	//these we don't do the switch in the cutscene
	while(GetIsObjectValid(oWP))
	{
		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "20_fx_torch", GetLocation(oWP), FALSE,"20_fx_torch");
//		CreateObject(OBJECT_TYPE_LIGHT, "20_lt_torch", GetLocation(oWP), FALSE, "20_lt_torch");	
		i++;
		oWP = GetNearestObjectByTag("20_wp_cyran_torch",oNear, i);
	}
}

//change lights and effects on torches
void ExchangeTorches(object oNear)
{
	int i = 1;
	float fDelay = 1.f;
	string sI;
	object oWP = GetNearestObjectByTag("20_wp_cyran_torch" + IntToString(i),oNear);
	while(GetIsObjectValid(oWP))
	{
		sI = IntToString(i);
		DestroyObject(GetNearestObjectByTag("20_fx_torch" + sI, oNear), fDelay);
//		DestroyObject(GetNearestObjectByTag("20_lt_torch" + sI, oNear), fDelay);

		DelayCommand(fDelay, MyCreateObjectVoid(OBJECT_TYPE_PLACED_EFFECT, "20_fx_torch_blue", GetLocation(oWP), "20_fx_torch_blue" + sI));
//		DelayCommand(fDelay, MyCreateObjectVoid(OBJECT_TYPE_LIGHT, "20_lt_torch_blue", GetLocation(oWP), "20_lt_torch_blue" +sI));	
		i++;
		oWP = GetNearestObjectByTag("20_wp_cyran_torch" + IntToString(i),oNear);
		fDelay += 1.f;
	}
}

//we do this after the special shot of 4 torches going blue, so they all match
void SwitchAllTorches(object oNear)
{
	int i = 1;
	object oWP = GetNearestObjectByTag("20_wp_cyran_torch",oNear, i);
	object oFX;
	//PrettyDebug("Switching torches.");
	while(GetIsObjectValid(oWP))
	{
	//	PrettyDebug("Valid Waypoint.");
	//	oFX = GetNearestObjectByTag("20_fx_torch", oNear, i);
	//	if(GetIsObjectValid(oFX))
	//	{
	//		PrettyDebug("Found a valid torch.");
	//	}
		DestroyObject(GetNearestObjectByTag("20_fx_torch", oNear, i), 0.2);
		DestroyObject(GetNearestObjectByTag("20_lt_torch", oNear, i), 0.2);

		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "20_fx_torch_blue", GetLocation(oWP), FALSE,"20_fx_torch_blue");
//		CreateObject(OBJECT_TYPE_LIGHT, "20_lt_torch_blue", GetLocation(oWP), FALSE,"20_lt_torch_blue");	
		i++;
		oWP = GetNearestObjectByTag("20_wp_cyran_torch",oNear, i);
	}
}

void ExplodeBarrel(object oBarrel)
{
	object oPC = GetFirstPC();
	location lBarrel = GetLocation(oBarrel);
	ApplySEFToLocation("sp_fireball_hit_aoe.sef",lBarrel);

	object oVictim = GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_LARGE, lBarrel);
	while(GetIsObjectValid(oVictim))
	{
		//Don't damage neutral guys
		if(GetFactionEqual(oVictim, oPC) || GetIsEnemy(oPC, oVictim))
		{
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(8)),oVictim); // kamal
		}
		oVictim = GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_HUGE,lBarrel);
	}
	DestroyObject(oBarrel);
}

	
void SpawnBarricades(object oNear)
{
	object oWP;
	int i = 1;
	
	oWP = GetNearestObjectByTag("2080_wp_barricades",oNear,i);
	while(GetIsObjectValid(oWP))
	{
		CreateObject(OBJECT_TYPE_PLACEABLE,"20_plc_barricade",GetLocation(oWP));
		i++;
		oWP = GetNearestObjectByTag("2080_wp_barricades",oNear,i);
	}
}

void SpawnFireWalls(object oNear)
{
	int i = 1;
	location lTarget;
	object oWP = GetNearestObjectByTag("20_wp_firewall_sp",oNear,i);
	while(GetIsObjectValid(oWP))
	{
		lTarget = GetLocation(oWP);
		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "20_fx_firewall_blue", lTarget);;
		CreateObject(OBJECT_TYPE_PLACEABLE, "2080_plc_collision_box", lTarget);
		i++;
		oWP = GetNearestObjectByTag("20_wp_firewall_sp",oNear,i);
	}
}

void DespawnFireWalls(object oNear)
{
	int i = 1;
	location lTarget;
	object oFX = GetNearestObjectByTag("20_fx_firewall_blue",oNear,i);
	object oBox = GetNearestObjectByTag("2080_plc_collision_box",oNear,i);;
	
	while(GetIsObjectValid(oFX))
	{
		DestroyObject(oFX, 0.3f);
		i++;
		oFX = GetNearestObjectByTag("20_fx_firewall_blue",oNear,i);
	}
	i = 1;
	while(GetIsObjectValid(oBox))
	{
		DestroyObject(oBox, 0.3f);
		i++;
		oBox = GetNearestObjectByTag("2080_plc_collision_box",oNear,i);
	}	
}

void PlaceBarrels(object oNear)
{
	int nBarrelState = GetLocalInt(GetModule(),"nBarrelState");

	//this is a prefix -- we'll determine the waypoint below according to the barrel state variable
	//set in the 20_ballard dialogue.
	string sWP = "20_wp_barrel_";
	object oWP1, oWP2;

	object oBarrel1 = GetNearestObjectByTag("20_plc_blastglobes",oNear);
	object oBarrel2 = GetNearestObjectByTag("20_plc_blastglobes",oNear,2);


	//old barrels -- they were preplaced.  Delete.
	DestroyObject(oBarrel1);
	DestroyObject(oBarrel2);
	
	switch(nBarrelState)
	{
	case 1:	//both at entrance
		sWP += "entrance";
		break;
	case 2:	//one at each southern door
		sWP += "south";
		break;
	case 3:	//both at western door
		sWP += "west";
		break;
	}

	oWP1 = GetNearestObjectByTag(sWP + IntToString(1),oNear);
	oWP2 = GetNearestObjectByTag(sWP + IntToString(2),oNear);

	CreateObject(OBJECT_TYPE_PLACEABLE, "20_plc_blastglobes",GetLocation(oWP1));
	CreateObject(OBJECT_TYPE_PLACEABLE, "20_plc_blastglobes",GetLocation(oWP2));
}

void SpawnMist(object oNear)
{
	object oWP;
	int i = 1;
	
	oWP = GetNearestObjectByTag("2080_wp_mist",oNear,i);
	while(GetIsObjectValid(oWP))
	{
		ApplySEFToLocation(FX_MIST,GetLocation(oWP), 600.f);
		i++;
		oWP = GetNearestObjectByTag("2080_wp_mist",oNear,i);
	}
}


void StartWave3Timer()
{
	SetLocalInt(GetArea(OBJECT_SELF), "bWave3TimerRunning",TRUE);
}

void UnleashWave2()
{
	//GroupAddNearestTag(GROUP_WAVE2,"20_wave2",OBJECT_SELF);
	//MyGroupSetScriptHidden(GROUP_WAVE2,FALSE);
	SpawnCreatureTypeForWave(GROUP_WAVE2,MEPHIT, 7, 2);
	SpawnCreatureTypeForWave(GROUP_WAVE2,SUCCUBUS, 2, 2);
	GroupGoHostile(GROUP_WAVE2);
	MyGroupDetermineCombatRound(GROUP_WAVE2);
	GroupMoveToWP(GROUP_WAVE2, "20_cyran_center",MOVE_RUN);
	StartWave3Timer();
}

void UnleashWave3()
{
	object oPC = GetFactionLeader(GetFirstPC());

//	GroupAddNearestTag(GROUP_WAVE3, "20_wave3",oPC);
//	MyGroupSetScriptHidden(GROUP_WAVE3,FALSE);
	SpawnCreatureTypeForWave(GROUP_WAVE3,MEPHIT, 9,3);
	SpawnCreatureTypeForWave(GROUP_WAVE3,SUCCUBUS,2,3);
	SpawnCreatureTypeForWave(GROUP_WAVE3,ERINYES,2,3);
	GroupOnDeathBeginConversation(GROUP_WAVE3, "20_ballard", "20_ballard_interlude2");
	GroupGoHostile(GROUP_WAVE3);
	GroupMoveToWP(GROUP_WAVE3, "20_cyran_center",MOVE_RUN);
	MyGroupDetermineCombatRound(GROUP_WAVE3);
	
}

void OpenSouthDoors()
{
	object oDoor1 = GetNearestObjectByTag("20_dr_cyran_south1");
	object oDoor2 = GetNearestObjectByTag("20_dr_cyran_south2");

	DestroyObject(oDoor1);
	DestroyObject(oDoor2);
}


	
int GetDead(object oGuy)
{
	if (GetIsDead(oGuy) || !GetIsObjectValid(oGuy))
		return 1;

	return 0;
}

int GetNumSoldiersDead()
{
	object oFinn = GetObjectByTag("20_finn");
	object oDeorwin = GetObjectByTag("20_deorwin");
	object oWetherly = GetObjectByTag("20_wetherly");
	object oBallard = GetObjectByTag("20_ballard");
	object oGuff =  GetObjectByTag("20_guff");
	
	return GetDead(oFinn) + GetDead(oDeorwin) + GetDead(oWetherly) + GetDead(oBallard) + GetDead(oGuff);
}

void MakeSoldierGroup(object oPC, int bAddGuffAndWetherly = TRUE)
{
	ResetGroup(GROUP_SOLDIERS);
	if(bAddGuffAndWetherly)
	{
		GroupAddNearestTag(GROUP_SOLDIERS, "20_guff",oPC);
		GroupAddNearestTag(GROUP_SOLDIERS, "20_wetherly",oPC);
	}
	GroupAddNearestTag(GROUP_SOLDIERS, "20_ballard",oPC);
	RemoveHenchman(oPC, GetNearestObjectByTag("20_finn",oPC));
	RemoveHenchman(oPC, GetNearestObjectByTag("20_deorwin",oPC));
	GroupAddNearestTag(GROUP_SOLDIERS, "20_finn",oPC);
	GroupAddNearestTag(GROUP_SOLDIERS, "20_deorwin",oPC);
	GroupChangeToStandardFaction(GROUP_SOLDIERS, STANDARD_FACTION_DEFENDER);
}

void SoldiersProtectPlayer(object oPC)
{
	object oMem = GetFirstInGroup(GROUP_SOLDIERS);
	while(GetIsObjectValid(oMem))
	{
		AIMakeProtector(oMem, oPC);
		oMem = GetNextInGroup(GROUP_SOLDIERS);
	}
}

void SoldiersGoRanged()
{
	object oMem = GetFirstInGroup(GROUP_SOLDIERS);
	while(GetIsObjectValid(oMem))
	{
		AssignCommand(oMem, SetCombatCondition(X0_COMBAT_FLAG_RANGED));
		AIAttackPreference(oMem, ATTACK_PREFERENCE_GROUPATTACK,100);
		AssignCommand(oMem, ActionEquipMostDamagingRanged());
		oMem = GetNextInGroup(GROUP_SOLDIERS);
	}	
}

void SoldiersStandGround()
{
	GroupSetSemicircleFormation(GROUP_SOLDIERS);
	GroupMoveToWP(GROUP_SOLDIERS, "20_cyran_upstairs_exit",MOVE_RUN);
	object oMem = GetFirstInGroup(GROUP_SOLDIERS);
	while(GetIsObjectValid(oMem))
	{
		AIFinitePursuit(oMem, 6.f);
		oMem = GetNextInGroup(GROUP_SOLDIERS);
	}
}

void StopAndRemove(object oPC, object oHench)
{
	RemoveHenchman(oPC, oHench);
	AIResetType(oHench);
	AssignCommand(oHench, SetAssociateState(NW_ASC_MODE_STAND_GROUND));
	AssignCommand(oHench, ClearAllActions(TRUE));
}

// for when the player is done with things.
void ClearSoldierHenchmen(object oPC)
{
	PrettyDebug("Clearing henchmen.");
	object oFinn = GetNearestObjectByTag("20_finn",oPC);
	object oDeorwin = GetNearestObjectByTag("20_deorwin",oPC);
	object oWetherly = GetNearestObjectByTag("20_wetherly",oPC);
	object oBallard = GetNearestObjectByTag("20_ballard",oPC);
	object oGuff =  GetNearestObjectByTag("20_guff",oPC);
	object oCyran = GetNearestObjectByTag("20_cyran",oPC);

	StopAndRemove(oPC, oFinn);
	StopAndRemove(oPC, oDeorwin);
	StopAndRemove(oPC, oBallard);
	StopAndRemove(oPC, oWetherly);
	StopAndRemove(oPC, oGuff);
	StopAndRemove(oPC, oCyran);	
}