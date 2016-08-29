// ginc_bb_nasherset
// by Brendan Bellina, Dec 2009

// Include file for equip and unequip scripts for Nasher item set

#include "x2_inc_itemprop"

void SetNasherBootsStandard( object oItem )
{	
	// Set Nasher's Boots to standard properties
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_boot")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
		
		// Standard Boots Properties
		itemproperty ipDexBonus = ItemPropertyAbilityBonus(IP_CONST_ABILITY_DEX, 3);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipDexBonus, oItem);
	}
}

void SetNasherBootsEnhanced( object oItem )
{	
	// Add Enhancements to Nasher's Boots
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_boot")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
		
		// Enhanced Boots Properties
		itemproperty ipDexBonus = ItemPropertyAbilityBonus(IP_CONST_ABILITY_DEX, 7);
		itemproperty ipFreeAction = ItemPropertyFreeAction();
		itemproperty ipDodgeACBonus = ItemPropertyACBonus(5);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipDexBonus, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipFreeAction, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipDodgeACBonus, oItem);
	}
}

void SetNasherCloakStandard( object oItem )
{	
	// Set Nasher's Cloak to standard properties
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_cloak")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
		
		// Standard Cloak Properties
		itemproperty ipDefACBonus = ItemPropertyACBonus(3);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipDefACBonus, oItem);
	}
}

void SetNasherCloakEnhanced( object oItem )
{
	// Add Enhancements to Nasher's Cloak
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_cloak")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
		
		// Enhanced Cloak Properties
		itemproperty ipDefACBonus = ItemPropertyACBonus(7);
		itemproperty ipUnivSaveBonus = ItemPropertyBonusSavingThrowVsX(IP_CONST_SAVEVS_UNIVERSAL, 5);
		itemproperty ipChaBonus = ItemPropertyAbilityBonus(IP_CONST_ABILITY_CHA, 3);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipDefACBonus, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipUnivSaveBonus, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipChaBonus, oItem);
	}
}

void SetNasherGlovesStandard( object oItem )
{	
	// Set Nasher's Gloves to standard properties
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_glove")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
		
		// Standard Gloves Properties
		itemproperty ipParrySkillBonus = ItemPropertySkillBonus(SKILL_PARRY, 5);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipParrySkillBonus, oItem);
	}
}

void SetNasherGlovesEnhanced( object oItem )
{
	// Add Enhancements to Nasher's Gloves
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_glove")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
			
		// Enhanced Gloves Properties
		itemproperty ipParrySkillBonus = ItemPropertySkillBonus(SKILL_PARRY, 10);
		itemproperty ipBludgeonDamBonus = ItemPropertyDamageBonus( 
			IP_CONST_DAMAGETYPE_BLUDGEONING, IP_CONST_DAMAGEBONUS_1d8);
		itemproperty ipDazeHit = ItemPropertyOnHitProps(IP_CONST_ONHIT_DAZE, IP_CONST_ONHIT_SAVEDC_20, 
			IP_CONST_ONHIT_DURATION_10_PERCENT_2_ROUNDS);
		itemproperty ipAttBonus = ItemPropertyAttackBonus(5);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipParrySkillBonus, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipBludgeonDamBonus, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipDazeHit, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipAttBonus, oItem);
	}
}

void SetNasherRingStandard( object oItem )
{	
	// Set Nasher's Ring to standard properties
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_ring")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
		
		// Standard Ring Properties
		itemproperty ipStrBonus = ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, 3);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipStrBonus, oItem);
	}
}

void SetNasherRingEnhanced( object oItem )
{
	// Add Enhancements to Nasher's Ring
	if (GetIsObjectValid(oItem) && GetResRef(oItem) == "x2_nash_ring")
	{
		IPRemoveAllItemProperties(oItem, DURATION_TYPE_PERMANENT);
			
		// Enhanced Ring Properties
		itemproperty ipStrBonus = ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, 7);
		itemproperty ipSpellResist = ItemPropertyBonusSpellResistance(IP_CONST_SPELLRESISTANCEBONUS_10);

		AddItemProperty(DURATION_TYPE_PERMANENT, ipStrBonus, oItem);
		AddItemProperty(DURATION_TYPE_PERMANENT, ipSpellResist, oItem);
	}
}