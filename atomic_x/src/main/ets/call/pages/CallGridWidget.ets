/**
 * 多人通话网格布局视图
 * 对应Flutter的CallGridWidget
 * 用于群组通话场景，显示参与者网格、控制按钮
 */
import {
  CallStore,
  DeviceStore,
  CallParticipantStatus,
  CallParticipantInfo,
} from '../common/CallStore';
import { CallColors } from '../common/CallColors';
import { CallConstants } from '../common/CallConstants';
import { MultiCallControlsWidget } from '../components/MultiCallControlsWidget';
import { TimerWidget } from '../components/TimerWidget';
import { CallGridWaitingWidget } from './CallGridWaitingWidget';

@Component
export struct CallGridWidget {
  @ObjectLink callStore: CallStore;
  @ObjectLink deviceStore: DeviceStore;
  @State controlsHeight: number = 115;

  build() {
    Stack() {
      // 背景：自身头像模糊
      Image(this.callStore.selfInfo.avatarURL || CallConstants.defaultAvatar)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .alt($rawfile('call/user_icon.png'))

      // 半透明遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(45, 45, 45, 0.9)')

      // 根据状态显示不同内容
      if (this.isReceivedGroupCallWaiting()) {
        // 被叫等待视图
        CallGridWaitingWidget({ callStore: this.callStore })
      } else {
        // 参与者网格视图
        this.ParticipantsGridView()
      }

      // 计时器（顶部）
      Column() {
        TimerWidget({
          callStore: this.callStore,
          fontSize: 18,
          fontWeight: FontWeight.Medium,
        })
      }
      .width('100%')
      .height(100)
      .position({ y: 20 })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 控制按钮（底部）
      Column() {
        MultiCallControlsWidget({
          callStore: this.callStore,
          deviceStore: this.deviceStore,
          onHeightChanged: (height: number) => {
            this.controlsHeight = height;
          },
        })
      }
      .width('100%')
      .position({ bottom: 0 })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 是否为被叫等待状态
   */
  private isReceivedGroupCallWaiting(): boolean {
    return this.callStore.selfInfo.id !== this.callStore.activeCall.inviterId &&
      this.callStore.selfInfo.status === CallParticipantStatus.waiting;
  }

  /**
   * 参与者网格视图
   */
  @Builder
  ParticipantsGridView() {
    Column() {
      Grid() {
        ForEach(this.callStore.allParticipants, (participant: CallParticipantInfo) => {
          GridItem() {
            this.ParticipantCell(participant)
          }
        })
      }
      .columnsTemplate(this.getGridColumnsTemplate())
      .rowsGap(4)
      .columnsGap(4)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 90, bottom: this.controlsHeight })
    .padding(4)
  }

  /**
   * 单个参与者单元格
   */
  @Builder
  ParticipantCell(participant: CallParticipantInfo) {
    Stack({ alignContent: Alignment.Bottom }) {
      // 头像背景
      Image(participant.avatarURL || CallConstants.defaultAvatar)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .alt($rawfile('call/user_icon.png'))

      // 用户名标签
      Text(participant.getDisplayName())
        .fontSize(12)
        .fontColor(CallColors.colorWhite)
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(4)
        .margin({ bottom: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .aspectRatio(1)
    .borderRadius(8)
    .clip(true)
  }

  /**
   * 根据参与者数量计算网格列数
   */
  private getGridColumnsTemplate(): string {
    const count = this.callStore.allParticipants.length;
    if (count <= 2) {
      return '1fr 1fr';
    } else if (count <= 4) {
      return '1fr 1fr';
    } else {
      return '1fr 1fr 1fr';
    }
  }
}
