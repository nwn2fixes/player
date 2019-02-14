// i_temp_aq
/*
   Template for an Acquire item script.
   This script will run each time the item is acquired.
   
   How to use this script:
   Replace the word "temp" (in line 1) with the tag of the item.  Rename the script with this name.  
    
   Additional Info:
   In general, all the item "tag-based" scripts will be named as follows:
   - a prefix ("i_" by defualt)
   - the tag of the item
   - a postfix indicating the item event.
   
   This script will be called automatically (by defualt) whether it exists or not.  If if does not exist, nothing happens.
   "_aq" was used for the Acquire postfix because "_ac" was already taken by Activate.  
   
   Note: this script runs on the module object, an important consideration for assigning actions.
   -ChazM
*/
// Name_Date

#include "ginc_item_script"

void main()
{
    object oPC      = GetModuleItemAcquiredBy();
    object oItem    = GetModuleItemAcquired();
    int iStackSize  = GetModuleItemAcquiredStackSize();
    object oFrom    = GetModuleItemAcquiredFrom();

	
	// Once marked complete, never run this script again.
	if (IsItemMarkedAsDone(oItem, SCRIPT_MODULE_ON_ACQUIRE_ITEM))
		return;
	
	// 	Don't run this script unless it's aqcuired by a player or party member
	// (This event runs at the start of the game	
	if (!IsItemAcquiredByPartyMember())
		return;

				
 	//Your code goes here
	AddJournalQuestEntry("g_q05_agents", 100, oPC);
		
	// Permanently mark item as complete so script will never run again (even if the character is exported to another game)		
	MarkItemAsDone(oItem, SCRIPT_MODULE_ON_ACQUIRE_ITEM);

}