// '3541a_cut_garius'
//
// kevL 2016 oct 3 - fix Garius and nightwalker.


#include "ginc_misc"
#include "ginc_effect"
#include "ginc_companions"
#include "ginc_debug"
#include "ginc_math"
#include "3541_inc"

// Functions

void UnhideGarius();
void UnhideAllies();
void DestroySoldiers();
void CreateGariusVictims();
void AnimateSoldiers();
void GariusAttacks();
void MoveCameraTracker1();
void MoveGarius();
void ChangeArcherFaction();
void GariusDestroysArchers();
void UnhideAndMoveGariusCrew();
void DeathEnsurance2();
void StartPairsBattle();
void SpawnAmmonAndZhjaeve();
void MoveGariusAgain();
void MoveAmmonAndZhjaeve();
void GariusCreatesPortal();
void GariusCreatesFireWall();
void GariusTeleportsOnWall();
void NightWalkerFlourish();
void GariusGoesHostile();
void AddAmmonAndZhjaeveToParty();
void NightWalkerGoesHostile();

//

void main(int nChoice)
{
	object oPC = GetFirstPC();
	object oRegulator = GetTarget(TAG_CUTSCENE_REGULATOR);

	switch(nChoice)
	{
		case 1:
			ActionPauseCutscene(1000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(1.0f));
			break;

		case 2:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			break;

		case 3:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
			break;

		case 5:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			DestroySoldiers();
			CreateGariusVictims();
			UnhideAllies();
			break;

		case 7:
			AnimateSoldiers();
			break;

		case 10:
			UnhideGarius();
			break;

		case 15:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			GariusAttacks();
			break;

		case 16:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			MoveGarius();
			break;

		case 17:
			ActionPauseCutscene(7000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(7.0f));
			MoveCameraTracker1();
			ChangeArcherFaction();
			GariusDestroysArchers();
			break;

		case 25:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
			UnhideAndMoveGariusCrew();
			DeathEnsurance2();
			break;

		case 30:
			StartPairsBattle();
			SpawnAmmonAndZhjaeve();
			break;

		case 50:
			SpawnAmmonAndZhjaeve();
			break;

		case 60:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			MoveAmmonAndZhjaeve();
//			MoveGariusAgain();
			break;

		case 70:
			ActionPauseCutscene(8000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(8.0f));
			GariusCreatesPortal();
			break;

		case 80:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			GariusCreatesFireWall();
			NightWalkerFlourish();
			break;

		case 90:
			AddAmmonAndZhjaeveToParty();
			GariusGoesHostile();
			NightWalkerGoesHostile();
			break;

		case 100: // For Debug
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			UnhideAllies();
			UnhideAndMoveGariusCrew();
			DeathEnsurance2();
			StartPairsBattle();
			GariusCreatesFireWall();
			break;
	}
}

void PlayCustomAnimationWrapper(object oObject, string sAnimationName, int nLooping, float fSpeed)
{
	PlayCustomAnimation(oObject, sAnimationName, nLooping, fSpeed);
}

void UnhideGarius()
{
	object oGarius = GetTarget("3541_garius");
	AssignCommand(oGarius, ClearAllActions(TRUE));
	PrettyMessage(IntToString(GetIsObjectValid(oGarius)) + " value returned for Garius object validity.");
	SetScriptHidden(oGarius, FALSE);
	SetImmortal(oGarius, TRUE);

	SetPlotFlag(oGarius, TRUE); // kL_fix ->
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_HEARTBEAT, "");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_NOTICE, "");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_SPELLCASTAT, "");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_MELEE_ATTACKED, "");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_DAMAGED, "");
}

void DestroySoldiers()
{
	object o3541 = GetObjectByTag(AREA_TAG);
	object oSoldier;
	object oWP;
	int i;

	SetLocalInt(o3541, "StopRespawningTroops", 1);

	for (i = 1; i <= 6; i++)
	{
		oSoldier = GetTarget("3541_fline_soldier" + IntToString(i));
		SetPlotFlag(oSoldier, FALSE);
		SetImmortal(oSoldier, FALSE);
		DestroyObject(oSoldier);
	}
}

