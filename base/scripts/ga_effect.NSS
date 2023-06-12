// ga_effect
/*
	Does an effect on the specified target.  This function takes 5 params:
		string sEffect - one of the below effects
		string sParams - comma delimited list of needed params
		string sDuration - I - Instant (default), P - Permanent, or T,<duration> - Temporary w/ specified duration
						ex: temporay 30 seconds would be "T,30.0f"
		int iVisualEffect - -1=no visual, 0 = standard visual, or supply your own from visualeffects.2da (will be applied as an instant)
		string sTarget - Uses the standard GetTarget() function - default is the PC Speaker
		
	*** Effects and Paramaters ***
	AbilityIncrease	- nAbility , nModifyBy  	-- Abilities: Str=0, Dex=1, Con=2, Int=3, Wis=4, Cha=5
	AbilityDecrease	- nAbility, nModifyBy
	Blindness 	- no params
	Damage		- nDamageAmount, nDamageType, nDamagePower 	-- Types: Bludgeon=1, acid=16, fire=256, etc.; Powers: Normal=0, PlusThree=3, etc.
	Death		- no params
	Disease 	- nDiseaseType			-- (0-16) see DISEASE_* constants in nwscript.nss 
	Heal		- nDamageToHeal
	Paralyze 	- no params
	Poison		- nPoisonType 			-- (0-43) see POISON_* constants in nwscript.nss 
	Raise 		- no params
	Visual 		- nVisualEffectId 		-- see visualeffects.2da for param options
		
	Example 1:
	This action script will heal the PC Speaker 100hp in a conversation
	ga_effect ("Heal", "100", "", 0, "") 
			
	Example 2:
	This action script will permanently give the PC Speaker in a conversation increased strength (+2)
	ga_effect ("AbilityIncrease", "0,2", "P", 0, "") 
    
    To use this script from the console command, the sParams parameter must use " " instead of commas.
    So to run the previous example from the console would be:
	rs ga_effect ("AbilityIncrease", "0 2", "P", 0, "") 
	
*/
// ChazM 4/11/05
// ChazM 11/6/06 - fixed params to be 0 based instead of 1 based (Bug found by robertharris).  
//				Added a few more effects, added support for linked duration visual effects, edited description.
// ChazM 11/6/06 fixed some visual effects, other minor changes.
// ChazM 2/14/07 added support for using function from console. 

#include "ginc_param_const"


void DoEffect(string sEffect, string sParams, string sDuration, int iVisualEffect, object oTarget, string sDelim=",");


void main(string sEffect, string sParams, string sDuration, int iVisualEffect, string sTarget)
{
    object oPC = GetPCSpeaker();
    string sTargetDefault;
    string sDelim;
    if (oPC == OBJECT_INVALID)
    {   // script is not being run from a conversation with a PC speaker so assume it is from a console command.
        sTargetDefault = "$OBJECT_SELF";
        sDelim = " ";   // runscripts can't use commas inside strings...
    }
    else
    {
        sTargetDefault = "$PC";
        sDelim = ",";
    }
	object oTarget = GetTarget(sTarget, sTargetDefault);	
	DoEffect(sEffect, sParams, sDuration, iVisualEffect, oTarget, sDelim);
}


void DoEffect(string sEffect, string sParams, string sDuration, int iVisualEffect, object oTarget, string sDelim=",")
{
	int iDurationType = GetDurationType(GetStringParam(sDuration, 0));
	float fDuration = 0.0f;
	if (iDurationType == DURATION_TYPE_TEMPORARY)
		fDuration = GetFloatParam(sDuration, 1);
	
	sEffect			= GetStringLowerCase(sEffect);
	effect eEffect;
	int iVis 		= 0;
	int iVisType	= DURATION_TYPE_INSTANT;
	
	
	if(sEffect == "abilitydecrease"){
	    eEffect = EffectAbilityDecrease(GetIntParam(sParams, 0, sDelim), GetIntParam(sParams, 1, sDelim));
		iVis = VFX_IMP_REDUCE_ABILITY_SCORE;
	} else		
	if(sEffect == "abilityincrease"){
	    eEffect = EffectAbilityIncrease(GetIntParam(sParams, 0, sDelim), GetIntParam(sParams, 1, sDelim));
		iVis = VFX_IMP_IMPROVE_ABILITY_SCORE;
	} else		
	if(sEffect == "blindness"){
	    eEffect = EffectBlindness();
		iVis = VFX_IMP_BLIND_DEAF_M	;
	} else		
	if(sEffect == "damage"){
	    eEffect = EffectDamage(GetIntParam(sParams, 0, sDelim), GetIntParam(sParams, 1, sDelim), GetIntParam(sParams, 2, sDelim));
		// iVis should be based on type
		iVis = VFX_IMP_FLAME_M;
	} else		
	if(sEffect == "death"){
	    eEffect = EffectDeath();
		iVis = VFX_IMP_DISEASE_S;
	} else		
	if(sEffect == "disease"){
		eEffect = EffectDisease(GetIntParam(sParams, 0, sDelim));
		iVis = 	VFX_IMP_DEATH;
	} else
	if(sEffect == "haste"){
		eEffect = EffectHaste();
		iVis	= VFX_IMP_HASTE;
	} else
	if(sEffect == "heal"){
		eEffect = EffectHeal(GetIntParam(sParams, 0, sDelim));
		iVis = VFX_IMP_HEALING_G;
	} else
	if(sEffect == "paralyze"){
		eEffect = EffectParalyze();
		iVisType = DURATION_TYPE_TEMPORARY;
		iVis = VFX_DUR_PARALYZED;
	} else
	if(sEffect == "poison"){
		eEffect = EffectPoison(GetIntParam(sParams, 0, sDelim));
		iVis = VFX_IMP_POISON_L;
	} else
	if((sEffect == "resurrection") || (sEffect == "raise")){
		eEffect = EffectResurrection();
		iVis = VFX_IMP_HEALING_G;
	} else
	if(sEffect == "visual"){
		eEffect = EffectVisualEffect(GetIntParam(sParams, 0, sDelim));
	} else
	{
		PrintString ("effect not defined: " + sEffect);
		return;
	}
	
	if (iVisualEffect >= 0)
	{	
		if (iVisualEffect == 0)
		 	iVisualEffect = iVis;
		effect eVis = EffectVisualEffect(iVisualEffect);
    	// Apply the visual effect to the target
		if (iVisType == DURATION_TYPE_INSTANT)
		{
    		ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
		}			
		else if (iVisType == DURATION_TYPE_TEMPORARY)
		{
			// link temporary visual effects to the actual effect.
	    	eEffect = EffectLinkEffects(eEffect, eVis);
		}			
	}
					
    ApplyEffectToObject(iDurationType, eEffect, oTarget, fDuration);
	PrintString ("Applied " + sEffect + " effect to " + GetName(oTarget) + " with Duration " + IntToString(iDurationType) + " " + FloatToString(fDuration));
}