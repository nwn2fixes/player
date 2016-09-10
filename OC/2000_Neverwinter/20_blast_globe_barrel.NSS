// 20_blast_globe_barrel
//
// Control for the blast globes you find in Cyran's house.
	
// EPF 2/14/06

#include "20_inc_cyran"		

	
void main(int nEvent)
{
	object oPC = GetPCSpeaker();
	object oBarrel = OBJECT_SELF;
	object oBarrel2;
	
	switch(nEvent)
	{
	case 1:	//barrel explodes.
		oBarrel2 = GetNearestObjectByTag("20_plc_blastglobes");
		ExplodeBarrel(oBarrel);
		if(GetIsObjectValid(oBarrel2))
		{
			ExplodeBarrel(oBarrel2);
		}
		
		break;
	case 2:	//player gets barrel into inventory
		CreateItemOnObject("20_it_blastglobe_barrel",oPC);
		SetLocalInt(GetModule(),"collected_blastbarrels",1); 
		DestroyObject(oBarrel);
		
		break;
	}
		
}