void UnhideAllies()
{
	object oPC = GetFirstPC();
	object oAlly;
	int i;
//	int nCounter = 1;
//	string sAllyTag = "3541_pair_ally";
//	object oAlly = GetNearestObjectByTag( sAllyTag, oPC, nCounter );

	for (i = 1; i <= 8; i++)
	{
		oAlly = GetTarget("3541_pair_ally" + IntToString(i));
		SetScriptHidden(oAlly, FALSE);
		SetImmortal(oAlly, TRUE);
	}

/*	while ( GetIsObjectValid(oAlly) )
	{
		SetScriptHidden(oAlly, FALSE);
		SetImmortal( oAlly, TRUE );

		oAlly = GetNearestObjectByTag( sAllyTag, oPC, ++nCounter );
	}*/
}

void CreateGariusVictims()
{
	int i;
	object oWP;
	location lLocation;
	string sVictimRR = "gfightally_gvictim";
	string sNewTag;

	for (i = 1; i <=6; i++)
	{
		oWP = GetTarget("3541_garius_target" + IntToString(i));
		lLocation = GetLocation(oWP);
		sNewTag = "3541_gar_victim" + IntToString(i);
		CreateObject(OBJECT_TYPE_CREATURE, sVictimRR, lLocation, FALSE, sNewTag);
	}
}

void AnimateSoldiers()
{
	object oSoldier;
	int i;

	for (i = 1; i <= 6; i++)
	{
		oSoldier = GetTarget("3541_gar_victim" + IntToString(i));
		PlayCustomAnimationWrapper(oSoldier, "1hSS_idlefidget01", 1, 1.0f);
	}
}

void MoveGarius()
{
	object oWP = GetTarget("3541_garius_enters");
	object oGarius = GetTarget("3541_garius");
	AssignCommand(oGarius, ClearAllActions(TRUE));
	AssignCommand(oGarius, ActionForceMoveToObject(oWP));
}

void DeathEnsurance()
{
	effect eDeath = EffectDeath(TRUE, TRUE);
	object oTarget;
	int i;

	for (i = 1; i<= 6; i++)
	{
		object oTarget = GetTarget("3541_gar_victim" + IntToString(i));

		if (GetIsDead(oTarget) == FALSE)
		{
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDeath, oTarget);
		}
	}
}

void GariusAttacks()
{
	object oSource = GetTarget("3541_garius");
	object oSound = GetTarget("3541_snd_greys_dying");
	object oShockSound = GetTarget("3541_snd_elec_shock");

	object oTarget1 = GetTarget("3541_gar_victim1");
	object oTarget2 = GetTarget("3541_gar_victim2");
	object oTarget3 = GetTarget("3541_gar_victim3");
	object oTarget4 = GetTarget("3541_gar_victim4");
	object oTarget5 = GetTarget("3541_gar_victim5");
	object oTarget6 = GetTarget("3541_gar_victim6");

	int nSpellID1 = SPELL_CHAIN_LIGHTNING;
	int nSpellID2 = SPELL_SHOCKING_GRASP;

	int nProjectilePathType = PROJECTILE_PATH_TYPE_DEFAULT;

	effect eDeath = EffectDeath();
	effect eShock = EffectNWN2SpecialEffectFile("sp_lightning_hit.sef");

	AssignCommand(oSource, ClearAllActions(TRUE));

	DelayCommand(1.2f, SoundObjectPlay(oSound));
	DelayCommand(0.4f, SoundObjectPlay(oShockSound));

	DelayCommand(0.4f, AssignCommand(oSource, ActionCastSpellAtObject(nSpellID2, oTarget1,
		METAMAGIC_NONE, TRUE, 20, nProjectilePathType, TRUE)));
	DelayCommand(0.5f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShock, oTarget1, 3.0f));
	DelayCommand(0.7f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget1));
	DelayCommand(0.8f, AssignCommand(oSource, ActionCastSpellAtObject(nSpellID2, oTarget2,
		METAMAGIC_NONE, TRUE, 20, nProjectilePathType, TRUE)));
	DelayCommand(0.9f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShock, oTarget2, 3.0f));
	DelayCommand(1.1f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget2));
	DelayCommand(1.2f, AssignCommand(oSource, ActionCastSpellAtObject(nSpellID2, oTarget3,
		METAMAGIC_NONE, TRUE, 20, nProjectilePathType, TRUE)));
	DelayCommand(1.3f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShock, oTarget3, 3.0f));
	DelayCommand(1.5f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget3));
	DelayCommand(1.6f, AssignCommand(oSource, ActionCastSpellAtObject(nSpellID2, oTarget4,
		METAMAGIC_NONE, TRUE, 20, nProjectilePathType, TRUE)));
	DelayCommand(1.7f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShock, oTarget4, 3.0f));
	DelayCommand(1.9f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget4));
	DelayCommand(2.0f, AssignCommand(oSource, ActionCastSpellAtObject(nSpellID2, oTarget5,
		METAMAGIC_NONE, TRUE, 20, nProjectilePathType, TRUE)));
	DelayCommand(2.1f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShock, oTarget5, 3.0f));
	DelayCommand(2.3f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget5));
	DelayCommand(2.4f, AssignCommand(oSource, ActionCastSpellAtObject(nSpellID2, oTarget6,
		METAMAGIC_NONE, TRUE, 20, nProjectilePathType, TRUE)));
	DelayCommand(2.5f, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShock, oTarget6, 3.0f));
	DelayCommand(2.7f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget6));
	DelayCommand(2.8f, DeathEnsurance());
	DelayCommand(5.5f, SoundObjectStop(oSound));
}

