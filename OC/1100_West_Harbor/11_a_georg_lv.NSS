// '11_a_georg_lv'
/*
	Georg and friends leave area.

	No they don't. This script either (a) moves Georg and his guards to the
	gathering point, or (b) moves Georg and all recruits to the battle-line in
	the wheatfield.
*/
// JYL 03/06/06
// kevL 2019 apr 13 - fix tag: '11_figher1' -> '11_fighter1'
// kevL 2019 apr 14 - got sick of looking at their crapcode and refactored it

#include "x2_inc_switches"

const string sTAG_MILITIA_PRE   = "11_militia";
const string sWP_WHEATFIELD_PRE = "11_farm_stop";


void MilitiaLineup();
void GoGeorg_phb(object oDest);


//
void main(int iDialogNode)
{
	switch (iDialogNode)
	{
		case 10: // Move Georg and his guards (if alive) to the gathering area.
		{
			object oWheat = GetObjectByTag("10_mn_wheat");
			SetMapPinEnabled(oWheat, TRUE);


//			object oGeorg = OBJECT_SELF; // "npc_georg_red"

			SetCommandable(TRUE);
			ClearAllActions(TRUE);

			object oDest = GetWaypointByTag("11_wp_georg_wait");
			ActionForceMoveToObject(oDest, TRUE);

			ActionDoCommand(SetCommandable(TRUE));
			SetCommandable(FALSE);

			DelayCommand(10.f, GoGeorg_phb(oDest));


			object oGuard = GetObjectByTag("11_georg_guard1");
			if (GetIsObjectValid(oGuard) && !GetIsDead(oGuard))
			{
				AssignCommand(oGuard, SetCommandable(TRUE));
				AssignCommand(oGuard, ClearAllActions(TRUE));

				oDest = GetWaypointByTag("11_wp_gguard1");
				AssignCommand(oGuard, ActionForceMoveToObject(oDest, TRUE));
				AssignCommand(oGuard, ActionDoCommand(DestroyObject(oGuard)));

				AssignCommand(oGuard, SetCommandable(FALSE));
			}

			oGuard = GetObjectByTag("11_georg_guard2");
			if (GetIsObjectValid(oGuard) && !GetIsDead(oGuard))
			{
				AssignCommand(oGuard, SetCommandable(TRUE));
				AssignCommand(oGuard, ClearAllActions(TRUE));

				oDest = GetWaypointByTag("11_wp_gguard2");
				AssignCommand(oGuard, ActionForceMoveToObject(oDest, TRUE));
				AssignCommand(oGuard, ActionDoCommand(DestroyObject(oGuard)));

				AssignCommand(oGuard, SetCommandable(FALSE));
			}
			break;
		}

		case 20: // Move Georg and recruits to battle-line in the wheatfield.
			MilitiaLineup();
			break;
	}
}


// pseudo-heartbeat to get Georg to his destination
void GoGeorg_phb(object oDest)
{
	if (GetDistanceToObject(oDest) > 5.f)
	{
		if (!IsInConversation(OBJECT_SELF)
			&& GetCurrentAction() == ACTION_INVALID)
		{
			SetCommandable(TRUE);

			ActionForceMoveToObject(oDest, TRUE);
			ActionDoCommand(SetCommandable(TRUE));

			SetCommandable(FALSE);
		}
		DelayCommand(10.f, GoGeorg_phb(oDest)); // recurse
	}
}

