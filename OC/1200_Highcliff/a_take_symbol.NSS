// 'a_take_symbol'
/*
	Take the Holy Symbol from the player.
*/
// JYL 10/11
// kevL 2023 feb 10 - rewrite to take the Symbol from any character in the party
//                  - invoke this script from Tor's dialog 'tor_new' (the dialog
//                    was using 'ga_take_item' which can check only PCSpeaker or
//                    TruePCs)

// OBJECT_SELF is the good friar Tor in Fort Locke
void main()
{
	object oSymbol;

	object oPcSpeaker = GetPCSpeaker();
	object oParty = GetFirstFactionMember(oPcSpeaker, FALSE);
	while (GetIsObjectValid(oParty))
	{
		if (GetIsObjectValid(oSymbol = GetItemPossessedBy(oParty, "12_tor_it")))
		{
			ActionTakeItem(oSymbol, oParty);
			return;
		}
		oParty = GetNextFactionMember(oPcSpeaker, FALSE);
	}
}
