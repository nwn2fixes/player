// i_nx1_dream_club_ac
// by Brendan Bellina
// July 2010

// Distributed with MotB Makeover SoZ Edition by Brendan Bellina

// Dream Club OnActivate handler
// This script is executed automatically when the item is activated
// To trigger properly the name of the script MUST be "i_" + itemtag + "_ac"
// Also to make the item usable set Item Property to Cast Spell: Unique Power on Self

//#include "ginc_debug"
	
void main()
{
	//PrettyDebug("i_nx1_dream_club_ac: Dream Club");

	object oPC = GetItemActivator();
	SetLocalString(oPC, "BB_NX1_DREAMWEAPON_TAG", GetTag(GetItemActivated()));
	SetLocalString(oPC, "BB_NX1_DREAMWEAPON_FORM", "club");
	SetGlobalString("BB_NX1_DREAMWEAPON_ACTOR", GetTag(oPC));
	// The campaign/module  may not allow companions to converse, so the conversation may
	// be with the FirstPC if the actor is a companion.
	AssignCommand(oPC, ActionStartConversation(oPC, "gl_dream_weapon", FALSE, FALSE, TRUE, FALSE));
}