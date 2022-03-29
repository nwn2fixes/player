//::///////////////////////////////////////////////////////////////////////////
//::
//::	3052a_cut_scar.nss
//::
//::	This file contains the cutscene actions for conversation 3052_cut_scar.
//::
//::///////////////////////////////////////////////////////////////////////////
//::
//::	Created by: Brian Fox & Constant Gaw
//::	Created on: 11/9/05
//::
//::///////////////////////////////////////////////////////////////////////////
// kL 2022 mar 29 - UnequipPC() unequip lefthand before righthand and get rid of
//                  the bogus drop routine.
// kL 2022 mar 29 - call DestroySilverShards() before UnequipPC() instead of at
//                  the end of the dialog to lessen chance of PC's hand-items
//                  dropping to ground if his/her inventory is full.
// kL 2022 mar 29 - CreateAndEquipSilverSwordOnPC() ensure there's room in the
//                  PC's inventory for the Silver blade.
// kL 2022 mar 29 - general maintenance.
// kL 2022 mar 29 - fix DestroySilverShards() was using an assignment operator
//                  instead of an equivalency check.

//::///////////////////////////////////////////////////////////////////////////
#include "30_constants"
//#include "30_true_name_inc"
#include "ginc_companions"
#include "ginc_group"
#include "ginc_object"
#include "x0_i0_partywide"
#include "ginc_cutscene"
//::///////////////////////////////////////////////////////////////////////////

const string RR_SILVER_SWORD = "silver_sword";
const string TAG_SILVER_SWORD = "silver_sword";

const string REAVER_PARTY_NAME = "Reaver2Party";
const string REAVER_MINIONS = "Reaver2Minions";

//::///////////////////////////////////////////////////////////////////////////
void UnequipPC();
void DestroyDanan();
void MoveCameraTracker3();
void HideCameraTracker1();
void HideCameraTracker2();
void HideCameraTracker3();
void HideCameraTracker4();
void HideCameraTracker5();
void ZhjaeveMovesToScar();
//void PCMovesToScar();
void ZhjaeveSits();
void PCSits();
void SpawnSwordFragments();
void PCGlowsSoftly();
void PCGlowsBrightly();
void ShardsGlowSoftly();
void ShardsGlowBrightly();
void MoveCameraTracker5();
void DestroyShardPlaceable();
void PlayReforgingEffect();
void MoveCameraTracker2();
void FadeToWhite();
void CreateAndEquipSilverSwordOnPC();
void PCRaiseSilverSword();
void ZhjaeveStandsUp();
void MoveCameraTracker1();
void RevealReaver();
void ReaverEntersScene();
void MoveCameraTracker4();
void RevealShadows1();
void RevealShadows2();
void FlamesErupt();
void TurnReaverPartyHostile();
void DestroySilverShards();
//void UseTrueName(string sTag);
void DestroyCameraMen();
//::///////////////////////////////////////////////////////////////////////////


