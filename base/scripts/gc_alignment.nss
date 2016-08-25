// gc_alignment
/*
   This checks if player's alignment is greater than or equal to nCheck.

   Parameters:
     int nCheck   = Checks if alignment of player is greater than defines.
                    On a scale of 3 (Saintly) to -3 (Fiendish)
					Or equivalently, 3 (Really, really lawful), to -3 (incredibly chaotic)

					So the standard "Is the PC good?" check would use a value of 0 for nCheck.
					Same for "Is the PC evil," but you'd use a NOT with this script call --
					as in "Is the PC NOT good?"

     int bLawChaosAxis = 0 means check Good/Evil axis, 1 means check Law/Chaos axis
*/
// FAB 10/5
// EPF 6/6/05 -- changed some function calls, modified param name
// kevL's 2016 aug 24
//	- fixed "nCheck" to "nAlignCheck"

int CheckAlignment(object oPC, int nCheck, int bLawChaosAxis)
{
    int nAlignCheck;

    // Set up alignment to check
    switch ( nCheck )
    {
        case -3:
            nAlignCheck = 5; // -84 Later on
            break;
        case -2:
            nAlignCheck = 15; // -59 Later on
            break;
        case -1:
            nAlignCheck = 25; // -24 Later on
            break;
        case 0:
            nAlignCheck = 50; // 0 Later on
            break;
        case 1:
            nAlignCheck = 75; // 25 Later on
            break;
        case 2:
            nAlignCheck = 85; // 60 Later on
            break;
        case 3:
            nAlignCheck = 99; // 85 Later on
            break;
    }

    if ( bLawChaosAxis == 0 )
    {
        if ( GetGoodEvilValue(oPC) >= nAlignCheck ) return TRUE;
    }
    else
    {
        if ( GetLawChaosValue(oPC) >= nAlignCheck ) return TRUE; // kL
    }

    return FALSE;

}

int StartingConditional(int nCheck, int bLawChaosAxis)
{

    object oPC = GetPCSpeaker();
	return CheckAlignment(oPC, nCheck, bLawChaosAxis);
}