// '2007_cliententer'
/*
	Sand's shop - he uses a substitute merchant in act 2+
*/
// EPF 8/8/06
// kevL 2018 aug 12 - refactor and fix the Fireburst scroll

void DestroyFireburst(object oStore);
void CreateFireburst(object oStore);

//
void main()
{
	object oPc = GetFirstEnteringPC();

	if (!GetLocalInt(OBJECT_SELF, "kLfix_SandStore"))
	{
		SetLocalInt(OBJECT_SELF, "kLfix_SandStore", TRUE);

		object oStore = GetNearestObjectByTag("10_sand_store", oPc);
		DestroyFireburst(oStore);
		DelayCommand(0.1f, CreateFireburst(oStore));

		oStore = GetNearestObjectByTag("10_2nd_sand_store", oPc);
		DestroyFireburst(oStore);
		DelayCommand(0.1f, CreateFireburst(oStore));
	}

	if (GetGlobalInt("00_nAct") > 1)
	{
		SetScriptHidden(GetNearestObjectByTag("10_intro_sand", oPc),TRUE);
		SetScriptHidden(GetNearestObjectByTag("10_sand", oPc), TRUE);
		SetScriptHidden(GetNearestObjectByTag("20_merchant_elemental", oPc), FALSE);
	}
}


//
void DestroyFireburst(object oStore)
{
	object oItem = GetFirstItemInInventory(oStore);
	while (GetIsObjectValid(oItem))
	{
		if (GetTag(oItem) == "n2_it_sparscr027")
		{
			DestroyObject(oItem);
			break;
		}
		oItem = GetNextItemInInventory(oStore);
	}
}

//
void CreateFireburst(object oStore)
{
	CreateItemOnObject("n2_it_sparscr011", oStore);
}
