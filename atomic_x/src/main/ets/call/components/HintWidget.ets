/**
 * 通话状态提示组件
 * 对应Flutter的HintWidget
 */
import {
  CallStore,
  CallMediaType,
  CallParticipantStatus,
  CallParticipantInfo,
  NetworkQuality,
} from '../common/CallStore';
import { CallColors } from '../common/CallColors';

@Component
export struct HintWidget {
  @ObjectLink callStore: CallStore;
  // 已接通提示显示追踪
  @State private hadShowAcceptText: boolean = false;
  @State private showAcceptText: boolean = false;
  private currentCallId: string = '';
  private acceptTextTimerId: number = -1;

  aboutToDisappear() {
    if (this.acceptTextTimerId !== -1) {
      clearTimeout(this.acceptTextTimerId);
    }
  }

  build() {
    Column() {
      if (this.shouldShowConnectionHint()) {
        // 已接通提示
        Text($r('app.string.call_connected'))
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(CallColors.colorG7)
      } else if (this.shouldShowStatusHint()) {
        // 等待/邀请提示
        Text(this.getStatusHintText())
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getHintTextColor())
      } else if (this.hasNetworkQualityHint()) {
        // 网络质量提示
        Text(this.getNetworkQualityHintText())
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getHintTextColor())
      }
    }
  }

  /**
   * 是否显示已接通提示
   */
  private shouldShowConnectionHint(): boolean {
    const selfInfo = this.callStore.selfInfo;
    const callId = this.callStore.activeCall.callId;

    if (selfInfo.status !== CallParticipantStatus.accept) {
      return false;
    }

    if (this.currentCallId !== callId) {
      this.currentCallId = callId;
      this.hadShowAcceptText = false;
    }

    if (this.hadShowAcceptText) {
      return false;
    }

    // 启动定时器，1秒后隐藏
    if (this.acceptTextTimerId === -1) {
      this.acceptTextTimerId = setTimeout(() => {
        this.hadShowAcceptText = true;
        this.acceptTextTimerId = -1;
      }, 1000);
    }

    return true;
  }

  /**
   * 是否显示状态提示
   */
  private shouldShowStatusHint(): boolean {
    return this.callStore.selfInfo.status === CallParticipantStatus.waiting;
  }

  /**
   * 获取状态提示文本
   */
  private getStatusHintText(): Resource {
    const selfInfo = this.callStore.selfInfo;
    const activeCall = this.callStore.activeCall;

    if (selfInfo.id === activeCall.inviterId) {
      return $r('app.string.call_waiting_for_acceptance');
    }

    if (activeCall.mediaType === CallMediaType.audio) {
      return $r('app.string.call_invited_to_audio');
    }
    return $r('app.string.call_invited_to_video');
  }

  /**
   * 是否有网络质量提示
   */
  private hasNetworkQualityHint(): boolean {
    return this.getNetworkQualityHintResource() !== null;
  }

  /**
   * 获取网络质量提示文本
   */
  private getNetworkQualityHintText(): Resource {
    return this.getNetworkQualityHintResource() ?? $r('app.string.call_connected');
  }

  private getNetworkQualityHintResource(): Resource | null {
    const selfInfo = this.callStore.selfInfo;
    const selfNetwork = this.callStore.networkQualities.get(selfInfo.id);

    if (selfNetwork && this.isBadNetwork(selfNetwork)) {
      return $r('app.string.call_self_network_low');
    }

    const entries = Array.from(this.callStore.networkQualities.entries());
    for (const entry of entries) {
      if (entry[0] !== selfInfo.id && this.isBadNetwork(entry[1])) {
        return $r('app.string.call_other_network_low');
      }
    }

    return null;
  }

  private isBadNetwork(quality: NetworkQuality): boolean {
    return quality === NetworkQuality.bad ||
      quality === NetworkQuality.veryBad ||
      quality === NetworkQuality.down;
  }

  private getHintTextColor(): string {
    if (this.callStore.activeCall.mediaType === CallMediaType.video) {
      return CallColors.colorWhite;
    }
    return CallColors.colorG7;
  }
}
