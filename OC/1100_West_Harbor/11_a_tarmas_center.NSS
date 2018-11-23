// 11_a_tarmas_center
/*
	All this does is remove the Wizard's Arsenal quest.
*/
// JYL 07/20/06
// kevL 2018.11.22 - fix: Don't let Tarmas tell you to loot his house (ie. don't
//                   add Wizard's Arsenal to the journal) if you've already
//                   looted it.

int StartingConditional()
{
	SetLocalInt(GetModule(), "bTarmasHouseEntered", TRUE); // fix, See dialog '11_tarmas'
	RemoveJournalQuestEntry("11_tarmas_house",GetFirstPC(), TRUE, TRUE);
	
	if (GetGlobalInt("11_west_harbor_plot")>=10)
	{
		object oArea = GetObjectByTag("1102_tarmas");
		AmbientSoundChangeDay(oArea, 0);	//turn off ambient sounds
		AmbientSoundChangeNight(oArea, 0);
		MusicBackgroundChangeDay(oArea,95);	//set to West Harbor Theme
		MusicBackgroundChangeNight(oArea,95);	
	}
	
	
	return FALSE;
}