void ChangeArcherFaction()
{
	int nCount = 1;
	object oPC = GetFirstPC();
	object oRegulator = GetTarget(TAG_CUTSCENE_REGULATOR);
	object oArcher = GetNearestObjectByTag("3541_sideline_archer", oPC, nCount);
	object oFactionDude1 = GetNearestObjectByTag("3541_pair_ally");
	object oFactionDude2 = GetNearestObjectByTag("3541_pair_enemy8");
	object oGarius = GetTarget("3541_garius");

	while (GetIsObjectValid(oArcher))
	{
		SetPlotFlag(oArcher, FALSE);
		SetImmortal(oArcher, FALSE);

		ChangeFaction(oArcher, oFactionDude1);
		oArcher = GetNearestObjectByTag("3541_sideline_archer", oPC, ++nCount);
	}

	ChangeFaction(oGarius, oFactionDude2);
}

void MoveCameraTracker1()
{
	object oTracker = GetTarget("3541_camera_tracker1");
	object oWP = GetTarget("3541_wp_tracker1");

	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void GariusDestroysArchers()
{
	object oGarius = GetTarget("3541_garius");

	effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);

	object oTarget1 = GetTarget("3541_arch_target1");
	object oTarget2 = GetTarget("3541_arch_target2");
	object oTarget3 = GetTarget("3541_arch_target3");
	object oTarget4 = GetTarget("3541_arch_target4");

	location lTarget1 = GetLocation(oTarget1);
	location lTarget2 = GetLocation(oTarget2);
	location lTarget3 = GetLocation(oTarget3);
	location lTarget4 = GetLocation(oTarget4);

//	vector vTarget1 = GetPosition(oTarget1);
//	vector vTarget2 = GetPosition(oTarget2);
//	vector vTarget3 = GetPosition(oTarget3);
//	vector vTarget4 = GetPosition(oTarget4);

	object oArea = GetArea(OBJECT_SELF);
	vector v1 = GetPosition(oTarget1);
	vector vAdd1 = Vector(0.0f, 0.0f, 1.0f);
	vector vTarget1 = v1 + vAdd1;
	float fOrientation1 = GetFacingFromLocation(lTarget1);
	location lGariusTarget1 = Location(oArea, vTarget1, fOrientation1);

	vector v2 = GetPosition(oTarget2);
	vector vAdd2 = Vector(0.0f, 0.0f, 1.0f);
	vector vTarget2 = v2 + vAdd2;
	float fOrientation2 = GetFacingFromLocation(lTarget2);
	location lGariusTarget2 = Location(oArea, vTarget2, fOrientation2);

	vector v3 = GetPosition(oTarget3);
	vector vAdd3 = Vector(0.0f, 0.0f, 1.0f);
	vector vTarget3 = v3 + vAdd3;
	float fOrientation3 = GetFacingFromLocation(lTarget3);
	location lGariusTarget3 = Location(oArea, vTarget3, fOrientation3);

	vector v4 = GetPosition(oTarget4);
	vector vAdd4 = Vector(0.0f, 0.0f, 1.0f);
	vector vTarget4 = v4 + vAdd4;
	float fOrientation4 = GetFacingFromLocation(lTarget4);
	location lGariusTarget4 = Location(oArea, vTarget4, fOrientation4);

	int nProjectilePathType = PROJECTILE_PATH_TYPE_ACCELERATING;

	int nSpellID1 = SPELL_FIREBALL;

	DelayCommand(0.5f, AssignCommand(oGarius, SetFacingPoint(vTarget1)));
	DelayCommand(0.8f, PlayCustomAnimationWrapper(oGarius, "atk_cast", 0, 1.0f));
	DelayCommand(1.5f, AssignCommand(oGarius, ActionCastSpellAtLocation(nSpellID1, lGariusTarget1, METAMAGIC_NONE,
		TRUE, nProjectilePathType, TRUE)));
//	DelayCommand(2.0f, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eShake, lTarget1, 1.0f));

	DelayCommand(1.5f, AssignCommand(oGarius, SetFacingPoint(vTarget2)));
	DelayCommand(2.0f, PlayCustomAnimationWrapper(oGarius, "atk_cast", 0, 1.0f));
	DelayCommand(2.5f, AssignCommand(oGarius, ActionCastSpellAtLocation(nSpellID1, lGariusTarget2, METAMAGIC_NONE,
		TRUE, nProjectilePathType, TRUE)));
//	DelayCommand(3.0f, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eShake, lTarget2, 1.0f));

	DelayCommand(2.5f, AssignCommand(oGarius, SetFacingPoint(vTarget3)));
	DelayCommand(3.0f, PlayCustomAnimationWrapper(oGarius, "atk_cast", 0, 1.0f));
	DelayCommand(3.5f, AssignCommand(oGarius, ActionCastSpellAtLocation(nSpellID1, lGariusTarget3, METAMAGIC_NONE,
		TRUE, nProjectilePathType, TRUE)));
//	DelayCommand(4.0f, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eShake, lTarget3, 1.0f));

	DelayCommand(3.5f, AssignCommand(oGarius, SetFacingPoint(vTarget4)));
	DelayCommand(4.0f, PlayCustomAnimationWrapper(oGarius, "atk_cast", 0, 1.0f));
	DelayCommand(4.5f, AssignCommand(oGarius, ActionCastSpellAtLocation(nSpellID1, lGariusTarget4, METAMAGIC_NONE,
		TRUE, nProjectilePathType, TRUE)));
//	DelayCommand(5.0f, ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eShake, lTarget4, 1.0f));
}

