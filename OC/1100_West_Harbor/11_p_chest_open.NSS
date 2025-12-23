// 11_p_chest_open

// Spawns in appropriate equipment for the user, get some sort of starting package going here. (Happens for each PC)

// DBR 07/27/06

// Modified by BrionT 06/04/09

// Added support for a Swashbuckler, giving a rapier, a dagger, and throwing axes, - by Axe_Edge 12/08/2025

// kevL 2025 dec 20 - removed GetArcherySpec() always returned FALSE

const int ARROW_STACK = 50;
int GetHasSpellFeat(object oPC);
//int GetArcherySpec(object oPC);

void main()
{
	object oPC = GetLastOpenedBy();
	if (GetLocalInt(oPC,"STARTING CHEST POP")==1)
		return;
	if (GetTag(oPC)!="") //companions don't get free loot.
		return;
	SetLocalInt(oPC,"STARTING CHEST POP",1);

	object oContainer = OBJECT_SELF;

	int nClass = GetClassByPosition(1,oPC);
	if (nClass==CLASS_TYPE_BARBARIAN)//*********************************************************************************
	{
		if (GetRacialType(oPC)==RACIAL_TYPE_DWARF) //first priority -- dwarf gear
		{
			CreateItemOnObject("x2_wdwraxe001",oContainer);				//Dwarven Waraxe
			CreateItemOnObject("nw_ashsw001",oContainer);				//light shield
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl008",oContainer);				//hide armor
			return;
		}
		if (GetHasFeat(FEAT_WEAPON_FOCUS_GREAT_AXE,oPC)) //greataxe focus second
		{
			CreateItemOnObject("nw_waxgr001",oContainer);				//greataxe
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl008",oContainer);				//hide armor
			return;
		}
		if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oPC)) //dual-wielding next
		{
			CreateItemOnObject("nw_waxhn001",oContainer);				//handaxe
			CreateItemOnObject("nw_waxhn001",oContainer);				//handaxe
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl008",oContainer);				//hide armor
			return;
		}
		CreateItemOnObject("nw_waxbt001",oContainer);				//battleaxe
		CreateItemOnObject("nw_ashsw001",oContainer);				//light shield
		CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
		CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl008",oContainer);				//hide armor
		return;
	} else if (nClass==CLASS_TYPE_BARD)//*******************************************************************************
	{
		if (GetHasFeat(FEAT_WEAPON_FINESSE,oPC)) //weapon finesse
		{
			CreateItemOnObject("nw_wswss001",oContainer);				//shortsword
			CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
			CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
			CreateItemOnObject("n2_it_drum",oContainer);				//drum
			return;
		}
		if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oPC)) //dual-wielding next
		{
			CreateItemOnObject("nw_wswss001",oContainer);				//shortsword
			CreateItemOnObject("nw_wswdg001",oContainer);				//dagger
			CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
			CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
			CreateItemOnObject("n2_it_lute",oContainer);				//lute
			return;
		}
		CreateItemOnObject("nw_wswls001",oContainer);				//longsword
		CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
		CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
		CreateItemOnObject("n2_it_flute",oContainer);				//flute
		return;
	} else if (nClass==CLASS_TYPE_CLERIC || nClass==CLASS_TYPE_FAVORED_SOUL)//******************************************
	{
		/*if (GetHasFeat(FEAT_WEAPON_FOCUS_WAR_MACE,oPC)) //warmace focus second
		{
			CreateItemOnObject("nw_wdbma001",oContainer);		//warmace
			CreateItemOnObject("nw_wbwx001",oContainer);		//light crossbow
			CreateItemOnObject("nw_wambo001",oContainer);		//bolts
			CreateItemOnObject("nw_it_mpotion001",oContainer);	//potion of cure light wounds
			CreateItemOnObject("nw_aarcl004",oContainer);		//chainmail
			return;
		}*/
		if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oPC)) //dual-wielding next
		{
			CreateItemOnObject("nw_wblml001",oContainer);				//mace
			CreateItemOnObject("nw_wblml001",oContainer);				//mace
			CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
			CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl004",oContainer);				//chainmail
			return;
		}
		CreateItemOnObject("nw_wblml001",oContainer);				//mace
		CreateItemOnObject("nw_ashlw001",oContainer);				//heavy shield
		CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
		CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl004",oContainer);				//chainmail
		return;
	} else if (nClass==CLASS_TYPE_DRUID)//******************************************************************************
	{
		if (GetHasSpellFeat(oPC)) //Spell Feat: Any
		{
			CreateItemOnObject("nw_wdbqs001",oContainer);				//quarterstaff
			CreateItemOnObject("nw_wbwsl001",oContainer);				//sling
			CreateItemOnObject("nw_wambu001",oContainer, ARROW_STACK);	//bullets
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
			return;
		}
		if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oPC)) //dual-wielding next
		{
			CreateItemOnObject("nw_wswsc001",oContainer);				//scimitar
			CreateItemOnObject("nw_blcl001",oContainer);				//club
			CreateItemOnObject("nw_wbwsl001",oContainer);				//sling
			CreateItemOnObject("nw_wambu001",oContainer, ARROW_STACK);	//bullets
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
			return;
		}
		CreateItemOnObject("nw_wswsc001",oContainer);				//scimitar
		CreateItemOnObject("nw_ashsw001",oContainer);				//light shield
		CreateItemOnObject("nw_wbwsl001",oContainer);				//sling
		CreateItemOnObject("nw_wambu001",oContainer, ARROW_STACK);	//bullets
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
		return;
	} else if (nClass==CLASS_TYPE_FIGHTER)//****************************************************************************
	{
		if (GetRacialType(oPC)==RACIAL_TYPE_DWARF) //first priority -- dwarf gear
		{
			CreateItemOnObject("x2_wdwraxe001",oContainer);				//dwarven waraxe
			CreateItemOnObject("nw_ashsw001",oContainer);				//light shield
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl003",oContainer);				//scale mail
			return;
		}
		if (GetHasFeat(FEAT_WEAPON_FINESSE,oPC)) //weapon finesse
		{
			CreateItemOnObject("nw_wswss001",oContainer);				//short sword
			CreateItemOnObject("nw_ashsw001",oContainer);				//light shield
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl003",oContainer);				//scale mail
			return;
		}
		if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oPC)) //dual-wielding next
		{
			CreateItemOnObject("nw_wswss001",oContainer);				//short sword
			CreateItemOnObject("nw_wswss001",oContainer);				//short sword
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl003",oContainer);				//scale mail
			return;
		}
		CreateItemOnObject("nw_wswgs001",oContainer);				//greatsword
		CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
		CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl003",oContainer);				//scale mail
		return;
	} else if (nClass==CLASS_TYPE_MONK)//*******************************************************************************
	{
		CreateItemOnObject("nw_wbwsl001",oContainer);				//sling
		CreateItemOnObject("nw_wambu001",oContainer, ARROW_STACK);	//bullets
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		return;
	} else if (nClass==CLASS_TYPE_PALADIN)//****************************************************************************
	{
		if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oPC)) //dual-wielding next
		{
			CreateItemOnObject("nw_wblml001",oContainer);				//mace
			CreateItemOnObject("nw_wblml001",oContainer);				//mace
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl004",oContainer);				//chainmail
			return;
		}
		CreateItemOnObject("nw_wblfl001",oContainer);				//light flail
		CreateItemOnObject("nw_ashsw001",oContainer);				//light shield
		CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
		CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl004",oContainer);				//chainmail
		return;
	} else if (nClass==CLASS_TYPE_RANGER)//*****************************************************************************
	{
/*		if (GetArcherySpec(oPC)) //Archery Spec'ed
		{
			CreateItemOnObject("nw_wswls001",oContainer);				//longsword
			CreateItemOnObject("nw_wswdg001",oContainer);				//dagger
			CreateItemOnObject("nw_wbwln001",oContainer);				//longbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl002",oContainer);				//studded leather armor
			return;
		} */
		if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING,oPC)) //dual-wielding next
		{
			CreateItemOnObject("nw_wswls001",oContainer);				//longsword
			CreateItemOnObject("nw_wswss001",oContainer);				//shortsword
			CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
			CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl002",oContainer);				//studded leather armor
			return;
		}
		CreateItemOnObject("nw_wswls001",oContainer);				//longsword
		CreateItemOnObject("nw_wswdg001",oContainer);				//dagger
		CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
		CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl002",oContainer);				//studded leather armor
		return;
	} else if (nClass==CLASS_TYPE_ROGUE)//******************************************************************************
	{
		CreateItemOnObject("nw_wswss001",oContainer);				//shortsword
		CreateItemOnObject("nw_wswdg001",oContainer);				//dagger
		CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
		CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
		return;
	} else if (nClass==CLASS_TYPE_SORCERER)//***************************************************************************
	{
		if (GetHasSpellFeat(oPC)) //Spell Feat: Any
		{
			CreateItemOnObject("nw_wdbqs001",oContainer);				//quarterstaff
			CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
			CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			return;
		}
		CreateItemOnObject("nw_wblml001",oContainer);				//mace
		CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
		CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		return;
	} else if (nClass==CLASS_TYPE_SPIRIT_SHAMAN)//**********************************************************************
	{
		CreateItemOnObject("nw_waxhn001",oContainer);				//handaxe
		CreateItemOnObject("nw_wbwsh001",oContainer);				//shortbow
		CreateItemOnObject("nw_ashlw001",oContainer);				//heavy shield
		CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl001",oContainer);				//leather armor
		return;
	} else if (nClass==CLASS_TYPE_SWASHBUCKLER)//***********************************************************************
	{
		CreateItemOnObject("nw_wswrp001",oContainer);					//rapier
		CreateItemOnObject("nw_wswdg001",oContainer);					//dagger
		//CreateItemOnObject("nw_wbwsh001",oContainer);					//shortbow
		CreateItemOnObject("nw_wthax001",oContainer, ARROW_STACK);		//throwing axes
		//CreateItemOnObject("nw_ashsw001",oContainer);					//light shield
		//CreateItemOnObject("nw_wamar001",oContainer, ARROW_STACK);	//arrows
		//CreateItemOnObject("nw_wthdt001",oContainer, ARROW_STACK);	//darts
		CreateItemOnObject("nw_it_mpotion001",oContainer);				//potion of cure light wounds
		//CreateItemOnObject("n2_helm_swashhat",oContainer);			//swashbuckler's hat
		//CreateItemOnObject("nw_aarcl001",oContainer);					//leather armor
		return;
	} else if (nClass==CLASS_TYPE_WARLOCK)//****************************************************************************
	{
		if (GetHasSpellFeat(oPC)) //Spell Feat: Any
		{
			CreateItemOnObject("nw_wdbqs001",oContainer);				//quarterstaff
			CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
			CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			//CreateItemOnObject("nw_aarcl009",oContainer);				//padded armor
			return;
		}
		CreateItemOnObject("nw_wblml001",oContainer);				//mace
		CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
		CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		//CreateItemOnObject("nw_aarcl009",oContainer);				//padded armor
		return;
	} else if (nClass==CLASS_TYPE_WIZARD)//*****************************************************************************
	{
		if (GetHasSpellFeat(oPC)) //Spell Feat: Any
		{
			CreateItemOnObject("nw_wdbqs001",oContainer);				//quarterstaff
			CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
			CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
			CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
			return;
		}
		CreateItemOnObject("nw_wblcl001",oContainer);				//club
		CreateItemOnObject("nw_wswdg001",oContainer);				//dagger
		CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
		CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		return;
	} else //safety catch condition should the script fail to identify the class of the opener *************************
		{
		CreateItemOnObject("nw_wblcl001",oContainer);				//club
		CreateItemOnObject("nw_wswdg001",oContainer);				//dagger
		CreateItemOnObject("nw_wbwxl001",oContainer);				//light crossbow
		CreateItemOnObject("nw_wambo001",oContainer, ARROW_STACK);	//bolts
		CreateItemOnObject("nw_it_mpotion001",oContainer);			//potion of cure light wounds
		return;
	}
}

