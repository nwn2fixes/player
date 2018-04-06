//	m_c_teamwork
/*
	Condition script to check if the party is qualified for a particular
	Teamwork Feat.
*/
//	JSH-OEI 7/24/08
// kevL 2018 apr 6 - case TW_CIRCLE_OF_BLADES was falling through to TW_SUPERIOR_FLANK
//                   which meant that to train Circle of Blades, you could *not* have
//                   Superior Flank yet. They should be trainable independently.

const int TW_FEARSOME_ROSTER		= 10;
const int TW_IMP_FEARSOME_ROSTER	= 20;
const int TW_TEAM_RUSH				= 30;
const int TW_FOE_HUNTING			= 40;
const int TW_GROUP_TRANCE			= 50;
const int TW_MISSILE_VOLLEY			= 60;
const int TW_CAMP_ROUTINE			= 70;
const int TW_IMP_CAMP_ROUTINE		= 80;
const int TW_STEADFAST_RESOLVE		= 90;
const int TW_AWARENESS				= 100;
const int TW_CIRCLE_OF_BLADES		= 110;
const int TW_SUPERIOR_FLANK			= 120;

int StartingConditional(int nCase)
{
	object oPC	= GetPCSpeaker();

	switch(nCase)
	{
		case TW_FEARSOME_ROSTER:
			if (!GetHasFeat(FEAT_TW_FEARSOME_ROSTER, oPC))
				return TRUE;
			break;
		case TW_IMP_FEARSOME_ROSTER:
			if (!GetHasFeat(FEAT_TW_IMPROVED_FEARSOME_ROSTER, oPC))
				return TRUE;
			break;
		case TW_TEAM_RUSH	:
			if (!GetHasFeat(FEAT_TW_TEAM_RUSH, oPC))
				return TRUE;
			break;
		case TW_FOE_HUNTING:
			if (!GetHasFeat(FEAT_TW_FOE_HUNTING, oPC))
				return TRUE;
			break;
		case TW_GROUP_TRANCE:
			if (!GetHasFeat(FEAT_TW_GROUP_TRANCE, oPC))
				return TRUE;
			break;
		case TW_MISSILE_VOLLEY	:
			if (!GetHasFeat(FEAT_TW_MISSILE_VOLLEYS, oPC))
				return TRUE;
			break;
		case TW_CAMP_ROUTINE:
			if (!GetHasFeat(FEAT_TW_CAMP_ROUTINE, oPC))
				return TRUE;
			break;
		case TW_IMP_CAMP_ROUTINE:
			if (!GetHasFeat(FEAT_TW_IMPROVED_CAMP_ROUTINE, oPC))
				return TRUE;
			break;
		case TW_STEADFAST_RESOLVE:
			if (!GetHasFeat(FEAT_TW_STEADFAST_RESOLVE, oPC))
				return TRUE;
			break;
		case TW_AWARENESS:
			if (!GetHasFeat(FEAT_TW_AWARENESS, oPC))
				return TRUE;
			break;
		case TW_CIRCLE_OF_BLADES:
			if (!GetHasFeat(FEAT_TW_CIRCLE_OF_BLADES, oPC))
				return TRUE;
			break; // kL_fixed.
		case TW_SUPERIOR_FLANK:
			if (!GetHasFeat(FEAT_TW_SUPERIOR_FLANK, oPC))
				return TRUE;
		default:
			break;
	}

	return FALSE;
}