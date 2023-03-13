// 12_b_shadprst_ud
/*
    User defined event handler for the High Cliff Shadow Priest
*/
// ChazM 2/23/05
// kevL 2023 march 12 - grant the ShadowPriest Martial weapon proficiency and
//                      equip the Warmace

// has GetHasEffect()
#include "NW_I0_GENERIC"

#include "inc_constants"

void CastZombieSummon ();
void WakeTarget(object oTarget);


void main()
{
    int iEventNum = GetUserDefinedEventNumber();

    switch (iEventNum) {

        case UD_EVENT_1: // summon zombies
            ClearAllActions();
            ActionCastFakeSpellAtObject(SPELL_SUMMON_SHADOW, OBJECT_SELF);
            ActionDoCommand(CastZombieSummon());

			// kL_begin -> the ShadowPriest needs Martial weapon proficiency to
			// equip the Warmace

			FeatAdd(OBJECT_SELF, FEAT_WEAPON_PROFICIENCY_MARTIAL, FALSE);
			object oWarmace = GetItemPossessedBy(OBJECT_SELF, "mst_bldm_drk_3");
			AssignCommand(OBJECT_SELF, ActionEquipItem(oWarmace, INVENTORY_SLOT_RIGHTHAND));
			// kL_end.

            NoInterrupt(); // optional - insures action queue not interrupted
            break;
    }
}


// Summon the 4 zombies
void CastZombieSummon ()
{
    WakeTarget(GetObjectByTag("SummonZombie1"));
    WakeTarget(GetObjectByTag("SummonZombie2"));
    WakeTarget(GetObjectByTag("SummonZombie3"));
    WakeTarget(GetObjectByTag("SummonZombie4"));
}




// wake specific target - remove lying down effect
void WakeTarget(object oTarget)
{
    SetCommandable(TRUE, oTarget);
    AssignCommand(oTarget, ClearAllActions());
    AssignCommand(oTarget, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE_DRUNK,1.0,1.0));

    // apply visual "wake up" effect
    //ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUND_BURST), GetLocation(oTarget));
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_EPIC_UNDEAD), GetLocation(oTarget));

    // Have zombie's attack
    AssignCommand(oTarget, ActionDoCommand(DetermineCombatRound()));
}
