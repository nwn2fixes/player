// gc_check_race_pc
//
// returns TRUE if the PC speaker's race corresponds with the race specified.
// race can be specified in two ways: by number or by string.  The number
// is still entered as a string, sRace.

// Here are the arguments you can use:
//
// sRace		Alternative
// -----		-----------
// dwarf		1
// elf			2
// gnome		3
// halfelf		4
// halfling		5
// halforc		6
// human		7
// outsider		8
// yuan-ti		9
//
// so gc_check_race_pc("dwarf") and gc_check_race_pc("1") will do the same thing.

// You can also check subraces using this function:
// (Note: Shield Dwarves, Moon Elves, Lightfoot Halflings, and Rock Gnomes are the common varieties of their
//  respective races.)
// (Note: half-elf, half-orc, and human are considered both races and subraces.  The subrace versions should
//  be prepended with "sr-" as written below, if you intend to check subrace rather than the race.)
//
// sRace			Alternative
// -----			-----------
// shielddwarf		11
// moonelf			12
// rockgnome		13
// sr-halfelf		14
// lightfoothalf	15
// sr-halforc		16
// sr-human			17
// golddwarf		18
// duergar			19
// drow				20
// sunelf			21
// woodelf			23
// svirfneblin		24
// stronghearthalf	26
// aasimar			27
// tiefling			28
// half-drow		29
// wildelf			30
// firegenasi		31
// watergenasi		32
// earthgenasi		33
// airgenasi		34
// grayorc			35
//
// civdwarves		41	-- this is all dwarf subraces, save duergar.
// civelves			42	-- all elf subraces, save drow and wild.
// civhalflings		43	-- all halfling subraces, save ghostwise
// civorcs			44	-- all orc subraces
//
//
// EPF 6/16/05
// TDE 7/29/08 - Added yuan-ti, grayorc and civorcs
// Aqvilinus(kevL) 2019 jan 15 - fix civ-types' subracial checks


