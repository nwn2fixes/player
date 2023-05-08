// 'ga_cast_fake_spell_at_object'
/*
	Has sCaster appear to cast a spell at sTarget but with no resulting effects.

	float fDelay   - delay before casting
	string sCaster - the caster's tag or identifier (if blank use Dialog Owner)
	                 See 'ginc_param_const' for TARGET_* constants.
	int iSpellId   - spell ID. See NWSCRIPT.nss for SPELL_* constants.
	string sTarget - the caster's tag or identifier (if blank use PC Speaker)
	                 See 'ginc_param_const' for TARGET_* constants.
	int iPathType  - 0 = PROJECTILE_PATH_TYPE_DEFAULT
	                 See NWSCRIPT.nss for PROJECTILE_PATH_TYPE_* constants
*/
// ChazM 4/26/07
// nwn2fixes 2020.03.07 - cast FAKE spell
// nwn2fixes 2023.05.05 - add ActionPauseCutscene() so dialog doesn't break

#include "ginc_param_const"

//
void main(float fDelay, string sCaster, int iSpellId, string sTarget, int iPathType)
{
	object oCaster = GetTarget(sCaster, TARGET_OWNER);
	if (GetIsObjectValid(oCaster))
	{
		object oTarget = GetTarget(sTarget, TARGET_PC_SPEAKER);
		if (GetIsObjectValid(oTarget))
		{
			ActionPauseCutscene(FloatToInt(fDelay * 1000)); // nwn2fix - ensure a fakespell fires and dialog continues

			AssignCommand(oCaster, DelayCommand(fDelay, ActionCastFakeSpellAtObject(iSpellId, oTarget, iPathType))); // nwn2fix
		}
	}
}
