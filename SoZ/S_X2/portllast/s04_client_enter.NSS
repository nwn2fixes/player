// s04_client_enter.nss
/*
	Area OnClientEnter event handler for Gothaladreum.
*/
// TDE 3/13/08
//BN - OEI 09/08/08 Added desotyable states for NPCs if the army of the dead is called. 

#include "kinc_spawn"
#include "ginc_misc"

void SpawnNPCsInitial()
{
	object oPC = GetFirstPC();
	
	SpawnIt("s04_nya");
	AddJournalQuestEntry("s_q02_army_dead", 200, oPC, TRUE, FALSE);
}

void SpawnLoot()
{
	// Spawn placed loot
	string sLoot1	= "nx2_ring_prot_01"; //Ring of Protection +1
	string sLoot2	= "nw_it_gem001"; //Greenstone
	string sLoot3	= "nx2_fplate_00"; // Fullplate
	string sLoot4	= "nx2_bsword_02"; // +2 Bastard Sword
	string sLoot5	= "x1_it_spdvscr605"; // Scroll of Create Undead
	string sLoot6	= "n2_it_spdvscr006"; // Scroll of Detect Undead
	string sLoot7	= "n2_it_sparscr010"; // Scroll of False Life
	string sLoot8	= "nw_it_spdvscr501"; // Scroll of Raise Dead
	string sLoot9	= "nx2_r_boot_reflex03"; // Recipe: Boots of Reflexes +3
	string sLoot10	= "nx2_r_brc_armor02"; // Recipe: Bracers of Armor +2
	string sLoot11	= "nx2_r_bck_resist03"; // Recipe: Cloak of Resistance +3
	string sLoot12	= "nx2_r_head_int06"; // Recipe: Headband of Intelect +6
	string sLoot13	= "nx2_r_brc_armor02"; // Recipe: Bracers of Armor +2
	string sLoot14	= "nx2_r_ring_majsonic"; // Recipe: Ring of Major Sonic Resistance
	string sLoot15	= "nw_it_torch001"; // Torch
	string sLoot16	= "nw_it_torch001"; // Torch
	
	CreateLootOnObject("s04_gravestone1", sLoot1);
	CreateLootOnObject("s04_gravestone2", sLoot2);
	CreateLootOnObject("s04_gravestone3", sLoot3);
	CreateLootOnObject("s04_adreum", sLoot4);
	CreateLootOnObject("s04_book1", sLoot5);
	CreateLootOnObject("s04_book1", sLoot6);
	CreateLootOnObject("s04_book1", sLoot7);
	CreateLootOnObject("s04_book1", sLoot8);
	CreateLootOnObject("s04_book2", sLoot9);
	CreateLootOnObject("s04_book2", sLoot10);
	CreateLootOnObject("s04_book2", sLoot11);
	CreateLootOnObject("s04_book2", sLoot12);
	CreateLootOnObject("s04_book2", sLoot13);
	CreateLootOnObject("s04_book2", sLoot14);
	CreateLootOnObject("s04_skelly_corpse", sLoot15);
	CreateLootOnObject("s04_skelly_corpse", sLoot16);
	

}

void DestroyNpcs()
{
	string sNya = "s04_nya";
	string sAdreum = "s04_adreum";
	string sSkel1 = "s04_skeleton_legionaire";
	string sSkel2 = "s04_skeleton_legionaire2";
	string sSkel3 = "s04_skeleton_legionaire3";
	string sSkel4 = "s04_skeleton_legionaire4";
	string sSkel5 = "s04_skeleton_legionaire5";
	string sSkel6 = "s04_skeleton_legionaire6";
	string sSkel7 = "s04_skeleton_legionaire7";
	string sSkel8 = "s04_skeleton_legionaire8";
	string sSkel9 = "s04_skeleton_legionaire9";
	string sSkel10 = "s04_skeleton_legionaire10";
	
	if (GetGlobalInt("S_bLuskansGone") && GetGlobalInt("S_bNyaReturns"))
		DestroyIt(sNya, -1);
	DestroyIt(sAdreum, -1);	
	DestroyIt(sSkel1, -1);	
	DestroyIt(sSkel2, -1);	
	DestroyIt(sSkel3, -1);	
	DestroyIt(sSkel4, -1);	
	DestroyIt(sSkel5, -1);	
	DestroyIt(sSkel6, -1);	
	DestroyIt(sSkel7, -1);	
	DestroyIt(sSkel8, -1);	
	DestroyIt(sSkel9, -1);	
	DestroyIt(sSkel10, -1);	
}
	
int StartingConditional()
{
	object oModule = GetModule();

	// First time the party enters Gothaladreum. 
	if(!IsMarkedAsDone())
	{
		PrettyDebug("s04_client_enter: Initial NPCs spawning.");
		SpawnNPCsInitial();
		SpawnLoot();	
		MarkAsDone();
	}
	
	if (GetGlobalInt("S_bArmyofDeadRaised"))
	{
	DestroyNpcs();
	}

	return ( FALSE );
}