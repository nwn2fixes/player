// 'f10_a_spawn_shadows'
/*
	Spawns greater shadows.
*/
// JSH-OEI 4/30/08
// Akhacha 2023/10/31 - Fixed script checking GetArea(oWP) against OBJECT_SELF,
//                      rather than GetArea(OBJECT_SELF).
// kevL 2023 nov 1 - refactor a bit and remark debug

#include "ginc_group"

void SpawnCreature(string sResRef)
{
	int i = 0;

	string sWPTag = "sp_" + sResRef;
	object oWP = GetObjectByTag(sWPTag);
	while (GetIsObjectValid(oWP))
	{
		//PrettyDebug ("Spawning in " + sResRef);

		if (GetObjectType(oWP) == OBJECT_TYPE_WAYPOINT
			&& GetArea(oWP) == GetArea(OBJECT_SELF) // Akhacha_fix
			&& !IsMarkedAsDone(oWP))
		{
			MarkAsDone(oWP);

			location lLoc = GetLocation(oWP);
			object oCreature = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc);

			GroupAddMember("F10 Shadows", oCreature);
		}
		oWP = GetObjectByTag(sWPTag, ++i);
	}
}

void main()
{
	SpawnCreature("f10_greater_shadow");
	GroupDetermineCombatRound("F10 Shadows");
}
