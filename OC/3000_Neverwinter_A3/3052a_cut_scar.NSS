//::///////////////////////////////////////////////////////////////////////////
//::
//::	'3052a_cut_scar'
//::
//::	This file contains the cutscene actions for conversation
//::	'3052_cut_scar'.
//::
//::///////////////////////////////////////////////////////////////////////////
//::
//::	Created by: Brian Fox & Constant Gaw
//::	Created on: 11/9/05
//::
//::///////////////////////////////////////////////////////////////////////////
// kL 2022 mar 29 - UnequipPc() unequip lefthand before righthand and get rid of
//                  the bogus drop routine.
//                - call DestroyShards() before UnequipPc() instead of at the
//                  end of the dialog to lessen chance of PC's hand-items
//                  dropping to ground if his/her inventory is full.
//                - CreateAndEquipSilverSword() ensure there's room in the PC's
//                  inventory for the Silver blade.
//                - general maintenance.
//                - fix DestroyShards() was using an assignment operator instead
//                  of an equivalency check.
// kL 2022 apr 2  - fix: call DestroyShards() on a node before UnequipPc().
//                - turn Zhjaeve to face the party after she walks to the scar.
//                - more maintenance.
//                - efforts to ensure that the PC and Zhjaeve face each other.
//                - CreateAndEquipSilverSword() don't drop plot or cursed items
//                  or items that can stack or any bag.
// kL 2022 apr 3  - SetOrientOnDialog(FALSE) for all party. Woohoo - character
//                  facing shall be either scripted here or done on the dialog-
//                  nodes.
// kL 2022 apr 16 - fed up. refactor and try to make character movements
//                  transparent and more believable.
// kL 2022 apr 20 - fixed DestroyShards() to check roster. Plus optimizations.

/**
 * Includes
 */

#include "30_constants"
#include "ginc_group"

/**
 * Constants
 */

const string TAG_REGULATOR     = "3052_ip_controller";

const string RR_SILVER_SWORD   = "silver_sword";
const string TAG_SILVER_SWORD  = "silver_sword";

const string REAVER_PARTY_NAME = "Reaver2Party";
const string REAVER_MINIONS    = "Reaver2Minions";

const string SHARD_TAG_PRE     = "nwn2_it_shard";
const int    SHARDS_TOTAL      = 8;

/**
 * Declarations
 */

void DestroyDanan();
void DestroyShards();
void unhide_trackers(); // kL

void ZhjaeveMovesToScar();
void PcMovesToScarAndZhjaeveSits();
void PcSits();
void SpawnSwordFragments();
void ShardsGlowSoftly();
void PcGlowsSoftly();
void ShardsGlowBrightly();
void PcGlowsBrightly();
void CreateSwordPlacedEffect();
void DestroyShardPlaceable();
void FadeToWhite();
void PCRaiseSilverSword();
void CreateAndEquipSilverSword();
void ZhjaeveAndPcStandUp();

void RevealReaver();
void FlamesErupt();
void RevealShadows1();
void RevealShadows2();
void TurnReaverPartyHostile();

void MoveCameraTracker(string id);
void HideCameraTracker(string id);
void DestroyCameraTrackers();

void party_face(object oTarget); // kL
float GetDirectionTo(object oTarget, object oSource = OBJECT_SELF); // kL

/**
 * Forward definitions
 */

//
void play(object oCreature, string sAni, int bLoop = TRUE, float fSpeed = 1.f)
{
	PlayCustomAnimation(oCreature, sAni, bLoop, fSpeed);
}

/**
 * Main void
 */