int StartingConditional(string sRace)
{
	sRace = GetStringLowerCase(sRace);
	object oPC = GetPCSpeaker();
	int nRacialType = GetSubRace(oPC);
	int nCheck;
	int nRace = StringToInt(sRace);
	int bSubrace = TRUE;


	//RACES
	if(sRace == "dwarf" || nRace == 1)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_DWARF;
	}
	else if (sRace == "elf" || nRace == 2)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_ELF;
	}
	else if (sRace == "gnome" || nRace == 3)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_GNOME;
	}
	else if (sRace == "halfelf" || nRace == 4)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_HALFELF;
	}
	else if (sRace == "halfling" || nRace == 5)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_HALFLING;
	}
	else if (sRace == "halforc" || nRace == 6)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_HALFORC;
	}
	else if (sRace == "human" || nRace == 7)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_HUMAN;
	}
	else if (sRace == "outsider" || nRace == 8)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_OUTSIDER;
	}
	else if (sRace == "yuanti" || sRace == "yuan-ti" || nRace == 9)
	{
		nRacialType = GetRacialType(oPC);
		nCheck = RACIAL_TYPE_YUANTI;
	}

	//SUBRACES
	else if(sRace == "shielddwarf" || nRace == 11)
	{
		nCheck = RACIAL_SUBTYPE_SHIELD_DWARF;
	}
	else if(sRace == "moonelf" || nRace == 12)
	{
		nCheck = RACIAL_SUBTYPE_MOON_ELF;
	}
	else if(sRace == "rockgnome" || nRace == 13)
	{
		nCheck = RACIAL_SUBTYPE_ROCK_GNOME;
	}
	else if(sRace == "halfelf" || nRace == 14)
	{
		nCheck = RACIAL_SUBTYPE_HALFELF;
	}
	else if(GetStringLeft(sRace, 13) == "lightfoothalf" || nRace == 15)
	{
		nCheck = RACIAL_SUBTYPE_LIGHTFOOT_HALF;
	}
	else if(sRace == "halforc" || nRace == 16)
	{
		nCheck = RACIAL_SUBTYPE_HALFORC;
	}
	else if(sRace == "human" || nRace == 17)
	{
		nCheck = RACIAL_SUBTYPE_HUMAN;
	}
	else if(sRace == "golddwarf" || nRace == 18)
	{
		nCheck = RACIAL_SUBTYPE_GOLD_DWARF;
	}
	else if(sRace == "duergar" || nRace == 19)
	{
		nCheck = RACIAL_SUBTYPE_GRAY_DWARF;
	}
	else if(sRace == "drow" || nRace == 20)
	{
		nCheck = RACIAL_SUBTYPE_DROW;
	}
	else if(sRace == "sunelf" || nRace == 21)
	{
		nCheck = RACIAL_SUBTYPE_SUN_ELF;
	}
	else if(sRace == "woodelf" || nRace == 23)
	{
		nCheck = RACIAL_SUBTYPE_WOOD_ELF;
	}
	else if(sRace == "svirfneblin" || nRace == 24)
	{
		nCheck = RACIAL_SUBTYPE_SVIRFNEBLIN;
	}
	else if(GetStringLeft(sRace,16) == "stronghearthalf" || nRace == 26)
	{
		nCheck = RACIAL_SUBTYPE_STRONGHEART_HALF;
	}
	else if(sRace == "aasimar" || nRace == 27)
	{
		nCheck = RACIAL_SUBTYPE_AASIMAR;
	}
	else if(sRace == "tiefling" || nRace == 28)
	{
		nCheck = RACIAL_SUBTYPE_TIEFLING;
	}
	else if(sRace == "halfdrow" || nRace == 29)
	{
		nCheck = 43; // Half-Drow
	}
	else if(sRace == "wildelf" || nRace == 30)
	{
		nCheck = RACIAL_SUBTYPE_WILD_ELF;
	}
	else if(sRace == "firegenasi" || nRace == 31)
	{
		nCheck = RACIAL_SUBTYPE_FIRE_GENASI;
	}
	else if(sRace == "watergenasi" || nRace == 32)
	{
		nCheck = RACIAL_SUBTYPE_WATER_GENASI;
	}
	else if(sRace == "earthgenasi" || nRace == 33)
	{
		nCheck = RACIAL_SUBTYPE_EARTH_GENASI;
	}
	else if(sRace == "airgenasi" || nRace == 34)
	{
		nCheck = RACIAL_SUBTYPE_AIR_GENASI;
	}
	else if(sRace == "grayorc" || sRace == "greyorc" || nRace == 35)
	{
		nCheck = RACIAL_SUBTYPE_GRAYORC;
	}

	//SETS OF SUBRACES
	else if (sRace == "civdwarves" || nRace == 41) // Aqvilinus fix ->
	{
		return (nRacialType == RACIAL_SUBTYPE_GOLD_DWARF ||
				nRacialType == RACIAL_SUBTYPE_SHIELD_DWARF);
	}
	else if (sRace == "civelves" || nRace == 42)
	{
		return (nRacialType == RACIAL_SUBTYPE_MOON_ELF ||
				nRacialType == RACIAL_SUBTYPE_SUN_ELF ||
				nRacialType == RACIAL_SUBTYPE_WOOD_ELF);
	}
	else if (sRace == "civhalflings" || nRace == 43)
	{
		return (nRacialType == RACIAL_SUBTYPE_LIGHTFOOT_HALF ||
				nRacialType == RACIAL_SUBTYPE_STRONGHEART_HALF);
	}
	else if (sRace == "civorcs" || nRace == 44)
	{
		return (nRacialType == RACIAL_SUBTYPE_HALFORC ||
				nRacialType == RACIAL_SUBTYPE_GRAYORC);
	}

	return (nRacialType == nCheck);
}
