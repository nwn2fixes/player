// '3052_cut_scar_end'
/*
	End/Abort script for '3052_cut_scar' dialog.

	OC Act III
	3000_Neverwinter_A3.mod
	areatag '3052_wharbor'

	Note that the dialog cannot be aborted.

	- resets party's OrientOnDialog flags
*/
// kL 2022 apr 8

//
void main()
{
	object oPc = GetFirstPC();
	object oParty = GetFirstFactionMember(oPc, FALSE);
	while (GetIsObjectValid(oParty))
	{
		SetOrientOnDialog(oParty, TRUE);
		oParty = GetNextFactionMember(oPc, FALSE);
	}
}
