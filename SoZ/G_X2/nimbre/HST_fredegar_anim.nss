/*
	as_an_pig_01
	as_an_pig_02
	as_an_pig_03
	as_an_pig_04
*/


#include "nw_i0_spells"
#include "nw_i0_generic"




int HSTGetDistanceToPlayerSmallerThan ( object oCreature, float fDistance )
{
	object oPlayer = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_CONTROLLED, oCreature);
	
	if (GetDistanceBetween(oCreature, oPlayer) < fDistance)
		return TRUE;
	
	return FALSE;
}




void HSTPlayPigSound ()
{
	if (HSTGetDistanceToPlayerSmallerThan(OBJECT_SELF, 13.0f))
		PlaySound("as_an_pig_0" + IntToString(d4()));
}




void HSTAnimFredegar ( object oPig )
{
	if (!GetIsObjectValid(oPig))
		return;
		
	//SendMessageToPC(GetFirstPC(), "delaycommand() running on object " + GetName(OBJECT_SELF));
	
	if (GetLocalInt(GetModule(), "g_bMoundSearched"))
	{
		//SendMessageToPC(GetFirstPC(), "aaaaaaaaaaaaaaaaaaaaaaaaaaaand cut");
		SpeakString("* squeak *");
		SetBumpState(oPig, BUMPSTATE_DEFAULT);
		SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS); 
		return;
	}
	
	if (!IsInConversation(oPig) && !GetIsInCombat(oPig))
	{
		PlayAnimation(ANIMATION_FIREFORGET_TAUNT);
		DelayCommand(GetRandomDelay(0.0f, 2.0f), HSTPlayPigSound());
	}
	
	DelayCommand(GetRandomDelay(3.0f, 7.0f), HSTAnimFredegar(oPig));
}




void main ()
{
	object oPig = OBJECT_SELF;
	
	//SendMessageToPC(GetFirstPC(), "running on object " + GetName(oPig));
	
	DelayCommand(12.0f, HSTAnimFredegar(oPig));
}