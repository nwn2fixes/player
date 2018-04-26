//::///////////////////////////////////////////////////////////////////////////
//::
//::	30a_nasher.nss
//::
//::	This file contains the custcene actions for conversation 30_nasher.
//::
//::///////////////////////////////////////////////////////////////////////////
//::
//::	Created by: Brian Fox
//::	Created on: 10/21/05
//::
//::///////////////////////////////////////////////////////////////////////////

#include "30_constants"
#include "ginc_actions"
#include "ginc_param_const"
#include "ginc_debug"
#include "ginc_item"
#include "nw_i0_plot"

//::///////////////////////////////////////////////////////////////////////////

const string CHEST_TAG = "pl_3000_gear_chest";
const string TAG_THRONEROOM_GATE = "30_castle_gate3";

//::///////////////////////////////////////////////////////////////////////////

void NasherAttackReaver();
void OpenAllDoors();
void PCEquipRodOfNever(object oPC);
void NevalleEntersThroneroom();
void PlayerBowsForCeremony(object oPC);
void ReturnItemsToPCInventory();
void CrowdExits();

void PlayCustomAnimationVoid(object oTarget, string sFilename, int bLooping)
{
	if (!PlayCustomAnimation(oTarget, sFilename, bLooping))
		PrettyDebug(GetTag(oTarget) + " does not have " + sFilename + " animation!");
}

//::///////////////////////////////////////////////////////////////////////////

void main(int nChoice)
{
	object oPC = GetPCSpeaker();

	switch(nChoice)
	{
		case 5:
			NasherAttackReaver();
			break;

		case 10:
			OpenAllDoors();
			break;

		case 20:
			ActionPauseCutscene(PAUSE_TIME, FALSE);
			NevalleEntersThroneroom();
			break;

		case 25:
			ActionPauseCutscene(PAUSE_TIME, FALSE);
			PlayerBowsForCeremony(oPC);

		case 30:
			CrowdExits();
			break;

		case 40:
			ReturnItemsToPCInventory();
			break;

		default:
			PrettyError("ERROR: unhandled case (" + IntToString(nChoice) + ") in 30a_nasher");
			break;
	}
}

//::///////////////////////////////////////////////////////////////////////////

void NasherAttackReaver()
{
	object oNasher = GetTarget(TAG_NASHER);
	object oReaver = GetTarget(TAG_REAVER_1);

	AssignCommand(oNasher, ActionAttack(oReaver));
}

// kL. Reverts changes that were made to Nasher and his guards after the PC
// exits the Underneath and a Reaver's assassination attempt fails. This 'unfix'
// code runs during the PC's knighting cutscene in the throne room.
// - helper for OpenAllDoors()
void RevertFixes(object oTarget, object oFaction)
{
	ChangeFaction(oTarget, oFaction);
	ClearCombatOverrides(oTarget);
	ForceRest(oTarget);
}

void OpenAllDoors()
{
	//PrettyDebug("OPENING ALL DOORS");

	// kL: The gate has already been opened in '3000_cliententer'. This function
	// is repurposed to clear several changes that were made to Nasher and his
	// guards that fixed up the Battle of the Rod (the Reaver assassination attempt
	// on Nasher - after PC exits the Underneath).

	object oNasher = OBJECT_SELF; // Nasher is speaker
	SetPlotFlag(oNasher, TRUE);

	object oFaction = CreateObject(OBJECT_TYPE_CREATURE, "3000_nasher_pig", GetLocation(oNasher));
	RevertFixes(oNasher, oFaction);

	int i = 1;
	object oGuard = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oNasher, i);
	while (GetIsObjectValid(oGuard))
	{
		if (!GetIsDead(oGuard))
			RevertFixes(oGuard, oFaction);

		oGuard = GetNearestObjectByTag(TAG_3000_GUARD_INTERIOR, oNasher, ++i);
	}

	DestroyObject(oFaction);


/*	int nCounter = 1;
	object oDoor = GetNearestObjectByTag(TAG_THRONEROOM_GATE, OBJECT_SELF, nCounter); // kL_note: There's only one.
	while (GetIsObjectValid(oDoor))
	{
		//AssignCommand(oDoor, SetLocked(OBJECT_SELF, FALSE));
		//AssignCommand(oDoor, ActionOpenDoor(OBJECT_SELF));
		DelayCommand(0.5f, AssignCommand(oDoor, SetLocked(OBJECT_SELF, FALSE)));
		DelayCommand(0.6f, AssignCommand(oDoor, ActionOpenDoor(OBJECT_SELF)));
		oDoor = GetNearestObjectByTag(TAG_THRONEROOM_GATE, OBJECT_SELF, ++nCounter);
	} */
}

void PCEquipRodOfNever(object oPC)
{
	object oRod = GetItemPossessedBy(oPC, TAG_ROD_OF_NEVER);

	if (!GetIsObjectValid(oRod))
	{
		PrettyDebug("PC does not possess the Rod of Never!");
		return;
 	}

	AssignCommand(oPC, ActionEquipItem(oRod, INVENTORY_SLOT_LEFTHAND));
}

void NevalleEntersThroneroom()
{
	//PrettyDebug("NEVALLE IS ENTERING THE THRONEROOM");

	object oNevalle = GetTarget(TAG_NEVALLE);
	object oNasher = GetTarget(TAG_NASHER);
	object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oNevalle);

	AssignCutsceneActionToObject(oNevalle, ActionForceMoveToObject(oNasher, TRUE, 2.0f));
	AssignCommand(oNevalle, ActionUnequipItem(oWeapon));
}

void PlayerBowsForCeremony(object oPC)
{
	object oNasher = GetTarget(TAG_NASHER);

	AssignCutsceneActionToObject(oPC, PlayCustomAnimationVoid(oPC, "%", 0));
	AssignCutsceneActionToObject(oPC, PlayCustomAnimationVoid(oPC, "kneeldown", 0));
	DelayCommand(0.5f, AssignCutsceneActionToObject(oPC, PlayCustomAnimationVoid(oPC, "kneelidle", 1)));
	DelayCommand(0.5f, AssignCutsceneActionToObject(oPC, PlayCustomAnimationVoid(oPC, "%", 0)));
	DelayCommand(2.5f, AssignCutsceneActionToObject(oPC, PlayCustomAnimationVoid(oPC, "kneelup", 0)));
	DelayCommand(2.5f, AssignCutsceneActionToObject(oPC, PlayCustomAnimationVoid(oPC, "%", 0)));

	AssignCutsceneActionToObject(oNasher, PlayCustomAnimationVoid(oNasher, "%", 0));
	AssignCutsceneActionToObject(oNasher, PlayCustomAnimationVoid(oNasher, "opendoor", 0));
}

void ReturnItemsToPCInventory()
{
	//PrettyDebug("Returning original items to PC");

	object oPC = GetPCSpeaker();
	object oChest = GetTarget(CHEST_TAG);

	GiveAllInventory(oChest, oPC);
	RestoreEquippedItems(oPC);
}

void CrowdExits()
{
	int i = 1;
	object oNPC = GetNearestObjectByTag(TAG_3000_AUDIENCE, OBJECT_SELF, i);
	object oNasher = GetTarget(TAG_NASHER);

	AssignCommand(oNasher, ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)));

	while (GetIsObjectValid(oNPC))
	{
		AssignCommand(oNPC, EscapeArea(FALSE));
		oNPC = GetNearestObjectByTag(TAG_3000_AUDIENCE, OBJECT_SELF, ++i);
	}
}
