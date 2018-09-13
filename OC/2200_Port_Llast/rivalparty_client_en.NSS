// rivalparty_client_en
//
// Initiate the rival party encounter

// EPF 2/8/06
// kevL 2018 sept 13 - delete Niyra's mithral chainmail drop and replace it with
//                     mithral chainmail that has the ArmorRuleStats of mithral.

int StartingConditional()
{
	if(!FiredFromPartyTransition())
		return FALSE;
	object oPC = GetFactionLeader(GetFirstEnteringPC());

	// kL_fix: Niyra's mithral chainmail drop.
	object oNiyra = GetNearestObjectByTag("niyra", oPC);
	if (GetIsObjectValid(oNiyra) && !GetLocalInt(oNiyra, "chaindropfixed"))
	{
		SetLocalInt(oNiyra, "chaindropfixed", TRUE);

		object oDrop0 = GetItemPossessedBy(oNiyra, "NW_MAARCL037"); // Elven Chainmail
		if (GetIsObjectValid(oDrop0))
		{
			DestroyObject(oDrop0);

			// NOTE: Niyra's drop is not stock Elven Chainmail ... it appears to differ
			// only in that it has IPs
			//   AC Bonus [+3], Base Item Weight Reduction [40% of Weight], Skill Bonus: Hide [+6], Skill Bonus: Move Silently [+6]
			//   (but remove the WeightReduction since the Mithral armorrulestat already accounts for decreased weight)
			// instead of
			//   AC Bonus [+3], Saving Throw Bonus: Universal [+1] <- stock
			object oDrop = CreateItemOnObject("nw_maarcl037_niyra", oNiyra);
			if (GetIsObjectValid(oDrop))
				SetDroppableFlag(oDrop, TRUE);
		}
	}
	// kL_fix_End.

	AssignCommand(GetNearestObjectByTag("zinn",oPC), ActionStartConversation(oPC, "22_rivalparty",FALSE,FALSE,TRUE,FALSE));
	return TRUE;
}