void main(int iCase)
{
	object oRegulator = GetTarget("3052_ip_controller");
	object oZhjaeve;

	switch (iCase)
	{
		case 3: // not used in 3052_cut_scar
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
			break;

		case 4:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			DestroyDanan();
			break;

		case 6:
			// kL move DestroySilverShards() here from 110 to lower the
			// chance that the PC's hand-items fall to the ground when
			// unequipped
			DestroySilverShards();
			UnequipPC();
			break;

		case 5:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			MoveCameraTracker3();
			break;

		case 8:
			HideCameraTracker3();
			break;

		case 10:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			ZhjaeveMovesToScar();
			break;

		case 12:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
//			PCMovesToScar();
			ZhjaeveSits();
			break;

		case 1:
			ActionPauseCutscene(1000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(1.0f));
			break;

		case 17:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			PCSits();
			break;

		case 19:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
			DelayCommand(0.5f, SpawnSwordFragments());
			break;

		case 2:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			break;

		case 15: // not used in 3052_cut_scar
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			ZhjaeveSits();
			break;

		case 20:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			ShardsGlowSoftly();
			MoveCameraTracker5();
			break;

		case 25:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			PCGlowsSoftly();
			HideCameraTracker5();
			break;

		case 30:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			ShardsGlowBrightly();
			PCGlowsBrightly();
			break;

		case 31:
			DestroyShardPlaceable();
			break;

		case 32:
			ActionPauseCutscene(5000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(5.0f));
			PlayReforgingEffect();
			break;

		case 33:
			MoveCameraTracker2();
			break;

		case 34:
			DelayCommand(4.5f, AssignCommand(oRegulator, FadeToWhite()));
			DelayCommand(5.0f, PCRaiseSilverSword());
			break;

		case 110:
//			DestroySilverShards(); // kL Moved to case 6 before unequip hands.
			break;

		case 35:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
			DelayCommand(2.0f, CreateAndEquipSilverSwordOnPC());
			HideCameraTracker2();
			break;

		case 40:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
//			PCRaiseSilverSword();
			break;

		case 45:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			ZhjaeveStandsUp();
			break;

		case 48:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			MoveCameraTracker1();
			break;

		case 50:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
			HideCameraTracker1();
			RevealReaver();
			break;

		case 60: // not used in 3052_cut_scar
			ActionPauseCutscene(PAUSE_TIME, FALSE);
			AssignCutsceneActionToObject(oRegulator, ReaverEntersScene());
			break;

		case 75:
			FlamesErupt();
			break;

		case 70:
			ActionPauseCutscene(6000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(6.0f));
			MoveCameraTracker4();
			DelayCommand(1.0f, RevealShadows1());
			DelayCommand(4.0f, RevealShadows2());
			break;

		case 72:
			HideCameraTracker4();
			break;

		case 80:
			TurnReaverPartyHostile();
			break;

		case 85:
			DestroyCameraMen();
			break;

		default:
			PrettyError("Unhandled case (" + IntToString(iCase) + ") in 3052a_cut_scar.");
			break;
	}
}

//::///////////////////////////////////////////////////////////////////////////

void PlayCustomAnimationWrapper(object oObject, string sAni, int bLoop = TRUE, float fSpeed = 1.0f)
{
	PlayCustomAnimation(oObject, sAni, bLoop, fSpeed);
}

// kL Modified: got rid of the bogus drop routine.
void UnequipPC()
{
	object oPC = GetFactionLeader(GetFirstPC());

	object oWeaponLh = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
	object oWeaponRh = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);

	AssignCommand(oPC, ClearAllActions());

	AssignCommand(oPC, ActionUnequipItem(oWeaponLh));
	AssignCommand(oPC, ActionUnequipItem(oWeaponRh));
}

void DestroyDanan()
{
	object oDanan = GetNearestObjectByTag("3052_starling");
	object oRetta = GetNearestObjectByTag("3052_retta");
	object oShadowDanan = GetNearestObjectByTag("3052_shadow_danan");
	object oShadowRetta = GetNearestObjectByTag("3052_greater_shadow_retta");

	DestroyObject(oDanan);
	DestroyObject(oRetta);
	DestroyObject(oShadowDanan);
	DestroyObject(oShadowRetta);
}

