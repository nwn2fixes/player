// 22_cs_ulip.nss
// Cutscene controller for Ulip meeting cutscene (22_ulip)
// BMA-OEI 8/14/05
// travus 1/14/26 - Destroys a misplaced goblin that is stuck in the wall.

#include "ginc_group"
#include "22_inc_goblins"

const string sUlipGroup = "UlipGobos";

void SetupUlipGoblins()
{
	ResetGroup(sUlipGroup);
	GroupSetBMAFormation(sUlipGroup);
	GroupSetNoise(sUlipGroup);
	GroupAddMember(sUlipGroup, OBJECT_SELF);
	GroupAddTag(sUlipGroup, "22_ulipgobos");
}

void UlipRunsToPC()
{
	ActionPauseCutscene(5000);
	GroupMoveToWP(sUlipGroup, "2222_wp_ulipstop", MOVE_FORCE_RUN);
}

void UlipGobosGoHostile()
{
	object oPC = GetPCSpeaker();
	GroupSetImmortal(sUlipGroup, FALSE);
	GroupSetPlotFlag(sUlipGroup, FALSE);
	GroupAttack(sUlipGroup, oPC);
}

void main(int nCase)
{
	switch (nCase)
	{
		case 100:
			DestroyObject(GetNearestObjectByTag("22_goblin")); // travus fix
			SetupUlipGoblins();
			break;

		case 110:
			UlipRunsToPC();
			break;

		case 200:
			SetLocalInt(GetModule(), "bKilledUlip", TRUE);
			GoblinsGoHostile();
			break;

		default:
			PrintString("22_ulip.nss: case " + IntToString(nCase) + " does not exist");
			break;
	}
}
