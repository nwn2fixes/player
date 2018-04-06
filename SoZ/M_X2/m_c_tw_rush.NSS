//	m_c_tw_rush
/*
	Checks to see if the party qualifies for the Team Rush teamwork benefit.
	
	100 - Check to see if a PC has Survival 8+ and the Toughness feat.
	200 - Check to see if all party members have Survival 1+.
*/
//	JSH-OEI 7/28/08
// kevL 2018 apr 6 - FIX: change leader prerequisite conditional operator from AND to OR
//                        Daerred needs *both* conditions else disqualified.

int StartingConditional(int nCase)
{
	object oPC				= GetPCSpeaker();
	object oPartyMember		= GetFirstFactionMember(oPC, FALSE);

	switch (nCase)
	{
		case 100:	// Team Rush - Leader Prerequisite
			if (GetSkillRank(SKILL_SURVIVAL, oPC, TRUE)<8
				|| !GetHasFeat(FEAT_TOUGHNESS, oPC)) // kL_change.
				return TRUE;
			else	
				return FALSE;
				
		case 200:	// Team Rush - Team Member Prerequisite
			while (GetIsObjectValid(oPartyMember))
			{
				/*	*All* party members must meet this requirement.	*/
				if (GetIsRosterMember(oPartyMember) || GetIsOwnedByPlayer(oPartyMember))
				{
					if (GetSkillRank(SKILL_SURVIVAL, oPartyMember, TRUE)<1)
						return TRUE;
				}
				oPartyMember	= GetNextFactionMember(oPC, FALSE);
			}
			return FALSE;
					
		break;
	}
	
	return FALSE;
}