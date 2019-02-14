// i_x2_nash_ring_ue
// by Brendan Bellina
// Dec 2009

// Created for use in the OC Makeover SoZ Edition

// Unequip script for Nasher's Ring of Strength

#include "ginc_bb_nasherset"

void main()
{
    // * This code runs when the item is unequipped
    object oPC      = GetPCItemLastUnequippedBy();
    object oItem    = GetPCItemLastUnequipped();
	
	// Reset this item to standard properties
	SetNasherRingStandard( oItem );
		
	// Reset any other equipped Nasher items to standard properties		
	object oBoots = GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC);
	SetNasherBootsStandard( oBoots );

	object oCloak = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
	SetNasherCloakStandard( oCloak );

	object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
	SetNasherGlovesStandard( oGloves );
}