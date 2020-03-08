// ga_cast_fake_spell_at_object(float fSecondsDelay, string sCaster, int nSpell, string sSpellTarget, int nProjectilePathType)
/*
	Description:
	Has sCaster appear to cast a spell at sSpellTarget, but with no resulting effects.

	Parameters:
		float fSecondsDelay		- Delay before casting
		string sCaster			- The caster's tag or identifier, if blank use Dialog Owner. see "ginc_param_const" for TARGET_* constants
		int nSpell				- spell ID. see NWSCRIPT.nss for SPELL_* constants
		string sSpellTarget		- The caster's tag or identifier, if blank use PC Speaker. see "ginc_param_const" for TARGET_* constants
		int nProjectilePathType	- 0 = PROJECTILE_PATH_TYPE_DEFAULT. see NWSCRIPT.nss for PROJECTILE_PATH_TYPE_* constants

*/
// ChazM 4/26/07

#include "ginc_param_const"

void main(float fSecondsDelay, string sCaster, int nSpell, string sSpellTarget, int nProjectilePathType)
{
	object oCaster = GetTarget(sCaster, TARGET_OWNER);
	object oSpellTarget = GetTarget(sSpellTarget, TARGET_PC_SPEAKER);

	AssignCommand(oCaster, DelayCommand(fSecondsDelay, ActionCastFakeSpellAtObject(nSpell, oSpellTarget, nProjectilePathType)));
}
