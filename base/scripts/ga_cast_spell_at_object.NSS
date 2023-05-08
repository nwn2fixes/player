// 'ga_cast_spell_at_object'
/*
	Has sCaster cast a spell at sTarget.

	float fDelay     - delay before casting
	string sCaster   - the caster's tag or identifier (if blank use Dialog Owner)
					   See "ginc_param_const" for TARGET_* constants.
	int iSpellId     - spell ID. See NWSCRIPT.nss for SPELL_* constants.
	string sTarget   - the target's tag or identifier (if blank use PC Speaker)
					   See 'ginc_param_const' for TARGET_* constants.
	int iMetaMagic   - metamagic to use
					   -1 for the standard default of METAMAGIC_ANY
					    0 = METAMAGIC_NONE
					    See NWSCRIPT.nss for METAMAGIC_* constants.
	int bCheat       - if this is 1 then the executor of the action doesn't have
					   to be able to cast the spell
	int iDomainLevel - should define the caster level (kL_note: This is broken)
	int iPathType    - 0 = PROJECTILE_PATH_TYPE_DEFAULT
					   See NWSCRIPT.nss for PROJECTILE_PATH_TYPE_* constants.
	int bInstant     - if this is 1 the spell is cast immediately
*/
// ChazM 4/26/07
// nwn2fixes 2023.05.06 - add ActionPauseCutscene() so dialog doesn't break
//                      - verify iMetaMagic else default to METAMAGIC_ANY
//                      - check that either Caster has spell memorized or bCheat==TRUE

#include "ginc_param_const"

//
void main(float fDelay, string sCaster, int iSpellId, string sTarget, int iMetaMagic, int bCheat, int iDomainLevel, int iPathType, int bInstant)
{
	object oCaster = GetTarget(sCaster, TARGET_OWNER);
	if (GetIsObjectValid(oCaster))
	{
		if (bCheat || GetHasSpell(iSpellId, oCaster))
		{
			object oTarget = GetTarget(sTarget, TARGET_PC_SPEAKER);
			if (GetIsObjectValid(oTarget))
			{
				ActionPauseCutscene(FloatToInt(fDelay * 1000)); // nwn2fix - ensure a spell fires and dialog continues

				switch (iMetaMagic)
				{
					case   0: iMetaMagic = METAMAGIC_NONE;       break;
					case   1: iMetaMagic = METAMAGIC_EMPOWER;    break;
					case   2: iMetaMagic = METAMAGIC_EXTEND;     break;
					case   4: iMetaMagic = METAMAGIC_MAXIMIZE;   break;
					case   8: iMetaMagic = METAMAGIC_QUICKEN;    break;
					case  16: iMetaMagic = METAMAGIC_SILENT;     break;
					case  32: iMetaMagic = METAMAGIC_STILL;      break;
					case  64: iMetaMagic = METAMAGIC_PERSISTENT; break;
					case 128: iMetaMagic = METAMAGIC_PERMANENT;  break;

					default: iMetaMagic = METAMAGIC_ANY; break;
				}

				AssignCommand(oCaster, DelayCommand(fDelay, ActionCastSpellAtObject(iSpellId, oTarget, iMetaMagic, bCheat, iDomainLevel, iPathType, bInstant)));
			}
		}
		else
			AssignCommand(oCaster, SpeakString("I do not have that spell memorized."));
	}
}
