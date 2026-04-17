/**
 * 通话主视图
 * 对应Flutter的CallView
 * 根据通话类型（单人/多人）自动切换浮动布局或网格布局
 */
import {
  CallStore,
  DeviceStore,
  CallMediaType,
  AudioRoute,
} from '../common/CallStore';
import { CallFloatWidget } from './CallFloatWidget';
import { CallGridWidget } from './CallGridWidget';

@Component
export struct CallView {
  @ObjectLink callStore: CallStore;
  @ObjectLink deviceStore: DeviceStore;

  aboutToAppear() {
    // 初始化设备：打开麦克风
    this.deviceStore.openLocalMicrophone();

    // 根据通话类型设置音频路由
    if (this.callStore.activeCall.mediaType === CallMediaType.audio) {
      this.deviceStore.setAudioRoute(AudioRoute.earpiece);
    } else {
      this.deviceStore.setAudioRoute(AudioRoute.speakerphone);
    }

    // 视频通话时打开摄像头
    if (this.callStore.activeCall.mediaType === CallMediaType.video) {
      this.deviceStore.openLocalCamera(true);
    }

    console.info('[CallView] 通话视图初始化完成');
  }

  aboutToDisappear() {
    // 关闭麦克风
    this.deviceStore.closeLocalMicrophone();
    console.info('[CallView] 通话视图销毁');
  }

  build() {
    Column() {
      if (this.isGroupCall()) {
        // 群组通话 - 网格布局
        CallGridWidget({
          callStore: this.callStore,
          deviceStore: this.deviceStore,
        })
      } else {
        // 单人通话 - 浮动布局
        CallFloatWidget({
          callStore: this.callStore,
          deviceStore: this.deviceStore,
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 判断是否为群组通话
   */
  private isGroupCall(): boolean {
    return this.callStore.activeCall.chatGroupId.length > 0 ||
      this.callStore.activeCall.inviteeIds.length > 1;
  }
}
