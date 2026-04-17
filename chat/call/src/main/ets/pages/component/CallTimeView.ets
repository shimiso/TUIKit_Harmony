import { CallManager } from '../../manager/CallManager'
import { formatSecondsTo00 } from '../../common/Time'

@ComponentV2
export struct CallTimeView {
  build() {
    Column() {
      Text(this.getCallTime()).fontColor($r('app.color.callkit_color_white')).fontSize(16)
        .visibility(CallManager.getInstance().callState.callDuration > 0 ? Visibility.Visible : Visibility.Hidden)
    }
  }

  private getCallTime(): string {
    return formatSecondsTo00(CallManager.getInstance().callState.callDuration)
  }
}