// kL_note: I have changed the dialog-owner (OBJECT_SELF) to Zhjaeve in
// '3052_cliententer'
// obsolete: OBJECT_SELF was the PC or the controlled Co that entered the
// speak-trigger. But that's asking for trouble wrt the automatic facing
// routines; fixed.
void main(int iCase)
{
	switch (iCase)
	{
		case 4:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(2.f));

			DestroyDanan();

			unhide_trackers();

			// kL moved DestroyShards() here from the end of the dialog to lower
			// the chance that the PC's hand-items fall to the ground when
			// unequipped in case 17
			DelayCommand(0.25f, DestroyShards()); // delayed for fade-to-black (instant)
			break;

		case 5:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(4.f));

			MoveCameraTracker("3");
			break;

		case 8:
			HideCameraTracker("3");
			break;

		case 10:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(4.f));

			ZhjaeveMovesToScar();
			break;

		case 12:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(3.f));

			PcMovesToScarAndZhjaeveSits();
			break;

		case 1:
			ActionPauseCutscene(1000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(1.f));
			break;

		case 17:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(2.f));

			PcSits();
			break;

		case 19:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(3.f));

			DelayCommand(0.5f, SpawnSwordFragments());
			break;

		case 2:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(2.f));
			break;

		case 20:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(2.f));

			ShardsGlowSoftly();

			MoveCameraTracker("5");
			break;

		case 25:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(2.f));

			PcGlowsSoftly();

			HideCameraTracker("5");
			break;

		case 30:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(2.f));

			ShardsGlowBrightly();
			PcGlowsBrightly();
			break;

		case 32:
			ActionPauseCutscene(5000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(5.f));

			MoveCameraTracker("2");

			CreateSwordPlacedEffect();
			DestroyShardPlaceable();

			DelayCommand(4.5f, FadeToWhite());
			DelayCommand(5.0f, PCRaiseSilverSword());
			break;

		case 35:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(3.f));

			DelayCommand(2.f, CreateAndEquipSilverSword());

			HideCameraTracker("2");
			break;

		case 40:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(3.f));
			break;

		case 45:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(2.f));

			ZhjaeveAndPcStandUp();
			break;

		case 48:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(4.f));

			MoveCameraTracker("1");
			break;

		case 50:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(3.f));

			HideCameraTracker("1");

			RevealReaver();
			FlamesErupt();
			break;

		case 70:
			ActionPauseCutscene(6000, FALSE);
			AssignCutsceneActionToObject(GetNearestObjectByTag(TAG_REGULATOR), ActionWait(6.f));

			MoveCameraTracker("4");

			DelayCommand(1.f, RevealShadows1());
			DelayCommand(4.f, RevealShadows2());
			break;

		case 72:
			HideCameraTracker("4");
			break;

		case 80:
			TurnReaverPartyHostile();
			break;

		case 85:
			DestroyCameraTrackers();
			break;
	}
}

/**
 * Definitions
 */

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


// kL helper for DestroyShardsRoster()
int DestroyShardsInventory(object oTarget)
{
	int tally = 0;

	object oShard; string sShard;

	int i = 0;
	while (++i <= SHARDS_TOTAL)
	{
		sShard = SHARD_TAG_PRE + IntToString(i);
		if (GetIsObjectValid(oShard = GetItemPossessedBy(oTarget, sShard)))
		{
			++tally;
			DestroyObject(oShard);
		}
	}
	return tally;
}

// kL helper for DestroyShardsRoster()
void despawn(object oRoster, string sRoster)
{
	SetScriptHidden(oRoster, FALSE);
	DespawnRosterMember(sRoster);
}

// kL helper for DestroyShards()
// Those geniuses forgot that a despawned roster character could have shard(s)
// (and that shards can be stashed in containers in other Modules).
void DestroyShardsRoster(int tally)
{
	object oRoster;

	location loc = GetLocation(GetPCSpeaker());

	string sRoster = GetFirstRosterMember();
	while (sRoster != "")
	{
		if (!GetIsObjectValid(GetObjectFromRosterName(sRoster)))
		{
			oRoster = SpawnRosterMember(sRoster, loc);
			SetScriptHidden(oRoster, TRUE);

			tally += DestroyShardsInventory(oRoster);

			DelayCommand(5.f, despawn(oRoster, sRoster));

			if (tally >= SHARDS_TOTAL)
				break;
		}
		sRoster = GetNextRosterMember();
	}
}

// kL rewrite
// note: silver shards cannot be dropped on the ground. See 'k_mod_unacquire' in
// the OC Campaign folder.
void DestroyShards()
{
	int tally = 0;

	object oShard; string sShard;

	int i = 0;
	while (++i <= SHARDS_TOTAL)
	{
		sShard = SHARD_TAG_PRE + IntToString(i);

		int j = -1;
		while (GetIsObjectValid(oShard = GetObjectByTag(sShard, ++j))) // destroy all shards ->
		{
			if (GetIsObjectValid(GetItemPossessor(oShard)))
			{
				// its on party that are despawned (in the current Module)
				// can remain as 'loose' its in the Module in addition to
				// being saved out on the roster character
				//
				// so don't count those loose/rogue its; count only its
				// in containers
				++tally;
			}

			DestroyObject(oShard, 0.f, FALSE);
		}
	}

	if (tally < SHARDS_TOTAL)
		DelayCommand(0.f, DestroyShardsRoster(tally));
}


// kL Unhides the camera-trackers that were set ScriptHidden in
// '3052_cliententer' OnClientEnter handler for the area.
void unhide_trackers()
{
	object oTracker;

	int i = 0;
	while (++i <= 5)
	{
		oTracker = GetNearestObjectByTag("3052_camera_tracker" + IntToString(i));
		SetScriptHidden(oTracker, FALSE);
	}
}