void DeathEnsurance2()
{
	effect eDeath = EffectDeath(TRUE, TRUE);
	object oTarget;
	int i;

	for (i = 1; i<= 4; i++)
	{
		object oTarget = GetTarget("3541_sideline_archer" + IntToString(i));

		if (GetIsDead(oTarget) == FALSE)
		{
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDeath, oTarget);
		}
	}
}

void UnhideAndMoveGariusCrew()
{
	object oSound = GetTarget("3541_snd_undead_cry");
	object oCrewMember;
	object oWP;
	int i;

	for (i = 1; i <=7; i++)
	{
		object oCrewMember = GetNearestObjectByTag("3541_pair_enemy" + IntToString(i));
		object oWP = GetTarget("3541_wp_enemy_run" + IntToString(i));

		SetScriptHidden(oCrewMember, FALSE);
		AssignCommand(oCrewMember, ClearAllActions(TRUE));
		AssignCommand(oCrewMember, ActionForceMoveToObject(oWP, TRUE));
	}

	SoundObjectPlay(oSound);
}

void StartPairsBattle()
{
	object oCrewMember;
	object oWP;
	object oFactionDude = GetNearestObjectByTag("3541_pair_enemy8");
	int i;

	for (i = 1; i <=7; i++)
	{
		object oCrewMember = GetNearestObjectByTag("3541_pair_enemy" + IntToString(i));
		object oWP = GetTarget("3541_fighting_pair_sp" + IntToString(i));

		AssignCommand(oCrewMember, ClearAllActions(TRUE));
		AssignCommand(oCrewMember, JumpToObject(oWP));
		ChangeFaction(oCrewMember, oFactionDude);
	}

	for (i = 8; i <=8; i++)
	{
		object oCrewMember = GetNearestObjectByTag("3541_pair_enemy" + IntToString(i));

		SetScriptHidden(oCrewMember, FALSE);
	}
}

