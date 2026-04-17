/**
 * 通话计时器组件
 * 对应Flutter的TimerWidget
 */
import { CallStore, CallMediaType, CallParticipantStatus } from '../common/CallStore';
import { CallColors } from '../common/CallColors';

@Component
export struct TimerWidget {
  // 字体大小
  fontSize: number = 14;
  // 字体粗细
  fontWeight: FontWeight = FontWeight.Normal;
  @ObjectLink callStore: CallStore;

  build() {
    if (this.callStore.selfInfo.status === CallParticipantStatus.accept) {
      Text(this.formatDuration(this.callStore.activeCall.duration))
        .fontSize(this.fontSize)
        .fontWeight(this.fontWeight)
        .fontColor(this.callStore.activeCall.mediaType === CallMediaType.audio
          ? CallColors.colorG7
          : CallColors.colorWhite)
    }
  }

  /**
   * 格式化通话时长
   */
  private formatDuration(timeCount: number): string {
    const hour = Math.floor(timeCount / 3600);
    const minute = Math.floor((timeCount % 3600) / 60);
    const second = timeCount % 60;
    const minuteShow = minute <= 9 ? `0${minute}` : `${minute}`;
    const secondShow = second <= 9 ? `0${second}` : `${second}`;

    if (hour > 0) {
      const hourShow = hour <= 9 ? `0${hour}` : `${hour}`;
      return `${hourShow}:${minuteShow}:${secondShow}`;
    }
    return `${minuteShow}:${secondShow}`;
  }
}
