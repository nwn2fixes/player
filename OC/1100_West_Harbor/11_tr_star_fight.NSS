//::///////////////////////////////////////////////////////////////////////////
//::
//::	11_tr_star_fight.nss
//::
//::	Make the dwarves fight player.
//::
//::///////////////////////////////////////////////////////////////////////////
// travus 2/7/24 - Set dogs to STANDARD_FACTION_DEFENDER so they fight the dwarves.
// kevL 2024.02.08 - tweaks

#include "ginc_group"
#include "x0_i0_walkway"

const string sGROUP = "ATTACK_GROUP";

//
void DogAttack(string sTag)
{
	object oDog = GetNearestObjectByTag(sTag);
	if (GetIsObjectValid(oDog))
	{
		ChangeToStandardFaction(oDog, STANDARD_FACTION_DEFENDER);

		// These next two lines are required in-case the player enters the room before
		// speaking with Retta so a walk-waypoint path is set for the dogs.
		SetWWPController("stardogs", oDog);
		AssignCommand(oDog, MoveToNextWaypoint(TRUE, TRUE));
	}
}

void main()
{
	if (!GetLocalInt(OBJECT_SELF, "DoOnce"))
	{
		object oEnter = GetEnteringObject();
		if (GetIsPC(oEnter))
		{
			SetLocalInt(OBJECT_SELF, "DoOnce", TRUE);

			GroupChangeToStandardFaction(sGROUP, STANDARD_FACTION_HOSTILE);

			object oMember = GetFirstInGroup(sGROUP);
			while (GetIsObjectValid(oMember))
			{
				AssignCommand(oMember, DetermineCombatRound(oEnter));
				oMember = GetNextInGroup(sGROUP);
			}

			DogAttack("11_dog_nasher");
			DogAttack("11_dog_mutton");
			DogAttack("11_dog_locke");
		}
	}
}
