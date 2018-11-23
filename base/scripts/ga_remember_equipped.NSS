// ga_remember_equipped
/*
	This script marks the equipped items so that they can later be restored.
	
	Parameters:
		string sCreature = Tag of object giving items.  Default is PC. (Must be creature)
*/
// ChazM 3/15/06


#include "ginc_item"
#include "ginc_param_const"
	
void main(string sCreature)
{
	object oCreature = GetTarget(sCreature, TARGET_PC);
	
	PrettyDebug ("sCreature = " + GetName(oCreature));

	RememberEquippedItems(oCreature);
}