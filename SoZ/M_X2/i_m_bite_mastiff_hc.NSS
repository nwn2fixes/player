//	i_m_bite_mastiff_hc
/*
	Trip attack for shadow mastiffs.
*/
//	JSH-OEI 5/20/08
// kevL 2018 apr 6 - no trip if game difficulty is *less* than or equal to Normal.

void main()
{
	object oItem  		= GetSpellCastItem();    // The item casting that triggered this spellscript
	object oSpellOrigin = OBJECT_SELF ;
	object oSpellTarget = GetSpellTargetObject();

	effect eTrip		= EffectKnockdown();
	effect eTripImmune	= EffectImmunity(IMMUNITY_TYPE_KNOCKDOWN);
	
	int nD20Self		= d20();
	int nD20Target		= d20();
	int nStrModSelf		= GetAbilityModifier(ABILITY_STRENGTH, OBJECT_SELF);
	int nStrModTarget	= GetAbilityModifier(ABILITY_STRENGTH, oSpellTarget);
	int nDexModTarget	= GetAbilityModifier(ABILITY_DEXTERITY, oSpellTarget);
	int nTargetMod;
	
	//	No trip attacks on Normal or less.
	if (GetGameDifficulty()<=GAME_DIFFICULTY_NORMAL) // kL_invert.
		return;
	
	if (nStrModTarget > nDexModTarget)
	{
		nTargetMod = nStrModTarget;
	}
	else
	{
		nTargetMod = nDexModTarget;
	}
	
	int nTripCheck		= nD20Self + nStrModSelf + 7;
	int nOpposeCheck	= nD20Target + nTargetMod;
	
	if (GetRacialType(oSpellTarget)==RACIAL_TYPE_DWARF)
	{
		nOpposeCheck	= nOpposeCheck + 4;
	}
	
	//SendMessageToPC(oSpellTarget, "Shadow Mastiff Trip Roll: " + IntToString(nTripCheck));
	//SendMessageToPC(oSpellTarget, "Oppose Roll: " + IntToString(nOpposeCheck));
	
	if ((nTripCheck > nOpposeCheck) && !GetIsImmune(oSpellTarget, IMMUNITY_TYPE_KNOCKDOWN))
	{
		//SendMessageToPC(oSpellTarget, GetFirstName(oSpellTarget) + " has been tripped by " + GetName(OBJECT_SELF) + "!");
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTrip, oSpellTarget, 3.f);
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTripImmune, oSpellTarget, 3.f);
	}
	
}