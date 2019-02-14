// i_nx1_container01_ci
/*
   Template for Casting Spell on item script.
    //* This code runs when a PC or DM casts a spell from one of the
    //* standard spellbooks on the item
*/
// ChazM 8/2/06
	
#include "x2_inc_switches"
#include "ginc_debug"
#include "ginc_crafting"
	
void main()
{
	object oPC = OBJECT_SELF;               	// The player who cast the spell
	object oItem  = GetSpellTargetObject();     // The item targeted by the spell
	int iSpell = GetSpellId();                  // The id of the spell that was cast
                                            	// See the list of SPELL_* constants
    
    //SpeakString("Item = " + GetTag(oItem) + " SpellID = " + IntToString(iSpell));
    // store these variables for use in gr_DoMagicCrafting
    SetLocalInt(oItem, "MySpellID", iSpell);
    SetLocalObject(oItem, "PC", oPC);
    // run gr_DoMagicCrafting
    ExecuteScript("gr_DoMagicCrafting", oItem);

	SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END); // prevent spell that was cast from taking effect
	//SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_CONTINUE); // this will allow spell to take effect
}