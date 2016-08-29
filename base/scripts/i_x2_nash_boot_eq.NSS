// i_x2_nash_boot_eq
// by Brendan Bellina
// Dec 2009

// Created for use in the OC Makeover SoZ Edition

// Equip script for Nasher's Nimble Boots

#include "ginc_bb_nasherset"

void main()
{
    // * This code runs when the item is equipped
    object oPC      = GetPCItemLastEquippedBy();
    object oItem    = GetPCItemLastEquipped();
	
	// If all other Nasher items are equipped then apply enhancements
	if (
		TRUE
	//	&& GetResRef(GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC)) == "x2_nash_boot"
		&& GetResRef(GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC)) == "x2_nash_cloak"
		&& GetResRef(GetItemInSlot(INVENTORY_SLOT_ARMS, oPC)) == "x2_nash_glove"
		&& (
		    GetResRef(GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC)) == "x2_nash_ring"
		    || GetResRef(GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC)) == "x2_nash_ring"
		   )
	    )		
	{	
		// Add Enhancements to this item
		SetNasherBootsEnhanced( oItem );
		
		// Add Enhancements to other items		
		object oCloak = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
		SetNasherCloakEnhanced( oCloak );

		object oGloves = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
		SetNasherGlovesEnhanced( oGloves );

		if (GetResRef(GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC)) == "x2_nash_ring")
		{
			object oRing = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC);
			SetNasherRingEnhanced( oRing );
		}
		else
		{
			object oRing = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC);
			SetNasherRingEnhanced( oRing );		
		}
	}	
}