void SpawnAmmonAndZhjaeve()
{
	object oAJWP = GetNearestObjectByTag("wp_3541_aj_sp");
	object oZhjaeveWP = GetNearestObjectByTag("wp_3541_zhjaeve_sp");
	object oAJ = SpawnRosterMember(TAG_AMMON, GetLocation(oAJWP));
	object oZhjaeve = SpawnRosterMember(TAG_ZHJAEVE, GetLocation(oZhjaeveWP));
	ForceRest(oAJ);
	ForceRest(oZhjaeve);
}

void MoveAmmonAndZhjaeve()
{
	object oAJWP = GetNearestObjectByTag("wp_3541_aj_pc");
	object oZhjaeveWP = GetNearestObjectByTag("wp_3541_zhjaeve_pc");
	object oAJ = GetTarget("ammon_jerro");
	object oZhjaeve = GetTarget("zhjaeve");
	AssignCommand(oAJ, ClearAllActions(TRUE));
	AssignCommand(oAJ, ActionForceMoveToObject(oAJWP, TRUE));
	AssignCommand(oZhjaeveWP, ClearAllActions(TRUE));
	AssignCommand(oZhjaeveWP, ActionForceMoveToObject(oZhjaeveWP, TRUE));
}

void MoveGariusAgain()
{
	object oGarius = GetTarget("3541_garius");
	object oWP = GetTarget("3541_wp_garius2");

	AssignCommand(oGarius, ClearAllActions(TRUE));
	AssignCommand(oGarius, ActionForceMoveToObject(oWP, FALSE));
}

void GariusCreatesPortal()
{
	object oGarius = GetNearestObjectByTag("3541_garius");
	object oPortalSound = GetTarget("3541_snd_portal");
	object oPortalCloseSound = GetTarget("3541_snd_portal_close");
	object oNightwalker = GetNearestObjectByTag("3541_nightwalker");
	string sPortal = "fx_altargen_red.sef";
	string sGate = "sp_gate.sef";
	string sGen = "fx_portal_gen1.sef";
	string sExplosion = "fx_magical_explosion.sef";
	location lLocation = GetLocation(oNightwalker);

	AssignCommand(oGarius, ClearAllActions(TRUE));
	AssignCommand(oGarius, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2, 1.0f, 6.0f));
//	AssignCommand(oGarius, ActionWait(2.0f));
	DelayCommand(1.0f, AssignCommand(oGarius, ApplySEFToLocation(sPortal, lLocation, 5.0f)));
	DelayCommand(1.5f, SoundObjectPlay(oPortalSound));
	DelayCommand(2.0f, AssignCommand(oGarius, ApplySEFToLocation(sGate, lLocation, 4.0f)));
	DelayCommand(3.0f, AssignCommand(oGarius, ApplySEFToLocation(sGen, lLocation, 3.0f)));
	DelayCommand(5.0f, AssignCommand(oGarius, ActionDoCommand(SetPlotFlag(oNightwalker, FALSE))));
	DelayCommand(5.0f, AssignCommand(oGarius, ActionDoCommand(SetScriptHidden(oNightwalker, FALSE))));
	DelayCommand(6.0f, SoundObjectPlay(oPortalCloseSound));
	DelayCommand(6.0f, SoundObjectStop(oPortalSound));
//	AssignCommand(oGarius, ActionWait(4.5f));
	DelayCommand(6.0f, AssignCommand(oGarius, ApplySEFToLocation(sExplosion, lLocation, 1.0f)));
}