void ZhjaeveMovesToScar()
{
	ActionForceMoveToObject(GetNearestObjectByTag("3052_wp_zhjaeve_sit"), FALSE, 0.f);
	ActionDoCommand(SetFacingPoint(GetPosition(GetNearestObjectByTag("3052_wp_ssplaceable")))); // SetFacing() fails (or can fail) here

	object oPc = GetPCSpeaker();
	float dir = GetDirectionTo(GetNearestObjectByTag("3052_wp_ssplaceable"), oPc);
	AssignCommand(oPc, DelayCommand(0.9f, ActionDoCommand(SetFacing(dir))));
}

void PcMovesToScarAndZhjaeveSits()
{
	object oPc = GetPCSpeaker();

	AssignCommand(oPc, ActionForceMoveToObject(GetNearestObjectByTag("3052_wp_pc_sit"), FALSE, 0.f));

	float dir = GetDirectionTo(GetNearestObjectByTag("3052_wp_ssplaceable"), oPc);
	AssignCommand(oPc, ActionDoCommand(SetFacing(dir))); // SetFacingPoint() fails (or can fail) here

	DelayCommand(1.2f, play(OBJECT_SELF, "sitgroundidle"));
}

// helper for PcSits()
// kL Modified: got rid of the bogus drop routine.
void unequip(object oTarget)
{
	object oWeaponLh = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oTarget);
	object oWeaponRh = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oTarget);

	AssignCommand(oTarget, ClearAllActions());

	AssignCommand(oTarget, ActionUnequipItem(oWeaponLh));
	AssignCommand(oTarget, ActionUnequipItem(oWeaponRh));
}

void PcSits()
{
	object oPc = GetPCSpeaker();

	DelayCommand(0.7f, unequip(oPc)); // delayed to make any weapon drop more noticeable

	DelayCommand(1.1f, play(oPc, "sitgroundidle"));
	DelayCommand(1.5f, party_face(OBJECT_SELF));
}

void SpawnSwordFragments()
{
	object oWp = GetNearestObjectByTag("3052_wp_ssplaceable");
	CreateObject(OBJECT_TYPE_PLACEABLE,
				 "3052_plc_brokenswd",
				 GetLocation(oWp),
				 FALSE,
				 "3052_ss_fragments");
}

void ShardsGlowSoftly()
{
	effect eSef = EffectNWN2SpecialEffectFile("fx_shard_rip");
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSef, GetNearestObjectByTag("3052_ss_fragments"), 5.f);
}

void PcGlowsSoftly()
{
	effect eSef = EffectNWN2SpecialEffectFile("fx_shard_rip");
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSef, GetPCSpeaker(), 15.f);
}

void ShardsGlowBrightly()
{
	effect eSef = EffectNWN2SpecialEffectFile("3052_fx_shard_glow");
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSef, GetNearestObjectByTag("3052_ss_fragments"), 10.f);
}

void PcGlowsBrightly()
{
	effect eSef = EffectNWN2SpecialEffectFile("fx_glowstone_blue_p");
	ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSef, GetLocation(GetPCSpeaker()), 5.f);
}

void CreateSwordPlacedEffect()
{
	object oWp = GetNearestObjectByTag("3052_wp_ssplaceable");

	vector pos = GetPosition(oWp);
	location loc = Location(GetArea(oWp), Vector(pos.x - 0.75f, pos.y, pos.z), 0.f); // else Location of oWp can effup.
	object oSword = CreateObject(OBJECT_TYPE_PLACED_EFFECT, "fx_silversword_reform", loc);

	object oSound = GetNearestObjectByTag("3052_snd_sword_forge");
	DelayCommand(0.5f, SoundObjectPlay(oSound));

	DelayCommand(6.f, DestroyObject(oSword));
}

void DestroyShardPlaceable()
{
	object oShards = GetNearestObjectByTag("3052_ss_fragments");
	DestroyObject(oShards);
}

void FadeToWhite()
{
	object oPc = GetFirstPC();
	object oParty = GetFirstFactionMember(oPc);
	while (GetIsObjectValid(oParty))
	{
		FadeToBlack(oParty, 1.f, 9.13f, 0xFFFFFF); // white
		oParty = GetNextFactionMember(oPc);
	}
}

void PCRaiseSilverSword()
{
	play(GetPCSpeaker(), "liftswordloop", TRUE, 0.5f);
}


// kL helper for CreateAndEquipSilverSword()
int is_stacksize_one(object oIt)
{
	int type = GetBaseItemType(oIt);
	string stacksize = Get2DAString("baseitems", "Stacking", type);
	return stacksize == "1";
}

