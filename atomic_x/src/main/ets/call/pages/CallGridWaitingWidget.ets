/**
 * 群组通话等待视图
 * 对应Flutter的CallGridWaitingWidget
 * 显示主叫方信息和其他被邀请者头像列表
 */
import {
  CallStore,
  CallParticipantInfo,
} from '../common/CallStore';
import { CallColors } from '../common/CallColors';
import { CallConstants } from '../common/CallConstants';

@Component
export struct CallGridWaitingWidget {
  @ObjectLink callStore: CallStore;

  build() {
    Column() {
      // 主叫方信息
      this.CallerInfoView()

      // 邀请提示
      Text($r('app.string.call_invited_to_group'))
        .fontSize(16)
        .fontColor(CallColors.colorG5)

      // 间距
      Column().height(50)

      // 其他被邀请者列表
      this.InviteeListView()
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 主叫方信息视图
   */
  @Builder
  CallerInfoView() {
    Column() {
      // 主叫方头像
      Image(this.getCallerAvatar())
        .width(120)
        .height(120)
        .borderRadius(15)
        .objectFit(ImageFit.Cover)
        .margin({ top: 150 })
        .alt($rawfile('call/user_icon.png'))

      // 主叫方名称
      Text(this.getCallerDisplayName())
        .fontSize(24)
        .fontColor(CallColors.colorG7)
        .margin({ top: 10, bottom: 10 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 被邀请者列表视图
   */
  @Builder
  InviteeListView() {
    Column() {
      if (this.getInviteeAvatarList().length > 0) {
        Text($r('app.string.call_they_are_also_there'))
          .fontSize(15)
          .fontColor(CallColors.colorG5)

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
          ForEach(this.getInviteeAvatarList(), (avatarUrl: string) => {
            Image(avatarUrl || CallConstants.defaultAvatar)
              .width(30)
              .height(30)
              .borderRadius(5)
              .objectFit(ImageFit.Cover)
              .margin(2.5)
              .alt($rawfile('call/user_icon.png'))
          })
        }
        .margin({ top: 10 })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  /**
   * 获取主叫方头像
   */
  private getCallerAvatar(): string {
    const inviterId = this.callStore.activeCall.inviterId;
    for (const participant of this.callStore.allParticipants) {
      if (participant.id === inviterId) {
        return participant.avatarURL || CallConstants.defaultAvatar;
      }
    }
    return CallConstants.defaultAvatar;
  }

  /**
   * 获取主叫方显示名称
   */
  private getCallerDisplayName(): string {
    const inviterId = this.callStore.activeCall.inviterId;
    for (const participant of this.callStore.allParticipants) {
      if (participant.id === inviterId) {
        return participant.getDisplayName();
      }
    }
    return inviterId;
  }

  /**
   * 获取被邀请者头像列表（排除自己和主叫方）
   */
  private getInviteeAvatarList(): string[] {
    const result: string[] = [];
    for (const participant of this.callStore.allParticipants) {
      if (participant.id !== this.callStore.selfInfo.id &&
        participant.id !== this.callStore.activeCall.inviterId) {
        result.push(participant.avatarURL);
      }
    }
    return result;
  }
}
