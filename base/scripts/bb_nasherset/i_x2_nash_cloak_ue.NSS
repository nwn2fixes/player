// i_x2_nash_cloak_ue
// by Brendan Bellina
// Dec 2009

// Created for use in the OC Makeover SoZ Edition

// Unequip script for Nasher's Cloak of Protection

#include "ginc_bb_nasherset"

void main()
{
    // * This code runs when the item is unequipped
    object oPC      = GetPCItemLastUnequippedBy();
    object oItem    = GetPCItemLastUnequipped();
	
	// Reset this item to standard properties
	SetNasherCloakStandard( oItem );
		
	// Reset any other equipped Nasher items to standard properties		
	object oBoots = GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC);
	SetNasherBootsStandard( oBoots );

	object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
	SetNasherGlovesStandard( oGloves );

	if (GetResRef(GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC)) == "x2_nash_ring")
	{
		object oRing = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC);
		SetNasherRingStandard( oRing );
	}
	
	if (GetResRef(GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC)) == "x2_nash_ring")
	{
		object oRing = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC);
		SetNasherRingStandard( oRing );		
	}
}