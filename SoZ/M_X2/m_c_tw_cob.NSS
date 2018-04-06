//	m_c_tw_cob
/*
	Checks to see if the party qualifies for the Circle of Blades teamwork benefit.
	
	100 - Check to see if a PC has Weapon Specialization (Any) and BAB +6
	200 - Check to see if all party members have Sneak Attack +1d6 OR Weapon Finesse.
*/
//	JSH-OEI 7/28/08
// kevL 2018 apr 6 - FIX: change leader prerequisite conditional operator from AND to OR
//                        Juen requires *both* conditions - else disqualified.

int StartingConditional(int nCase)
{
	object oPC				= GetPCSpeaker();
	object oPartyMember		= GetFirstFactionMember(oPC, FALSE);


	switch (nCase)
	{
		case 100:	// Circle of Blades - Leader Prerequisite
			if (GetBaseAttackBonus(oPC)<6 // kL_fixed: Used to be AND.
				|| (!GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BASTARD_SWORD, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_BATTLE_AXE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_CLUB, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DAGGER, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_DWAXE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_AXE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_GREAT_SWORD, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HALBERD, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HAND_AXE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KAMA, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KATANA, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_KUKRI, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_HAMMER, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_HEAVY_FLAIL, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_FLAIL,oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LIGHT_MACE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_LONG_SWORD, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_MORNING_STAR, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_RAPIER, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCIMITAR, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SCYTHE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SHORT_SWORD, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SICKLE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_SPEAR, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_STAFF, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE, oPC)
					&& !GetHasFeat(FEAT_WEAPON_SPECIALIZATION_WAR_HAMMER, oPC)
					&& !GetHasFeat(1591, oPC))) // Falchion
				return TRUE;
			
			return FALSE;
					
		case 200:	// Circle of Blades - Team Member Prerequisite
			while (GetIsObjectValid(oPartyMember))
			{
				/*	All other party members must meet this requirement.	*/
				if ((oPartyMember != oPC) && (GetIsRosterMember(oPartyMember) || GetIsOwnedByPlayer(oPartyMember)))
				{
					if (!GetHasFeat(FEAT_SNEAK_ATTACK, oPartyMember)
						&& !GetHasFeat(FEAT_BLACKGUARD_SNEAK_ATTACK_1D6, oPartyMember)
						&& !GetHasFeat(FEAT_WEAPON_FINESSE, oPartyMember))
						return TRUE;
				}
				oPartyMember	= GetNextFactionMember(oPC, FALSE);
			}
			return FALSE;
					
		break;
	}
	
	return FALSE;
}