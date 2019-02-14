// gp_forgemagic_ca
/*
    forge magic weapons on spell cast
*/
// ChazM 12/15/05
// ChazM 3/28/06 Crafting call interface change

#include "ginc_crafting"

void main()
{
    int iSpellID = GetLastSpell(); // returns the SPELL_* that was cast.
    object oCaster = GetLastSpellCaster(); // returns the object that cast the spell.
    output ("iSpellID = " + IntToString(iSpellID), oCaster);
    //output ("iSpellID = " + IntToString(iSpellID));
    DoMagicCrafting(iSpellID, oCaster);
}