// kL helper for create_and_equip()
void copy_dropped(object oDropped, object oPc)
{
	CopyObject(oDropped, GetLocation(oPc), oPc);
	DestroyObject(oDropped);
}

// kL helper for CreateAndEquipSilverSword()
void create_and_equip(object oPc, object oDropped)
{
	object oSilverSword = CreateItemOnObject(RR_SILVER_SWORD, oPc);
	AssignCommand(oPc, ActionEquipItem(oSilverSword, INVENTORY_SLOT_RIGHTHAND));

	AssignCommand(oPc, ActionDoCommand(copy_dropped(oDropped, oPc)));
}

// kL Modified: Ensure there's room in the PC's inventory for the Silver blade.
void CreateAndEquipSilverSword()
{
	object oPc = GetPCSpeaker();
	object oSilverSword = CreateItemOnObject(RR_SILVER_SWORD, oPc);

	if (!GetIsObjectValid(GetItemPossessedBy(oPc, RR_SILVER_SWORD))) // blade dropped; inventory full; handle it ->
	{
		object oDropit = GetFirstItemInInventory(oPc); // find an item outside a bag to drop ->
		while (GetIsObjectValid(oDropit))
		{
			if (GetHasInventory(oDropit)) // don't drop a bag ...
			{
				object oContainer = oDropit;

				object oSubit = GetFirstItemInInventory(oContainer);
				while (GetIsObjectValid(oSubit))
				{
					oSubit = GetNextItemInInventory(oContainer);
					oDropit = GetNextItemInInventory(oPc);
				}
			}
			else if (!GetPlotFlag(oDropit) // not a bag or plot or cursed etc. Go with it
				&& !GetItemCursedFlag(oDropit)
				&& is_stacksize_one(oDropit))
			{
				break;
			}
			// else Silver blade drops to the ground

			oDropit = GetNextItemInInventory(oPc);
		}

		if (GetIsObjectValid(oDropit)) // safety. 'oDropit' shall be valid (unless PC has 128 bags ... and/or only uncontained items that are plot or cursed)
		{
			object oDropped = CopyObject(oDropit, GetLocation(oPc));
			DestroyObject(oDropit);

			DestroyObject(oSilverSword);

			DelayCommand(0.f, create_and_equip(oPc, oDropped)); // delayed to ensure 'oDropit' is destroyed first
		}
		// else Silver blade drops to the ground
	}
	else
		AssignCommand(oPc, ActionEquipItem(oSilverSword, INVENTORY_SLOT_RIGHTHAND));
}

void ZhjaeveAndPcStandUp()
{
	play(OBJECT_SELF, "%");
	play(GetPCSpeaker(), "%");
}


void RevealReaver()
{
	object oReaver = GetNearestObjectByTag(TAG_REAVER_3052);
	SetScriptHidden(oReaver, FALSE);

	effect eFlash = EffectNWN2SpecialEffectFile("fx_garius_ritual");
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eFlash, oReaver);

	ResetGroup(REAVER_PARTY_NAME);
	GroupAddMember(REAVER_PARTY_NAME, oReaver);

	object o;

	int i = 0;
	while (++i <= 3)
	{
		o = GetNearestObjectByTag("3052_felemen" + IntToString(i));
		SetScriptHidden(o, FALSE);
		GroupAddMember(REAVER_PARTY_NAME, o, FALSE);
	}

	i = 0;
	while (++i <= 2)
	{
		o = GetNearestObjectByTag("3052_bgolem" + IntToString(i));
		SetScriptHidden(o, FALSE);
		GroupAddMember(REAVER_PARTY_NAME, o, FALSE);
	}

	party_face(oReaver);
}

void FlamesErupt()
{
	object oWp;

	int i = 0;
	while (++i <= 13)
	{
		oWp = GetNearestObjectByTag("3052_wp_reaverfire" + IntToString(i));
		CreateObject(OBJECT_TYPE_PLACED_EFFECT,
					 "n2_fx_fire_lg",
					 GetLocation(oWp),
					 FALSE,
					 "3052_reaverfire" + IntToString(i));
	}

	object o3052 = GetObjectByTag("3052_wharbor");

	SetLocalInt(o3052, "ReaverFlamesOn", TRUE);

	SoundObjectPlay(GetNearestObjectByTag("3052_snd_reaver_entrance"));
	SoundObjectPlay(GetNearestObjectByTag("3052_snd_fire_smolder_scar"));
	SoundObjectPlay(GetNearestObjectByTag("3052_snd_fire_large_scar"));

	MusicBackgroundStop(o3052);
}

