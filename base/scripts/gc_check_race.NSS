// gc_check_race
//
/*
	TRUE if creature with tag sTarget is of race sRace.  Here are the options for sRace:
	aberration
	animal
	beast
	construct
	dragon
	dwarf
	elemental
	elf
	fey
	goblinoid
	giant
	gnome
	grayorc
	halfelf
	halfling
	halforc
	human
	humanoid (encompasses goblinoid, monstrous, orc, reptilian)
	magical_beast
	monstrous
	orc
	ooze
	outsider
	reptilian
	shapechanger
	undead
	vermin
	yuan-ti
*/
//	EPF 6/16/05
// kevL 20.02.20 - add Dwarf. They forgot Dwarf.


#include "ginc_misc"

int StartingConditional(string sTarget, string sRace)
{
	sRace = GetStringLowerCase(sRace);
	object oTarget = GetTarget(sTarget);
	int nRacialType = GetRacialType(oTarget);
	int nCheck = -1;
	if(sRace == "aberration")
	{
		nCheck = RACIAL_TYPE_ABERRATION;
	}
	else if(sRace == "animal")
	{
		nCheck = RACIAL_TYPE_ANIMAL;
	}
	else if(sRace == "beast")
	{
		nCheck = RACIAL_TYPE_BEAST;
	}
	else if(sRace == "construct")
	{
		nCheck = RACIAL_TYPE_CONSTRUCT;
	}
	else if(sRace == "dragon")
	{
		nCheck = RACIAL_TYPE_DRAGON;
	}
	else if(sRace == "dwarf") // kL_add
	{
		nCheck = RACIAL_TYPE_DWARF;
	}
	else if(sRace == "elemental")
	{
		nCheck = RACIAL_TYPE_ELEMENTAL;
	}
	else if(sRace == "elf")
	{
		nCheck = RACIAL_TYPE_ELF;
	}
	else if(sRace == "fey")
	{
		nCheck = RACIAL_TYPE_FEY;
	}
	else if(sRace == "giant")
	{
		nCheck = RACIAL_TYPE_GIANT;
	}
	else if(sRace == "gnome")
	{
		nCheck = RACIAL_TYPE_GNOME;
	}
	else if(sRace == "grayorc" || sRace == "greyorc")
	{
		nCheck = RACIAL_TYPE_GRAYORC;
	}
	else if(sRace == "halfelf")
	{
		nCheck = RACIAL_TYPE_HALFELF;
	}
	else if(sRace == "halfling")
	{
		nCheck = RACIAL_TYPE_HALFLING;
	}
	else if(sRace == "halforc")
	{
		nCheck = RACIAL_TYPE_HALFORC;
	}
	else if(sRace == "human")
	{
		nCheck = RACIAL_TYPE_HUMAN;
	}
	else if(sRace == "goblinoid")
	{
		nCheck = RACIAL_TYPE_HUMANOID_GOBLINOID;
	}
	else if(sRace == "monstrous")
	{
		nCheck = RACIAL_TYPE_HUMANOID_MONSTROUS;
	}
	else if(sRace == "orc")
	{
		nCheck = RACIAL_TYPE_HUMANOID_ORC;
	}
	else if(sRace == "reptilian")
	{
		nCheck = RACIAL_TYPE_HUMANOID_REPTILIAN;
	}
	else if(sRace == "magical_beast")
	{
		nCheck = RACIAL_TYPE_MAGICAL_BEAST;
	}
	else if(sRace == "ooze")
	{
		nCheck = RACIAL_TYPE_OOZE;
	}
	else if(sRace == "outsider")
	{
		nCheck = RACIAL_TYPE_OUTSIDER;
	}
	else if(sRace == "shapechanger")
	{
		nCheck = RACIAL_TYPE_SHAPECHANGER;
	}
	else if(sRace == "undead")
	{
		nCheck = RACIAL_TYPE_UNDEAD;
	}
	else if(sRace == "vermin")
	{
		nCheck = RACIAL_TYPE_VERMIN;
	}
	else if(sRace == "yuan-ti" || sRace == "yuanti")
	{
		nCheck = RACIAL_TYPE_YUANTI;
	}
	else if(sRace == "humanoid")
	{
		return (nRacialType == RACIAL_TYPE_HUMANOID_GOBLINOID || 
				nRacialType == RACIAL_TYPE_HUMANOID_MONSTROUS || 
				nRacialType == RACIAL_TYPE_HUMANOID_ORC || 
				nRacialType == RACIAL_TYPE_GRAYORC || 
				nRacialType == RACIAL_TYPE_HUMANOID_REPTILIAN);
	}
	else
	{
		PrintString("ERROR in gc_check_race: invalid race parameter specified -- race " + sRace + " does not exist.");
	}
	return (nRacialType == nCheck);
}