/* int GetArcherySpec(object oPC)
{
	return FALSE;
} */

int GetHasSpellFeat(object oPC)
{
	if (GetHasFeat(FEAT_SPELL_FOCUS_ABJURATION,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_PENETRATION,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_FOCUS_CONJURATION,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_FOCUS_DIVINATION,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_FOCUS_ENCHANTMENT,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_FOCUS_EVOCATION,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_FOCUS_ILLUSION,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_FOCUS_NECROMANCY,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SPELL_FOCUS_TRANSMUTATION,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_EMPOWER_SPELL,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_EXTEND_SPELL,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_QUICKEN_SPELL,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_SILENCE_SPELL,oPC))
		return TRUE;
	if (GetHasFeat(FEAT_STILL_SPELL,oPC))
		return TRUE;
	return FALSE;
}


/*
int ProvideArmor(object oChar, object oContainer);
int ProvideShield(object oChar, object oContainer);
int ProvideOneHandedWeapon(object oChar, object oContainer);
int ProvideTwoHandedWeapon(object oChar, object oContainer);
int ProvideClassFrosting(object oChar, object oContainer);
int ProvideRangedWeapon(object oChar, object oContainer);

void main()
{
	object oPC = GetLastOpenedBy();
	if (GetLocalInt(oPC,"STARTING CHEST POP")==1)
		return;
	if (GetTag(oPC)!="")
		return;
	SetLocalInt(oPC,"STARTING CHEST POP",1);

	object oChest = OBJECT_SELF;

	if (GetHasFeat(FEAT_SHIELD_PROFICIENCY, oPC))				//Spawn Shield if you can use one
		ProvideShield(oPC, oChest);

	ProvideArmor(oPC,oChest);								//Spawn in Appropriate Armor

	ProvideRangedWeapon(oPC,oChest);						//Spawn in a ranged weapon

	if (GetHasFeat(FEAT_TWO_WEAPON_FIGHTING, oPC))				//Spawn two weapons if you're a 'dual-er'
	{
		ProvideOneHandedWeapon(oPC,oChest);
		ProvideOneHandedWeapon(oPC,oChest);
	}
	else if (GetHasFeat(FEAT_SHIELD_PROFICIENCY, oPC))			//Spawn just one more weapon if you've got a shield.
	{
		ProvideOneHandedWeapon(oPC,oChest);
	}
	else if (ProvideTwoHandedWeapon(oPC,oChest)==0)			//Spawn a 2-H weapon if you can use it but not a shield
		ProvideOneHandedWeapon(oPC,oChest);					//Spawn just a weapon if that's all you can use.

	ProvideClassFrosting(oPC, oChest);						//Put in some extra dressing based on class
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int ProvideRangedWeapon(object oChar, object oContainer)
{
	if (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL,oChar))
	{
		CreateItemOnObject("nw_wamar001",oContainer,30);			//30x arrows
		CreateItemOnObject("nw_wbwsh001",oContainer);			//ShortBow
		return 1;
	}
	else
	{
		CreateItemOnObject("nw_wbwxl001",oContainer);			//Crossbow
		CreateItemOnObject("nw_wambo001",oContainer,30);			//30xBolts
		return 1;
	}
	return 0;
}

int ProvideOneHandedWeapon(object oChar, object oContainer)
{
	int nClass = GetClassByPosition(1,oChar);
	if ((nClass==CLASS_TYPE_WIZARD)||(nClass==CLASS_TYPE_CLERIC)||(nClass==CLASS_TYPE_DRUID))	//non-bladed
	{
		if (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL,oChar))
		{
			CreateItemOnObject("nw_wblhl001",oContainer);			//Light Hammer
			return 1;
		}
		else
		{
			CreateItemOnObject("nw_wblml001",oContainer);			//Mace
			return 1;
		}
	}
	else
	{
		if (GetHasFeat(FEAT_WEAPON_PROFICIENCY_MARTIAL,oChar))
		{
			CreateItemOnObject("nw_wswss001",oContainer);			//Short Sword
			return 1;
		}
		else
		{
			CreateItemOnObject("nw_wswdg001",oContainer);			//Dagger
			return 1;
		}
	}

	return 0;
}

int ProvideTwoHandedWeapon(object oChar, object oContainer)
{
	return 0;
}

int ProvideClassFrosting(object oChar, object oContainer)
{
	int nClass = GetClassByPosition(1,oChar);
	if (nClass==CLASS_TYPE_BARBARIAN)
	{

		return 0;
	} else if (nClass==CLASS_TYPE_BARD)
	{


		return 0;
	} else if (nClass==CLASS_TYPE_CLERIC)
	{
		CreateItemOnObject("x2_cloth008",oContainer);			//Cleric's Robe

		return 1;
	} else if (nClass==CLASS_TYPE_DRUID)
	{


		return 0;
	} else if (nClass==CLASS_TYPE_FIGHTER)
	{
		CreateItemOnObject("nw_it_mpotion005",oContainer);		//Potion of Barkskin
		return 1;
	} else if (nClass==CLASS_TYPE_MONK)
	{


		return 0;
	} else if (nClass==CLASS_TYPE_PALADIN)
	{


		return 0;
	} else if (nClass==CLASS_TYPE_RANGER)
	{


		return 0;
	} else if (nClass==CLASS_TYPE_ROGUE)
	{
		CreateItemOnObject("nw_it_mring021",oContainer);		//Copper Ring
		return 1;
	} else if (nClass==CLASS_TYPE_SORCERER)
	{
		CreateItemOnObject("nw_it_mpotion018",oContainer);		//Potion of Owl's Wisdom
		CreateItemOnObject("nw_it_mpotion001",oContainer);		//Potion of Cure Light Wounds
		return 1;
	} else if (nClass==CLASS_TYPE_WIZARD)
	{
		CreateItemOnObject("nw_it_sparscr105",oContainer);		//Scroll Summom Creature I
		CreateItemOnObject("nw_it_mpotion001",oContainer);		//Potion of Cure Light Wounds
		return 1;
	}

	return 0;
}

int ProvideArmor(object oChar, object oContainer)
{
	if (GetHasFeat(FEAT_ARMOR_PROFICIENCY_HEAVY,oChar))
	{
		CreateItemOnObject("nw_aarcl005",oContainer);				 	//Splint Mail (+0)
		//CreateItemOnObject("nw_aarcl005",oContainer);				 	//Splint Mail (+0)
		return 1;
	}
	else if (GetHasFeat(FEAT_ARMOR_PROFICIENCY_MEDIUM, oChar))
	{
		CreateItemOnObject("nw_aarcl004",oContainer);				 	//Chain Mail (+0)
		return 1;
	}
	else if (GetHasFeat(FEAT_ARMOR_PROFICIENCY_LIGHT, oChar))
	{
		CreateItemOnObject("nw_aarcl001",oContainer);				 	//Leather Armor (+0)
		return 1;
	}
	return 0;
}

int ProvideShield(object oChar, object oContainer)
{
	CreateItemOnObject("nw_ashsw001",oContainer);						 //Light shield (+0)
	return 1;
}*/
