import { Preference } from '../common/Preference'
import { CallBellFeature } from '../manager/feature/CallBellFeature'

export class GlobalState {
  enableMuteMode: Boolean = Preference.getInstance(CallBellFeature.PROFILE_TUICALLKIT)
    .getBoolean(CallBellFeature.PROFILE_MUTE_MODE, false)
  enableFloatWindow: Boolean = true
  enableVirtualBackground: Boolean = false
}

export default new GlobalState()