void MoveCameraTracker3()
{
	object oTracker = GetTarget("3052_camera_tracker3");
	object oWP = GetTarget("3052_wp_tracker3");

	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void HideCameraTracker1()
{
	object oTracker = GetTarget("3052_camera_tracker1");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker2()
{
	object oTracker = GetTarget("3052_camera_tracker2");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker3()
{
	object oTracker = GetTarget("3052_camera_tracker3");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker4()
{
	object oTracker = GetTarget("3052_camera_tracker4");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker5()
{
	object oTracker = GetTarget("3052_camera_tracker5");
	SetScriptHidden(oTracker, TRUE);
}

void ZhjaeveMovesToScar()
{
	object oZhjaeve = GetTarget(TAG_ZHJAEVE);
	object oWP = GetTarget("3052_wp_zhjaeve_sit");

	AssignCommand(oZhjaeve, ActionForceMoveToObject(oWP, FALSE));
}

/* void PCMovesToScar()
{
	object oPC = GetFactionLeader(GetFirstPC());
	object oWP = GetTarget("3052_wp_pc_sit");

	AssignCommand(oPC, ClearAllActions(TRUE));
	AssignCommand(oPC, ActionForceMoveToObject(oWP, FALSE));
}*/

void ZhjaeveSits()
{
	object oZhjaeve = GetTarget(TAG_ZHJAEVE);
	object oPC = GetFactionLeader(GetFirstPC());
	object oWP = GetTarget("3052_wp_pc_sit");

	DelayCommand(1.0f, AssignCommand(oZhjaeve, PlayCustomAnimationWrapper(oZhjaeve, "sitgroundidle")));
	AssignCommand(oPC, ActionForceMoveToObject(oWP, FALSE, 0.0f));
}

void PCSits()
{
	object oPC = GetFactionLeader(GetFirstPC());
	DelayCommand(1.0f, AssignCommand(oPC, PlayCustomAnimationWrapper(oPC, "sitgroundidle")));
}

void SpawnSwordFragments()
{
	object oWP = GetTarget("3052_wp_ssplaceable");
	location lLocation = GetLocation(oWP);

	CreateObject(OBJECT_TYPE_PLACEABLE, "3052_plc_brokenswd", lLocation, FALSE, "3052_ss_fragments");
}

void PCGlowsSoftly()
{
	object oPC = GetFactionLeader(GetFirstPC());
	effect eGlow = EffectNWN2SpecialEffectFile("fx_shard_rip");

	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oPC, 15.0f);
}

void PCGlowsBrightly()
{
	object oPC = GetFactionLeader(GetFirstPC());
	location lPC = GetLocation(oPC);
	effect eGlow = EffectNWN2SpecialEffectFile("fx_glowstone_blue_p");

//	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oPC, 5.0f);
	ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eGlow, lPC, 5.0f);
}

void ShardsGlowSoftly()
{
	object oShards = GetTarget("3052_ss_fragments");
	effect eGlow = EffectNWN2SpecialEffectFile("fx_shard_rip");

	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oShards, 5.0f);
}

void ShardsGlowBrightly()
{
	object oShards = GetTarget("3052_ss_fragments");
	effect eGlow = EffectNWN2SpecialEffectFile("3052_fx_shard_glow");

	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oShards, 10.0f);
}

void MoveCameraTracker5()
{
	object oTracker = GetTarget("3052_camera_tracker5");
	object oWP = GetTarget("3052_wp_tracker5");

	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void DestroyShardPlaceable()
{
	object oShards = GetTarget("3052_ss_fragments");
	DestroyObject(oShards);
}

void PlayReforgingEffect()
{
	object oSound = GetTarget("3052_snd_sword_forge");
	DelayCommand(0.5f, SoundObjectPlay(oSound));

//	object oPC = GetFactionLeader(GetFirstPC());
//	effect ePC = EffectNWN2SpecialEffectFile("fx_silversword_fx");
//	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePC, oPC, 6.0f);
//	effect eShards = EffectNWN2SpecialEffectFile("3052_fx_silversword_reform");
//	ApplyEffectToObject(DURATION_TYPE_INSTANT, eShards, oPC);

	location lReforge = GetLocation(GetTarget("3052_wp_scar"));
	object oSword = CreateObject(OBJECT_TYPE_PLACED_EFFECT, "fx_silversword_reform", lReforge);

	DelayCommand(6.0f, DestroyObject(oSword));
}

void MoveCameraTracker2()
{
	object oTracker = GetTarget("3052_camera_tracker2");
	object oWP = GetTarget("3052_wp_tracker2");

	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void FadeToWhite()
{
	object oPC = GetFirstPC();
	object oParty = GetFirstFactionMember(oPC);
	while (GetIsObjectValid(oParty))
	{
		FadeToBlack(oParty, 1.0f, 10.0f, 16777215);
		oParty = GetNextFactionMember(oPC);
	}
}

// kL
void copy_dropped(object oDropped, object oPC)
{
	CopyObject(oDropped, GetLocation(oPC), oPC);
	DestroyObject(oDropped);
}
// kL
void create_and_equip(object oPC, object oDropped)
{
	object o = CreateItemOnObject(RR_SILVER_SWORD, oPC);
	AssignCommand(oPC, ActionEquipItem(o, INVENTORY_SLOT_RIGHTHAND));

	if (GetIsObjectValid(oDropped)) // safety. 'oDropped' shall be valid (unless PC has 128 bags ...)
		AssignCommand(oPC, ActionDoCommand(copy_dropped(oDropped, oPC)));
}
// kL Modified: Ensure there's room in the PC's inventory for the Silver blade.
void CreateAndEquipSilverSwordOnPC()
{
	object oPC = GetFactionLeader(GetFirstPC());
	object oSilverSword = CreateItemOnObject(RR_SILVER_SWORD, oPC);

	if (!GetIsObjectValid(GetItemPossessedBy(oPC, RR_SILVER_SWORD))) // blade dropped; inventory full; handle it ->
	{
		DestroyObject(oSilverSword);

		object oDropped = OBJECT_INVALID;

		object oDropit = GetFirstItemInInventory(oPC); // don't drop a bag ... find an item outside a bag to drop ->
		while (GetIsObjectValid(oDropit))
		{
			if (GetHasInventory(oDropit))
			{
				object oContainer = oDropit;

				object oSubit = GetFirstItemInInventory(oContainer);
				while (GetIsObjectValid(oSubit))
				{
					oSubit = GetNextItemInInventory(oContainer);
					oDropit = GetNextItemInInventory(oPC);
				}
			}
			else
				break;

			oDropit = GetNextItemInInventory(oPC);
		}
		oDropped = CopyObject(oDropit, GetLocation(oPC)); // 'oDropped' shall be valid (unless PC has 128 bags ...)
		DestroyObject(oDropit);

		DelayCommand(0.0f, create_and_equip(oPC, oDropped)); // delayed to ensure 'oDropit' is destroyed first
	}
	else
		AssignCommand(oPC, ActionEquipItem(oSilverSword, INVENTORY_SLOT_RIGHTHAND));
}

void PCRaiseSilverSword()
{
	object oPC = GetFactionLeader(GetFirstPC());
	PlayCustomAnimationWrapper(oPC, "%");
	PlayCustomAnimationWrapper(oPC, "liftswordloop", TRUE, 0.5f);

//	AssignCutsceneActionToObject(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY1));
	// TODO: replace animation constant with final animation when available
	// kL_note: yeh better not forget that ...
}

void ZhjaeveStandsUp()
{
	object oZhjaeve = GetTarget(TAG_ZHJAEVE);
	AssignCommand(oZhjaeve, ClearAllActions(TRUE));
//	AssignCommand(oZhjaeve, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE));
	AssignCommand(oZhjaeve, PlayCustomAnimationWrapper(oZhjaeve, "%"));

	object oPC = GetFactionLeader(GetFirstPC());
	PlayCustomAnimationWrapper(oPC, "%");
}

void MoveCameraTracker1()
{
	object oTracker = GetTarget("3052_camera_tracker1");
	object oWP = GetTarget("3052_wp_tracker1");

	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void RevealReaver()
{
	object oReaver = GetTarget(TAG_REAVER_3052);
	SetScriptHidden(oReaver, FALSE);

	effect eFlash = EffectNWN2SpecialEffectFile("fx_garius_ritual");
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eFlash, oReaver);

	ResetGroup(REAVER_PARTY_NAME);
	GroupAddMember(REAVER_PARTY_NAME, oReaver);

	object o;

	int i;
	for (i = 1; i <= 3; i++)
	{
		o = GetTarget("3052_felemen" + IntToString(i));
		SetScriptHidden(o, FALSE);
		GroupAddMember(REAVER_PARTY_NAME, o, FALSE);
	}

	for (i = 1; i <= 2; i++)
	{
		o = GetTarget("3052_bgolem" + IntToString(i));
		SetScriptHidden(o, FALSE);
		GroupAddMember(REAVER_PARTY_NAME, o, FALSE);
	}
}

void ReaverEntersScene()
{
	object oReaver = GetTarget(TAG_REAVER_3052);

	AssignCutsceneActionToObject(oReaver, ActionForceMoveToObject(GetPCSpeaker()));
}

void MoveCameraTracker4()
{
	object oTracker = GetTarget("3052_camera_tracker4");
	object oWP = GetTarget("3052_wp_tracker4");

	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void RevealShadows1()
{
	effect ePoof = EffectNWN2SpecialEffectFile("sp_bless");

	int i;
	object oPC = GetFactionLeader(GetFirstPC());
	object oShadow = GetNearestObjectByTag("3052_reaver_shadow", oPC, i);
//	object oShadow = GetNearestObjectByTag(TAG_SHADOW_3052, oPC, i);
	for (i = 1; i <= 2; i++)
	{
		oShadow = GetTarget("3052_reaver_shadow" + IntToString(i));

		SetScriptHidden(oShadow, FALSE);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoof, oShadow, 1.0f);

		GroupAddMember(REAVER_MINIONS, oShadow);
	}
}

void RevealShadows2()
{
	effect ePoof = EffectNWN2SpecialEffectFile("sp_bless");

	int i;
	object oPC = GetFactionLeader(GetFirstPC());
	object oShadow = GetNearestObjectByTag("3052_reaver_shadow", oPC, i);
//	object oShadow = GetNearestObjectByTag(TAG_SHADOW_3052, oPC, i);
	for (i = 3; i <= 4; i++)
	{
		oShadow = GetTarget("3052_reaver_shadow" + IntToString(i));

		SetScriptHidden(oShadow, FALSE);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoof, oShadow, 1.0f);

		GroupAddMember(REAVER_MINIONS, oShadow);
	}
}

void FlamesErupt()
{
	object oWP;
	location lFire;
	string sTag;

	int i;
	for (i = 1; i <= 13; i++)
	{
		oWP = GetNearestObjectByTag("3052_wp_reaverfire" + IntToString(i));
		lFire = GetLocation(oWP);
		sTag = "3052_reaverfire" + IntToString(i);
		CreateObject(OBJECT_TYPE_PLACED_EFFECT, "n2_fx_fire_lg", lFire, FALSE, sTag);
	}

	object o3052 = GetObjectByTag("3052_wharbor");

	SetLocalInt(o3052, "ReaverFlamesOn", 1);

	object oEntranceSound = GetTarget("3052_snd_reaver_entrance");
	SoundObjectPlay(oEntranceSound);
	object oFire1 = GetTarget("3052_snd_fire_smolder_scar");
	SoundObjectPlay(oFire1);
	object oFire2 = GetTarget("3052_snd_fire_large_scar");
	SoundObjectPlay(oFire2);

	MusicBackgroundStop(o3052);
}

void TurnReaverPartyHostile()
{
	GroupChangeToStandardFaction(REAVER_PARTY_NAME, STANDARD_FACTION_HOSTILE);
	GroupChangeToStandardFaction(REAVER_MINIONS, STANDARD_FACTION_HOSTILE);
	GroupDetermineCombatRound(REAVER_PARTY_NAME);
	GroupDetermineCombatRound(REAVER_MINIONS);
}

void DestroySilverShards()
{
	int bShardFound;

	string sShardTag, sShardTagPrefix = "nwn2_it_shard";
	object oShard;

	int iCount = 0;
	while (iCount < 9)
	{
		bShardFound = FALSE;

		sShardTag = sShardTagPrefix + IntToString(iCount);
		oShard = GetTarget(sShardTag);				// check the module first

		if (GetIsObjectValid(oShard))				// found it in the module (outside of inventory)
		{
			bShardFound = TRUE;
			DelayCommand(0.1f, DestroyObject(oShard));
		}
		else										// iterate through the roster members and check their inventory
		{
			object oCompanion;

			string sRoster = GetFirstRosterMember();
			while (sRoster != "")
			{
				oCompanion = GetTarget(sRoster);
				oShard = GetItemPossessedBy(oCompanion, sShardTag);

				if (GetIsObjectValid(oShard))		// found it in the roster member's inventory
				{
					bShardFound = TRUE;
					DelayCommand(0.1f, DestroyObject(oShard));
				}

				sRoster = GetNextRosterMember();
			}
		}

		if (!bShardFound)							// if it STILL hasn't been found just, remove it from the party PCs
		{
			object oPC = GetFirstPC();
			RemoveItemFromParty(oPC, sShardTag);	// this will cover the PCs in the party; last resort but most likely outcome
		}

		++iCount;
	}
}

/* Helper function for UseTrueName()
void CastTrueName(object oTarget)
{
	ClearAllActions(TRUE);
	ActionCastSpellAtObject(SPELL_TRUE_NAME, oTarget, METAMAGIC_NONE, TRUE);
}
void UseTrueName(string sTag)
{
	object oReciter = GetTarget(sTag);
	object oReaver = GetTarget(TAG_REAVER_3050);
	AssignCommand(oReciter, CastTrueName(oReaver));

//	location lReaver = GetLocation(oReaver);
//	object oTrueNameScroll = GetItemPossessedBy(oReciter, TAG_TRUE_NAME_SCROLL);
//	event eActivateTrueNameScroll = EventActivateItem(oTrueNameScroll, lReaver, oReaver);
//	SignalEvent(oReciter, eActivateTrueNameScroll);
} */

void DestroyCameraMen()
{
	object oCameraMan;

	int i;
	for (i = 1; i <= 5; i++)
	{
		oCameraMan = GetTarget("3052_camera_tracker" + IntToString(i));
		DestroyObject(oCameraMan);
	}
}
