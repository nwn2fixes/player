// gc_bb_has_feat_specitem(int nFeat, string sGlobalVarName)
// by B. Bellina, July 2008
// Required for the special items: Dagger of Chaos and Rod of Lordly Might

// based on gc_has_feat
// this script determines the special item actor by checking a global
// variable and tests feats against the actor.
// Also checks only for the feat, ignoring the number of uses of the feat left

/*
    This checks if the creature or player has a given feat
	 nFeat		= The number of the feat. See nwscript.nss for a list of feats.
*/

#include "ginc_misc"
#include "ginc_debug"
	
int StartingConditional(int nFeat, string sGlobalVarName)
{
	int bIgnoreUses = 1;
	string sActor = GetGlobalString(sGlobalVarName);
	object oTarget = GetTarget(sActor);
	if (!GetIsObjectValid(oTarget))
		oTarget =(GetPCSpeaker()==OBJECT_INVALID?OBJECT_SELF:GetPCSpeaker());
	
	if ( GetHasFeat(nFeat, oTarget, bIgnoreUses) )
	{
		return TRUE;
	}

	return FALSE;
}