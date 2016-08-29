// i_x2_nash_boot_ue
// by Brendan Bellina
// Dec 2009

// Created for use in the OC Makeover SoZ Edition

// Unequip script for Nasher's Nimble Boots

#include "ginc_bb_nasherset"

void main()
{
    // * This code runs when the item is unequipped
    object oPC      = GetPCItemLastUnequippedBy();
    object oItem    = GetPCItemLastUnequipped();
	
	// Reset this item to standard properties
	SetNasherBootsStandard( oItem );
		
	// Reset any other equipped Nasher items to standard properties		
	object oCloak = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
	SetNasherCloakStandard( oCloak );

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