// UnEquip Script for Staff of Balpheron "n2_wmgst001"
// Adds Casting Abilities
// CGaw OEI 7/13/06

void AddItemProperties(object oItem)
{
	itemproperty ipDispel = ItemPropertyCastSpell(IP_CONST_CASTSPELL_DISPEL_MAGIC_10, 
		IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE);
	itemproperty ipImpInv = ItemPropertyCastSpell(IP_CONST_CASTSPELL_IMPROVED_INVISIBILITY_7, 
		IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE);
	itemproperty ipAResist = ItemPropertyCastSpell(IP_CONST_CASTSPELL_ASSAY_RESISTANCE_7, 
		IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE);
	itemproperty ipLSMantle = ItemPropertyCastSpell(IP_CONST_CASTSPELL_LESSER_SPELL_MANTLE_9, 
		IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE);
	itemproperty ipDBFire = ItemPropertyCastSpell(IP_CONST_CASTSPELL_DELAYED_BLAST_FIREBALL_15, 
		IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE);
	itemproperty ipChLight = ItemPropertyCastSpell(IP_CONST_CASTSPELL_CHAIN_LIGHTNING_15, 
		IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE);
	itemproperty ipWFire = ItemPropertyCastSpell(IP_CONST_CASTSPELL_WALL_OF_FIRE_9, 
		IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE);
	itemproperty ipILMStrm = ItemPropertyCastSpell(IP_CONST_CASTSPELL_ISAACS_LESSER_MISSILE_STORM_13, 
		IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE);
	itemproperty ipMMiss = ItemPropertyCastSpell(IP_CONST_CASTSPELL_MAGIC_MISSILE_9, 
		IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE);
	itemproperty ipIMArm = ItemPropertyCastSpell(IP_CONST_CASTSPELL_IMPROVED_MAGE_ARMOR_10, 
		IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE);
	itemproperty ipPfE = ItemPropertyCastSpell(IP_CONST_CASTSPELL_PROTECTION_FROM_EVIL_1, 
		IP_CONST_CASTSPELL_NUMUSES_1_CHARGE_PER_USE);
	itemproperty ipGoInv = ItemPropertyCastSpell(IP_CONST_CASTSPELL_GLOBE_OF_INVULNERABILITY_11, 
		IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE);
	itemproperty ipCoCold = ItemPropertyCastSpell(IP_CONST_CASTSPELL_CONE_OF_COLD_15, 
		IP_CONST_CASTSPELL_NUMUSES_4_CHARGES_PER_USE);
	itemproperty ipLightBolt = ItemPropertyCastSpell(IP_CONST_CASTSPELL_LIGHTNING_BOLT_10, 
		IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE);
	itemproperty ipScinSphere = ItemPropertyCastSpell(IP_CONST_CASTSPELL_SCINTILLATING_SPHERE_5, 
		IP_CONST_CASTSPELL_NUMUSES_2_CHARGES_PER_USE);
	itemproperty ipLMBlank = ItemPropertyCastSpell(IP_CONST_CASTSPELL_LESSER_MIND_BLANK_9, 
		IP_CONST_CASTSPELL_NUMUSES_3_CHARGES_PER_USE);
	itemproperty ipGStoneskin = ItemPropertyCastSpell(IP_CONST_CASTSPELL_GREATER_STONESKIN_11, 
		IP_CONST_CASTSPELL_NUMUSES_5_CHARGES_PER_USE);
			
	AddItemProperty(DURATION_TYPE_PERMANENT, ipDispel, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipImpInv, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipAResist, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipLSMantle, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipDBFire, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipChLight, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipWFire, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipILMStrm, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipMMiss, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipIMArm, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipPfE, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipGoInv, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipCoCold, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipLightBolt, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipScinSphere, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipLMBlank, oItem);
	AddItemProperty(DURATION_TYPE_PERMANENT, ipGStoneskin, oItem);
}

void main()
{
    // * This code runs when the item is equipped
    object oItem    = GetPCItemLastEquipped();
	if (GetLocalInt(oItem, "EQUIPPED") == TRUE) return;
	SetLocalInt(oItem, "EQUIPPED", TRUE);
	AddItemProperties(oItem);
}