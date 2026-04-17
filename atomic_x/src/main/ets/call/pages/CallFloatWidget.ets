/**
 * 单人通话浮动布局视图
 * 对应Flutter的CallFloatWidget
 * 用于1v1通话场景，显示远端用户信息、通话提示、控制按钮
 */
import {
  CallStore,
  DeviceStore,
  CallMediaType,
  CallParticipantStatus,
  CallParticipantInfo,
} from '../common/CallStore';
import { CallColors } from '../common/CallColors';
import { CallConstants } from '../common/CallConstants';
import { SingleCallControlsWidget } from '../components/SingleCallControlsWidget';
import { HintWidget } from '../components/HintWidget';
import { TimerWidget } from '../components/TimerWidget';

@Component
export struct CallFloatWidget {
  @ObjectLink callStore: CallStore;
  @ObjectLink deviceStore: DeviceStore;

  build() {
    Stack() {
      // 背景色
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#1A1A2E')

      // 远端用户信息（音频通话或视频通话等待中时显示）
      if (this.shouldShowUserInfo()) {
        this.UserInfoView()
      }

      // 通话提示（位于屏幕2/3处）
      Column() {
        HintWidget({ callStore: this.callStore })
      }
      .width('100%')
      .position({ y: '66%' })
      .alignItems(HorizontalAlign.Center)

      // 计时器（顶部）
      Column() {
        TimerWidget({
          callStore: this.callStore,
        })
      }
      .width('100%')
      .height(100)
      .position({ y: 20 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 控制按钮（底部）
      Column() {
        SingleCallControlsWidget({
          callStore: this.callStore,
          deviceStore: this.deviceStore,
        })
      }
      .width('100%')
      .position({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 是否显示用户信息
   * 视频通话已接听时不显示（因为有视频画面）
   */
  private shouldShowUserInfo(): boolean {
    if (this.callStore.activeCall.mediaType === CallMediaType.video &&
      this.callStore.selfInfo.status === CallParticipantStatus.accept) {
      return false;
    }
    return true;
  }

  /**
   * 远端用户信息视图
   */
  @Builder
  UserInfoView() {
    Column() {
      // 远端用户头像
      Image(this.getRemoteUserAvatar())
        .width(100)
        .height(100)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .alt($rawfile('call/user_icon.png'))

      // 远端用户名称
      Text(this.getRemoteUserDisplayName())
        .fontSize(18)
        .fontColor(this.getUserNameColor())
        .fontWeight(FontWeight.Bold)
        .margin({ top: 10 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .position({ y: '25%' })
  }

  /**
   * 获取远端用户头像
   */
  private getRemoteUserAvatar(): string {
    const remote = this.getRemoteParticipant();
    if (remote) {
      return remote.avatarURL || CallConstants.defaultAvatar;
    }
    return CallConstants.defaultAvatar;
  }

  /**
   * 获取远端用户显示名称
   */
  private getRemoteUserDisplayName(): string {
    const remote = this.getRemoteParticipant();
    if (remote) {
      return remote.getDisplayName();
    }
    return '';
  }

  /**
   * 获取远端参与者
   */
  private getRemoteParticipant(): CallParticipantInfo | null {
    for (const participant of this.callStore.allParticipants) {
      if (participant.id !== this.callStore.selfInfo.id) {
        return participant;
      }
    }
    return null;
  }

  /**
   * 获取用户名颜色
   */
  private getUserNameColor(): string {
    return this.callStore.activeCall.mediaType === CallMediaType.audio
      ? CallColors.colorG7
      : CallColors.colorWhite;
  }
}
