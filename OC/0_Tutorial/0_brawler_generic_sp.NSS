
//0b_brawler_generic_sp

//Sets up the ambient life brawlers to stage a fake fight before the player uses the ring

// DBR 5/31/06
// kevL 2017 mar 12 - fix to get the brawlers brawling again.

/* void CowerForever() // kL: not used.
{
	PlayCustomAnimation(OBJECT_SELF,"idlecower",1);
	DelayCommand(10.0f,CowerForever());
} */


void main()
{
	string sMe = GetTag(OBJECT_SELF);

//	SetCombatOverrides(OBJECT_SELF,OBJECT_INVALID, -1, -1, OVERRIDE_ATTACK_RESULT_DEFAULT,-1, -1, TRUE,TRUE, TRUE,TRUE );


	if (sMe=="0_brawler_generic1")
	{
		ActionAttack(GetObjectByTag("0_brawler_generic2"));
	}
	else if (sMe=="0_brawler_generic2")
	{
		ActionAttack(GetObjectByTag("0_brawler_generic1"));
	}
	else if (sMe=="0_brawler_generic3")
	{
		ActionAttack(GetObjectByTag("0_brawler_generic4"));
	}
	else if (sMe=="0_brawler_generic4")
	{
		ActionAttack(GetObjectByTag("0_brawler_generic3"));
	}

	/*else if (sMe=="0_brawler_generic_female1")
	{
		ActionAttack(GetObjectByTag("0_brawler_generic2"));
	}
	else if (sMe=="0_brawler_generic_female2")
	{
		ActionAttack(GetObjectByTag("0_brawler_generic_female1"));
	}*/
//	SetEventHandler(OBJECT_SELF,CREATURE_SCRIPT_ON_HEARTBEAT,"");
}