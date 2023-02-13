// 'i_12_tor_it_aq'
/*
	Gets rid of the other/extra holy symbol on bandit and/or chest.
*/
// JYL 03/28/06
// kevL 2023 feb 13 - use IsItemMarkedAsDone() and MarkItemAsDone() to prevent
//                    this script from firing in other Modules (in case player
//                    elects to not turn in Tor's Holy Symbol)
//                  - there are 2 holy symbols in the area. One is on the
//                    Bandit Chief and the other is in a chest. If the former is
//                    killed and/or if the chest is bashed open the symbol drops
//                    into a bodybag and Obsidian's routine to find and destroy
//                    the symbol that is not acquired breaks. So iterate over
//                    all symbols in the module and destroy the one that wasn't
//                    just acquired.
//                  - use IsItemAcquiredByPartyMember() for multiplayer compatibility

#include "ginc_item_script"

void main()
{
	if (IsItemAcquiredByPartyMember()) // kL_changed
	{
		object oSymbol = GetModuleItemAcquired();
		if (!IsItemMarkedAsDone(oSymbol, SCRIPT_MODULE_ON_ACQUIRE_ITEM)) // kL_add
		{
			MarkItemAsDone(oSymbol, SCRIPT_MODULE_ON_ACQUIRE_ITEM); // kL_add

			if (GetLocalInt(GetModule(), "12_got_symbol") != 1)
			{
				SetLocalInt(GetModule(), "12_got_symbol", 1);
				AddJournalQuestEntry("torsymbol", 20, GetFirstPC(), TRUE, TRUE);

				object oAcquirer = GetModuleItemAcquiredBy();

				int i = 0; // kL_changed ->
				oSymbol = GetObjectByTag("12_tor_it", i);
				while (GetIsObjectValid(oSymbol))
				{
					if (GetItemPossessor(oSymbol) != oAcquirer)
						DestroyObject(oSymbol);

					oSymbol = GetObjectByTag("12_tor_it", ++i);
				}
			}
		}
	}
}
