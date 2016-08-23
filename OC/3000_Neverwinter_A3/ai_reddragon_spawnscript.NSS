/////////////////////////////////////////
// Custom SpawnScript for Dragons
//
// Written By: Constant Gaw - OEI 8/11/06
/////////////////////////////////////////
// kevL's - 2016 aug 22 - Change string-var "Sweet_Counter_Req" to
// "Sweep_Counter_Req" to conform with usage in 'ai_dragon_userdef'.

#include "ginc_misc"
#include "ginc_ai"
#include "x0_i0_anims"

//Functions

void CustomAISpellQueueEnqueue(object oSpellCaster, int nSpell, string sTarget,
	int bCheat = FALSE, int bInstantCast = FALSE);

void main()
{
	SetLocalInt(OBJECT_SELF, "N2_TALENT_EXCLUDE", 7);

	SetLocalInt(OBJECT_SELF, "Breath_Counter", 0);
	SetLocalInt(OBJECT_SELF, "Breath_Counter_Req", d2() + 2);

	SetLocalInt(OBJECT_SELF, "Buffet_Counter", 0);
	SetLocalInt(OBJECT_SELF, "Buffet_Counter_Req", d3() + 3);

	SetLocalInt(OBJECT_SELF, "Sweep_Counter", 0);
	SetLocalInt(OBJECT_SELF, "Sweep_Counter_Req", d2() + 2); // kL

	SetLocalInt(OBJECT_SELF, "CanBuffet", 1);
	SetLocalInt(OBJECT_SELF, "CanBreath", 1);
	SetLocalInt(OBJECT_SELF, "CanSweep", 1);
	
    SetSpawnInCondition(NW_FLAG_END_COMBAT_ROUND_EVENT);
	
    SetSpawnInCondition(NW_FLAG_HEARTBEAT_EVENT);
	
	SetCombatOverrides(OBJECT_SELF, OBJECT_INVALID, -1, -1, OVERRIDE_ATTACK_RESULT_DEFAULT,
		 -1, -1, TRUE, FALSE, FALSE, FALSE);

	//---//////////////HEY!!! LOOK AT ME!!!!! Adjust these how you like.

//	CustomAISpellQueueEnqueue(OBJECT_SELF, SPELL_SPELL_RESISTANCE, "$SELF", FALSE, TRUE);		//cast first..

//	CustomAISpellQueueEnqueue(OBJECT_SELF, SPELL_DISPLACEMENT, "$SELF", FALSE, TRUE);		//cast second..

//	CustomAISpellQueueEnqueue(OBJECT_SELF, SPELL_ELEMENTAL_SHIELD, "$SELF", FALSE, TRUE);		//cast next..

																					//and so on..
	//---------*NOTES*-----------

	//The first parameter is the spell queue caster, the second is the spell to cast (see SPELL_* const list)
		//and the third parameter is the target to cast the spell at.

	//The third parameter can be a tag of a target, or it can be "$PC", "$SELF", "$FRIEND", or "$ENEMY"
		//"$PC" = nearest PC
		//"$FRIEND" = nearest alive friend
		//"$ENEMY" = nearest person who is hostile to me
		//"$SELD" = myself

	//There can be any number of calls to AISpellQueueEnqueue()
	
	AIAssignDCR(OBJECT_SELF, "ai_reddragon_roundend");

}

void CustomAISpellQueueEnqueue(object oSpellCaster, int nSpell, string sTarget, int bCheat = FALSE, int bInstantCast = FALSE)
{
	int nWhichEntry=GetLocalInt(oSpellCaster,sSPELL_QUEUE_NUM_CAST);//Which spell am I on?
	int index=nWhichEntry+1;
	while (GetLocalString(oSpellCaster,sSPELL_QUEUE_TARGET_ENTRY+IntToString(index))!="")//find next index
		index+=1;

	SetLocalInt(oSpellCaster,sSPELL_QUEUE_ENTRY+IntToString(index),nSpell);
	SetLocalString(oSpellCaster,sSPELL_QUEUE_TARGET_ENTRY+IntToString(index),sTarget);
	SetLocalInt(oSpellCaster,sSPELL_QUEUE_ENTRY_CHEAT+IntToString(index),bCheat);
	SetLocalInt(oSpellCaster,sSPELL_QUEUE_ENTRY_INSTANTCAST+IntToString(index),bInstantCast);

	if (index==1)//this is the first time I've been enqueued. Make sure I have the AI setup.
		SetCreatureOverrideAIScript(oSpellCaster,sSPELL_QUEUE_DCR_SCRIPT);
}