// Moves Georg and the recruits to the battle-line in the wheatfield before the
// first evil wave of creatures attack.
void MilitiaLineup()
{
	SetGlobalInt("11_clean_up_time", TRUE); // start deleting NPCs that weren't recruited


	object oDwarf = GetObjectByTag("11_die_dwarf");
	if (GetIsObjectValid(oDwarf))
		DestroyObject(oDwarf, 0.1f);

//	object oGeorg = OBJECT_SELF; // "npc_georg_red"

	SetCreatureOverrideAIScript(OBJECT_SELF, "11_dcr_spreadattack");

	SetCommandable(TRUE);
	ClearAllActions(TRUE);

	object oDest = GetWaypointByTag("11_farm_georg");
	ActionForceMoveToObject(oDest, TRUE);


	// kL_begin: move Tarmas to the wheatfield
	// NOTE: Is done in '11_tr_startwaves' - but only if the gith-mage cutscene failed ...
	// but if that happened you've got bigger problems to worry about.
	object oTarmas = GetObjectByTag("npc_tarmas");
	if (GetIsObjectValid(oTarmas))
	{
		AssignCommand(oTarmas, SetCommandable(TRUE));
		AssignCommand(oTarmas, ClearAllActions(TRUE));

		oDest = GetWaypointByTag("11_wp_tarmas_farm");
		AssignCommand(oTarmas, ActionForceMoveToObject(oDest, TRUE));
		AssignCommand(oTarmas, ActionDoCommand(SetCommandable(TRUE)));

		AssignCommand(oTarmas, SetCommandable(FALSE));
	}
	// kL_end.


	object oPierson = GetObjectByTag("11_pierson");
	if (GetIsObjectValid(oPierson) && !GetIsDead(oPierson))
	{
		SetCreatureOverrideAIScript(oPierson, "11_dcr_spreadattack");

		AssignCommand(oPierson, SetCommandable(TRUE));
		AssignCommand(oPierson, ClearAllActions(TRUE));

		oDest = GetWaypointByTag(sWP_WHEATFIELD_PRE + "7");
		AssignCommand(oPierson, ActionForceMoveToObject(oDest, TRUE));
	}

	object oCoward = GetObjectByTag("11_coward");
	if (GetIsObjectValid(oCoward) && !GetIsDead(oCoward))
	{
		SetCreatureOverrideAIScript(oCoward, "11_dcr_spreadattack");

		AssignCommand(oCoward, SetCommandable(TRUE));
		AssignCommand(oCoward, ClearAllActions(TRUE));

		oDest = GetWaypointByTag(sWP_WHEATFIELD_PRE + "8");
		AssignCommand(oCoward, ActionForceMoveToObject(oDest, TRUE));
	}

	object oMilitia;
	int i = 1;
	for (; i <= 6; ++i)
	{
		oMilitia = GetObjectByTag(sTAG_MILITIA_PRE + IntToString(i));
		if (GetIsObjectValid(oMilitia) && !GetIsDead(oMilitia))
		{
			SetCreatureOverrideAIScript(oMilitia, "11_dcr_spreadattack");

			AssignCommand(oMilitia, SetCommandable(TRUE));
			AssignCommand(oMilitia, ClearAllActions(TRUE));

			oDest = GetWaypointByTag(sWP_WHEATFIELD_PRE + IntToString(i));
			AssignCommand(oMilitia, ActionForceMoveToObject(oDest, TRUE));
		}
	}
}

// kL_add: Tags and Waypoints
/*
npc_merring		- Brother Merring
npc_tarmas		- Tarmas
npc_georg_red	- Georg Redfell

11_georg_guard1	- male guard
11_georg_guard2	- female guard

TAGS BEFORE RECRUITED
fightvillager2	- Lazlo Buckman
11_fighter1		- female militia
fightvillager3a	- Webb Mossfeld
11_wounded1		- Wyl Mossfeld
11_wounded2		- Ward Mossfeld
11_wounded3		- Pitney Lannon

11_greed_guy	- Pierson
11_coward_guy	- Ian Harmon

TAGS AFTER RECRUITED
11_militia1	- Lazlo Buckman
11_militia2	- female militia
11_militia3	- Webb Mossfeld
11_militia4	- Wyl Mossfeld
11_militia5	- Ward Mossfeld
11_militia6	- Pitney Lannon

11_pierson	- Pierson
11_coward	- Ian Harmon

--
WAYPOINTS AT GATHER POINT
wp_west_harbor_north
11_wp_gith_exit

11_wp_georg_wait
11_wp_gguard1
11_wp_gguard2

11_wp_whrecruit1
11_wp_whrecruit2
11_wp_whrecruit3
11_wp_whrecruit4
11_wp_whrecruit5
11_wp_whrecruit6
11_wp_whrecruit7
11_wp_whrecruit8
11_wp_whrecruit9
11_wp_whrecruit10

WAYPOINTS AT WHEATFIELD
11_wp_tarmas_farm
11_wp_farm_battle

11_farm_georg
11_farm_guard1
11_farm_guard2

11_farm_stop1
11_farm_stop2
11_farm_stop4
11_farm_stop5
11_farm_stop6
11_farm_stop7
11_farm_stop8
*/
