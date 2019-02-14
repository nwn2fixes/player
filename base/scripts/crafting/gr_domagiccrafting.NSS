// gr_DoMagicCrafting
/*
	Calls magic crafting on item
	
*/
// MDiekmann_3/14/07

#include "ginc_crafting"

void main()
{
    object oItem = OBJECT_SELF;
    object oPC = GetLocalObject(oItem, "PC");
    int iSpellID = GetLocalInt(oItem, "MySpellID");
    //output ("iSpellID = " + IntToString(iSpellID), oCaster);
    DoMagicCrafting(iSpellID, oPC); 
}