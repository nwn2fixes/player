// 20c_soldiers_dead
//
// Returns the number of dead henchmen in the cyran quest.  Returns TRUE if number of dead soldiers is >= ncheck.

// EPF 5/1/06

#include "20_inc_cyran"

int StartingConditional(int nCheck)
{
	return GetNumSoldiersDead() >= nCheck; // kL_fix
}