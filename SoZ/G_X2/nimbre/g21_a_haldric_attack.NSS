//	g21_a_haldric_attack
/*
	Haldric attempts to murder the party.
*/
//	JSH-OEI 4/22/08

#include "ginc_group"

void main()
{
	GroupSetScriptHidden("Haldric", FALSE);
	GroupGoHostile("Haldric");
}