void RevealShadows1()
{
	effect ePoof = EffectNWN2SpecialEffectFile("sp_bless");
	object oShadow;

	int i = 0;
	while (++i <= 2)
	{
		oShadow = GetNearestObjectByTag("3052_reaver_shadow" + IntToString(i)); // TAG_SHADOW_3052

		SetScriptHidden(oShadow, FALSE);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoof, oShadow, 1.f);

		GroupAddMember(REAVER_MINIONS, oShadow);
	}
}

void RevealShadows2()
{
	effect ePoof = EffectNWN2SpecialEffectFile("sp_bless");
	object oShadow;

	int i = 2;
	while (++i <= 4)
	{
		oShadow = GetNearestObjectByTag("3052_reaver_shadow" + IntToString(i)); // TAG_SHADOW_3052

		SetScriptHidden(oShadow, FALSE);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoof, oShadow, 1.f);

		GroupAddMember(REAVER_MINIONS, oShadow);
	}
}

void TurnReaverPartyHostile()
{
	GroupChangeToStandardFaction(REAVER_PARTY_NAME, STANDARD_FACTION_HOSTILE);
	GroupChangeToStandardFaction(REAVER_MINIONS, STANDARD_FACTION_HOSTILE);
	GroupDetermineCombatRound(REAVER_PARTY_NAME);
	GroupDetermineCombatRound(REAVER_MINIONS);
}


void MoveCameraTracker(string id)
{
	object oTracker = GetNearestObjectByTag("3052_camera_tracker" + id);
	object oWp = GetNearestObjectByTag("3052_wp_tracker" + id);

	AssignCommand(oTracker, ActionForceMoveToObject(oWp));
}

void HideCameraTracker(string id)
{
	object oTracker = GetNearestObjectByTag("3052_camera_tracker" + id);
	SetScriptHidden(oTracker, TRUE);
}

void DestroyCameraTrackers()
{
	object oTracker;

	int i = 0;
	while (++i <= 5)
	{
		oTracker = GetNearestObjectByTag("3052_camera_tracker" + IntToString(i));
		DestroyObject(oTracker);
	}
}

// kL
void party_face(object oTarget)
{
	object oZhjaeve = OBJECT_SELF;
	object oPc = GetPCSpeaker();

	float dir;

	object oParty = GetFirstFactionMember(oPc, FALSE);
	while (GetIsObjectValid(oParty))
	{
		if (oParty != oPc && oParty != oZhjaeve) // PC and Zhjaeve already have their facing taken care of.
		{
			dir = GetDirectionTo(oTarget, oParty);
			AssignCommand(oParty, ActionDoCommand(SetFacing(dir)));
		}
		oParty = GetNextFactionMember(oPc, FALSE);
	}
}

// kL
const float epsi = 0.00005f;

// kL
// Gets the direction (0.f .. 360.f in degrees) for oSource to face oTarget.
// - returns 999.f if source and target are at the same position
// - note before call Ensure that
//   (GetIsObjectValid(oSource) && GetIsObjectValid(oTarget)
//    && GetArea(oSource) == GetArea(oTarget))
// - a check should also be done for (oSource != oTarget) but if they are the
//   return is 999.f
float GetDirectionTo(object oTarget, object oSource = OBJECT_SELF)
{
	vector pSource = GetPosition(oSource);
	vector pTarget = GetPosition(oTarget);

	float dx = pTarget.x - pSource.x;
	float dy = pTarget.y - pSource.y;

	float dx_abs = fabs(dx);
	float dy_abs = fabs(dy);

	if (dx_abs > epsi || dy_abs > epsi)
	{
		if (dx_abs <= epsi) // guard vs divbyzero
		{
			if (dy < 0.f) return 270.f;
						  return  90.f;
		}

		if (dy_abs <= epsi)
		{
			if (dx < 0.f) return 180.f;
						  return   0.f;
		}

		float dir = atan(dy_abs/dx_abs); // yep they return atan in degrees ...

		if (dx < 0.f)
		{
			if (dy > 0.f) return 180.f - dir;	// top left quadrant
						  return 180.f + dir;	// bot left quadrant
		}

		if (dy < 0.f) return 360.f - dir;		// bot right quadrant
					  return         dir;		// top right quadrant
	}
	return 999.f;
}


//#include "30_true_name_inc"
//void UseTrueName(string sTag);

/* helper for UseTrueName()
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
//	object oScroll = GetItemPossessedBy(oReciter, TAG_TRUE_NAME_SCROLL);
//	event eActivate = EventActivateItem(oScroll, lReaver, oReaver);
//	SignalEvent(oReciter, eActivate);
} */
