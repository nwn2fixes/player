// '11_a_tarmas_center'
/*
	All this does is remove the Wizard's Arsenal quest.
*/
// JYL 07/20/06
// kevL 2018.11.22 - fix: Don't let Tarmas tell you to loot his house (ie. don't
//                   add Wizard's Arsenal to the journal) if you've already
//                   looted it.
// travus 2023.7.21 - if both 'bAllPartyMembers' and 'bAllPlayers' in the
//                    RemoveJournalQuestEntry() are set to TRUE then the journal
//                    entry will only be removed from the controlled character.
//                    To resolve this issue, added a GetIsSinglePlayer() check
//                    to revert to the function's default parameters. This must
//                    be done in order to properly remove the journal entry from
//                    the entire party in single-player games.

int StartingConditional()
{
	SetLocalInt(GetModule(), "bTarmasHouseEntered", TRUE); // kL_fix - See dialog '11_tarmas'

	if (GetIsSinglePlayer()) RemoveJournalQuestEntry("11_tarmas_house", GetFirstPC()); // travus_fix ->
	else                     RemoveJournalQuestEntry("11_tarmas_house", GetFirstPC(), TRUE, TRUE);

	if (GetGlobalInt("11_west_harbor_plot") >= 10)
	{
		object oArea = GetObjectByTag("1102_tarmas");

		AmbientSoundChangeDay(oArea, 0); // turn off ambient sounds
		AmbientSoundChangeNight(oArea, 0);

		MusicBackgroundChangeDay(oArea, 95); // set to West Harbor Theme
		MusicBackgroundChangeNight(oArea, 95);
	}

	return FALSE;
}