void GariusCreatesFireWall()
{
	object oGarius = GetTarget("3541_garius");
	object oSound1 = GetTarget("3541_garius_firewall");
	object oSound2 = GetTarget("3541_garius_cut_firewall");
	object oWP;
	location lLocation;
	int i;
	string sNewTag;

	AssignCommand(oGarius, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2, 1.0f, 3.0f));

	for (i = 1; i <=7; i++)
	{
		oWP = GetTarget("3541_wp_firewall" + IntToString(i));
		lLocation = GetLocation(oWP);
		sNewTag = "3541_firewall" + IntToString(i);
		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "n2_fx_walloffire", lLocation, FALSE, sNewTag);
	}

	lLocation = GetLocation(GetTarget("3541_wp_flamewall_long1"));
	CreateObject(OBJECT_TYPE_PLACEABLE, "3541_flamewall_long", lLocation, FALSE, "3541_flamewall_long1");
	lLocation = GetLocation(GetTarget("3541_wp_flamewall_long2"));
	CreateObject(OBJECT_TYPE_PLACEABLE, "3541_flamewall_long", lLocation, FALSE, "3541_flamewall_long2");
	lLocation = GetLocation(GetTarget("3541_wp_flamewall_short"));
	CreateObject(OBJECT_TYPE_PLACEABLE, "3541_flamewall_short", lLocation);

	SoundObjectPlay(oSound1);
	SoundObjectPlay(oSound2);
}

void GariusTeleportsOnWall()
{
	object oRegulator = GetTarget(TAG_CUTSCENE_REGULATOR);
	object oGarius = GetTarget("3541_garius");
	object oWP = GetTarget("3541_wp_garius_wall");
	location lGariusWall = GetLocation(oWP);
	location lGariusGround = GetLocation(oGarius);
	string sEffectFile = "fx_altargen.sef";

	AssignCommand(oGarius, ActionPlayAnimation(ANIMATION_LOOPING_CONJURE2, 1.0f, 2.0f));
	AssignCommand(oGarius, ActionWait(2.0f));
	AssignCommand(oGarius, ApplySEFToLocation(sEffectFile, lGariusGround, 1.0f));
	AssignCommand(oGarius, ActionJumpToObject(oWP));
	AssignCommand(oGarius, ApplySEFToLocation(sEffectFile, lGariusWall, 2.0f));
}

void NightWalkerFlourish()
{
	object oNightwalker = GetNearestObjectByTag("3541_nightwalker");
	object oArea = GetObjectByTag("3541_kicourtyard");
	object oSound = GetTarget("3541_snd_nwalker_roar");

	AssignCommand(oNightwalker, ClearAllActions(TRUE));
	AssignCommand(oNightwalker, ActionPlayAnimation(ANIMATION_FIREFORGET_TAUNT, 4.0f));
	SoundObjectPlay(oSound);

	MusicBattleChange(oArea, 43);
}

void GariusGoesHostile()
{
	object oGarius = GetTarget("3541_garius");
	ChangeToStandardFaction(oGarius, STANDARD_FACTION_HOSTILE);

	SetPlotFlag(oGarius, FALSE); // kL_fix ->
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_HEARTBEAT, "nw_c2_default1");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_NOTICE, "nw_c2_default2");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_SPELLCASTAT, "nw_c2_defaultb");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_MELEE_ATTACKED, "nw_c2_default5");
	SetEventHandler(oGarius, CREATURE_SCRIPT_ON_DAMAGED, "nw_c2_default6");
}

void AddAmmonAndZhjaeveToParty()
{
	object oPC = GetFirstPC();

	AddRosterMemberToParty(TAG_AMMON, oPC);
	AddRosterMemberToParty(TAG_ZHJAEVE, oPC);
}

void NightWalkerGoesHostile()
{
	object oNightwalker = GetNearestObjectByTag("3541_nightwalker");

	ChangeToStandardFaction(oNightwalker, STANDARD_FACTION_HOSTILE);
	AssignCommand(oNightwalker, DetermineCombatRound());
}
