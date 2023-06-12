// ga_effect_polymorph(string sTarget, int nPolymorphSelection, int nLocked, string sDurationType, float fTemporaryDuration, string sFlags)
/*
	Does a polymorph effect on the specified target.  
	Params:
		string sTarget - Uses the standard GetTarget() function, default is the PC Speaker (or OBJECT_SELF from Command Console)
		int nPolymorphSelection - row number from polymorph.2da
    	int nLocked - If 1 (TRUE), player can't cancel polymorph 
		string sDurationType - I - Instant (default), P - Permanent, or T - Temporary w/ specified duration
		float fTemporaryDuration - applies only if duration is Temporary.
		string sFlags - Reserved for future use.  Currently does nothing.
*/
// ChazM 4/16/07

#include "ginc_param_const"

string GetStandardTargetDefualt()
{
    object oPC = GetPCSpeaker();
    string sTargetDefault;
    if (oPC == OBJECT_INVALID)
    {   // script is not being run from a conversation with a PC speaker so assume it is from a console command.
        sTargetDefault = "$OBJECT_SELF";
    }
    else
    {	// script run from convo, so default to PC
        sTargetDefault = "$PC";
    }
	return (sTargetDefault);	
}

void main(string sTarget, int nPolymorphSelection, int nLocked, string sDurationType, float fTemporaryDuration)
{
	object oTarget = GetTarget(sTarget, GetStandardTargetDefualt());	
	int nDurationType = GetDurationType(sDurationType);
    effect ePoly = EffectPolymorph(nPolymorphSelection, nLocked);
    ApplyEffectToObject(nDurationType, ePoly, oTarget, fTemporaryDuration);

	PrintString ("Applied polymorph effect to " + GetName(oTarget) + " with Duration " + IntToString(nDurationType) + " " + FloatToString(fTemporaryDuration));
}