// '11_a_journal_wound'
/*
	Adds a journal entry about wounded guys if player hasn't healed one but has
	spoken with one. It completes the quest if player heals one.

	"Getting Back in the Fight" - tag: 11_wounded

	This script is called by wounded guy dialogs (0/20).
	Brother Merring's dialog sets entry (10) iff the Moss is given to the player
	(clerics, druids, and paladins don't need Moss).
*/
// JYL 03/16/06
// kevL 2019 apr 16 - rewrite w/ check for "Wounded" per Aqvilinus

const string sJOURNAL = "11_wounded";

void main()
{
	if (GetLocalInt(OBJECT_SELF, "Wounded"))
	{
		if (!GetGlobalInt("11_bGotHealQuest"))		// NOTE: Can't use check for (entry!=0)
		{											// because they use 0 for the 1st entry.
			SetGlobalInt("11_bGotHealQuest", TRUE);
			AddJournalQuestEntry(sJOURNAL,			// Requires 'bAllowOverrideHigher' for that reason also.
								 0,					// ie. var is really -> bAllowOverrideHigherOrEqual
								 GetFirstPC(),
								 TRUE,TRUE,TRUE);
		}
	}
	else
	{
		object oPC = GetFirstPC();
		if (GetJournalEntry(sJOURNAL, oPC) != 20)	// NOTE: An id check can be used here ->
			AddJournalQuestEntry(sJOURNAL, 20, oPC);
	}
}
