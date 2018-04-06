//	m_c_tw_foe
/*
	Checks to see if the party qualifies for the Foe Hunting teamwork benefit.

	100 - Check to see if a PC has Favored Enemy (any).
	200 - Check to see if all other party members have Survival 1+ and BAB 4+.
*/
//	JSH-OEI 7/28/08
// kevL 2018 apr 6 - team member prerequisites changed from Concentration skill
//                   to Survival skill (per Candril's dialog) and to require
//                   *both* Survival 1+ and BAB 4+ (per Candril's dialog).
//                 - add Favored Enemy Plant to satisfy leader prerequisite.

int StartingConditional(int nCase)
{
	object oPC				= GetPCSpeaker();
	object oPartyMember		= GetFirstFactionMember(oPC, FALSE);


	switch (nCase)
	{
		case 100:	// Foe Hunting - Leader Prerequisite
			if (!GetHasFeat(FEAT_FAVORED_ENEMY_ABERRATION, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_BEAST, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_CONSTRUCT, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_DRAGON, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_DWARF, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_ELEMENTAL, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_ELF, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_FEY, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_GIANT, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_GNOME, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_GOBLINOID, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_HALFELF, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_HALFLING, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_HALFORC, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_HUMAN,oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_MAGICAL_BEAST, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_MONSTROUS, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_ORC, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_OUTSIDER, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_REPTILIAN, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_SHAPECHANGER, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_UNDEAD, oPC)
				&& !GetHasFeat(FEAT_FAVORED_ENEMY_VERMIN, oPC)
				&& !GetHasFeat(282, oPC)) // Plant // kL_add.
				return TRUE;

			return FALSE;

		case 200:	// Foe Hunting - Team Member Prerequisite
			while (GetIsObjectValid(oPartyMember))
			{
				/*	All other party members must meet this requirement.	*/
				if ((oPartyMember != oPC) && (GetIsRosterMember(oPartyMember) || GetIsOwnedByPlayer(oPartyMember)))
				{
					if (GetSkillRank(SKILL_SURVIVAL, oPartyMember, TRUE)<1	// kL_fixed: Used to be Concentration.
						|| GetBaseAttackBonus(oPartyMember)<4)				// kL_fixed: Used to be AND condition.
						return TRUE;
				}
				oPartyMember	= GetNextFactionMember(oPC, FALSE);
			}
			return FALSE;

		break;
	}

	return FALSE;
}