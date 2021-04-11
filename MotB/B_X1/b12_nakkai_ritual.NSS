//	b12_nakkai_ritual
//
//	This script is used to have Nak'kai perform the ritual then trigger his ending conversation.
//		bHelpPlayer - Parm used to determine whether Nak'kai is enhancing Okku (1) or himself (0).
//
//	OMP-OEI 6/14/07 - Created groundwork to trigger conversation after ritual and set parms where necessary.
//	OMP-OEI 6/24/07 - Added code for ritual effects when Nak'kai enhances himself. Much remains to be done with VFX.
//						Set bRitualDone variable on Nak'kai so that he doesn't repeat himself in his conversation.
//	OMP-OEI 7/1/07	- Added the EnhancePet function to replace the claws and bite of pets.
// MDiekmann 9/11/07 - Modified to set global variable and call Okku level up event on upgrade
// kevL 21 apr 10 - fix Okku not getting xp for level

#include "kinc_spirit_eater"


void EnhancePet( object oPet );


void main( int bHelpPlayer )
{
	object oPC = GetSpiritEater();
	object oNakkai = GetObjectByTag( "b12_nakkai" );


	if ( bHelpPlayer )	// Okku will be enhanced
	{
		object oOkku = GetObjectByTag( "okku" );

		SetLocalInt( oNakkai, "bHelpPlayer", 1 );

		SetGlobalInt("bOkkuUpgraded", TRUE);

		// levelup Okku fix
		int iLevel = GetHitDice(oOkku) + 1;
		if (iLevel <= 30)
		{
			int iXp = (iLevel * (iLevel - 1) / 2) * 1000;
			SetXP(oOkku, iXp);
		}
		// end levelup Okku fix

		SignalEvent(oOkku, EventUserDefined(2053));

		AssignCommand( oNakkai, ActionCastFakeSpellAtObject( SPELL_WORD_OF_FAITH, oOkku, PROJECTILE_PATH_TYPE_DEFAULT ) );
	}
	else	// Nak'kai will enhance himself
	{
		object oOneOfMany = GetObjectByTag( "oneofmany" );
		object oPet1 = GetObjectByTag( "b12_nakkai_pet_1" );
		object oPet2 = GetObjectByTag( "b12_nakkai_pet_2" );
		effect eGrowNakkai = EffectSetScale( 1.5, 1.5, 1.5 );
		effect eGrowPets = EffectSetScale( 2.0, 2.0, 2.0 );
//		effect eLink;

		AssignCommand( oNakkai, ActionCastFakeSpellAtObject( SPELL_WORD_OF_FAITH, oOneOfMany, PROJECTILE_PATH_TYPE_DEFAULT ) );

		DelayCommand( 1.0, ApplyEffectToObject( DURATION_TYPE_PERMANENT, eGrowNakkai, oNakkai ) );
		DelayCommand( 1.0, ApplyEffectToObject( DURATION_TYPE_PERMANENT, eGrowPets, oPet1 ) );
		DelayCommand( 1.0, ApplyEffectToObject( DURATION_TYPE_PERMANENT, eGrowPets, oPet2 ) );

		EnhancePet( oPet1 );
		EnhancePet( oPet2 );
	}

	SetLocalInt( oNakkai, "bRitualDone", 1 );

	AssignCommand( oNakkai, ActionStartConversation( oPC, "b12_nakkai_ritual_done", FALSE , FALSE, TRUE, FALSE ) );
}


void EnhancePet( object oPet )
{
	object oClaw1 = CreateItemOnObject( "nx1_claw_nakkai_pet", oPet );
	object oClaw2 = CreateItemOnObject( "nx1_claw_nakkai_pet", oPet );
	object oBite = CreateItemOnObject( "nx1_bite_nakkai_pet", oPet );
	object oHide = CreateItemOnObject( "nx1_hide_nakkai_pet", oPet );


	DestroyObject( GetItemInSlot( INVENTORY_SLOT_CWEAPON_L, oPet ) );
	DestroyObject( GetItemInSlot( INVENTORY_SLOT_CWEAPON_R, oPet ) );
	DestroyObject( GetItemInSlot( INVENTORY_SLOT_CWEAPON_B, oPet ) );
	DestroyObject( GetItemInSlot( INVENTORY_SLOT_CARMOUR, oPet ) );

	SetIdentified( oClaw1, TRUE );
	SetIdentified( oClaw2, TRUE );
	SetIdentified( oBite, TRUE );
	SetIdentified( oHide, TRUE );

	AssignCommand( oPet, ActionEquipItem( oClaw1, INVENTORY_SLOT_CWEAPON_L ) );
	AssignCommand( oPet, ActionEquipItem( oClaw2, INVENTORY_SLOT_CWEAPON_R ) );
	AssignCommand( oPet, ActionEquipItem( oBite, INVENTORY_SLOT_CWEAPON_B ) );
	AssignCommand( oPet, ActionEquipItem( oHide, INVENTORY_SLOT_CARMOUR ) );
}
