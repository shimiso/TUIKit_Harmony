/**
 * 多人通话控制组件
 * 对应Flutter的MultiCallControlsWidget
 * 支持展开/收起动画效果
 */
import { ControlsButton } from './ControlsButton';
import {
  CallStore,
  DeviceStore,
  CallParticipantStatus,
  AudioRoute,
  DeviceStatus,
} from '../common/CallStore';
import { CallColors } from '../common/CallColors';

@Component
export struct MultiCallControlsWidget {
  @ObjectLink callStore: CallStore;
  @ObjectLink deviceStore: DeviceStore;
  @State isFunctionExpand: boolean = false;
  onHeightChanged: ((height: number) => void) | null = null;

  private readonly bigBtnHeight: number = 56;
  private readonly smallBtnHeight: number = 42;
  private readonly animDuration: number = 300;

  build() {
    Column() {
      if (this.callStore.selfInfo.status === CallParticipantStatus.waiting &&
        this.callStore.selfInfo.id !== this.callStore.activeCall.inviterId) {
        // 被叫等待视图
        this.WaitingView()
      } else {
        // 已接听视图
        this.AcceptedView()
      }
    }
  }

  /**
   * 被叫等待视图
   */
  @Builder
  WaitingView() {
    Column() {
      Row() {
        // 拒绝
        ControlsButton({
          imgUrl: $rawfile('call/hangup.png'),
          tips: getContext(this).resourceManager.getStringSync($r('app.string.call_hangup')),
          textColor: CallColors.colorG7,
          imgHeight: 60,
          onBtnTap: () => {
            this.callStore.reject();
          },
        })

        // 接听
        ControlsButton({
          imgUrl: $rawfile('call/dialing.png'),
          tips: getContext(this).resourceManager.getStringSync($r('app.string.call_accept')),
          textColor: CallColors.colorG7,
          imgHeight: 60,
          onBtnTap: () => {
            this.callStore.accept();
          },
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .padding({ bottom: 40 })
  }

  /**
   * 已接听视图（支持展开/收起）
   */
  @Builder
  AcceptedView() {
    Column() {
      // 展开/收起箭头
      Row() {
        Image($rawfile('call/arrow.png'))
          .width(this.smallBtnHeight)
          .height(this.smallBtnHeight)
          .rotate({ angle: this.isFunctionExpand ? 0 : 180 })
          .animation({ duration: this.animDuration, curve: Curve.EaseInOut })
          .onClick(() => {
            this.isFunctionExpand = !this.isFunctionExpand;
            if (this.onHeightChanged) {
              this.onHeightChanged(this.isFunctionExpand ? 210 : 115);
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding({ left: 20 })

      if (this.isFunctionExpand) {
        // 展开状态：两行按钮
        this.ExpandedControls()
      } else {
        // 收起状态：一行按钮
        this.CollapsedControls()
      }
    }
    .width('100%')
    .height(this.isFunctionExpand ? 210 : 115)
    .backgroundColor(CallColors.colorControlsBg)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .animation({ duration: this.animDuration, curve: Curve.EaseInOut })
    .gesture(
      PanGesture({ direction: PanDirection.Vertical })
        .onActionUpdate((event: GestureEvent) => {
          if (event.offsetY < 0 && !this.isFunctionExpand) {
            this.isFunctionExpand = true;
            if (this.onHeightChanged) {
              this.onHeightChanged(210);
            }
          } else if (event.offsetY > 0 && this.isFunctionExpand) {
            this.isFunctionExpand = false;
            if (this.onHeightChanged) {
              this.onHeightChanged(115);
            }
          }
        })
    )
  }

  /**
   * 展开状态控制按钮
   */
  @Builder
  ExpandedControls() {
    Column() {
      // 第一行：麦克风、扬声器、摄像头
      Row() {
        // 麦克风
        ControlsButton({
          imgUrl: this.deviceStore.microphoneStatus === DeviceStatus.on
            ? $rawfile('call/mute.png')
            : $rawfile('call/mute_on.png'),
          tips: this.deviceStore.microphoneStatus === DeviceStatus.on
            ? getContext(this).resourceManager.getStringSync($r('app.string.call_mic_on'))
            : getContext(this).resourceManager.getStringSync($r('app.string.call_mic_off')),
          textColor: CallColors.colorG7,
          imgHeight: this.bigBtnHeight,
          onBtnTap: () => {
            if (this.deviceStore.microphoneStatus === DeviceStatus.on) {
              this.deviceStore.closeLocalMicrophone();
            } else {
              this.deviceStore.openLocalMicrophone();
            }
          },
        })

        // 扬声器
        ControlsButton({
          imgUrl: this.deviceStore.currentAudioRoute === AudioRoute.speakerphone
            ? $rawfile('call/handsfree_on.png')
            : $rawfile('call/handsfree.png'),
          tips: this.deviceStore.currentAudioRoute === AudioRoute.speakerphone
            ? getContext(this).resourceManager.getStringSync($r('app.string.call_speaker_on'))
            : getContext(this).resourceManager.getStringSync($r('app.string.call_speaker_off')),
          textColor: CallColors.colorG7,
          imgHeight: this.bigBtnHeight,
          onBtnTap: () => {
            if (this.deviceStore.currentAudioRoute === AudioRoute.speakerphone) {
              this.deviceStore.setAudioRoute(AudioRoute.earpiece);
            } else {
              this.deviceStore.setAudioRoute(AudioRoute.speakerphone);
            }
          },
        })

        // 摄像头
        ControlsButton({
          imgUrl: this.deviceStore.cameraStatus === DeviceStatus.on
            ? $rawfile('call/camera_on.png')
            : $rawfile('call/camera_off.png'),
          tips: this.deviceStore.cameraStatus === DeviceStatus.on
            ? getContext(this).resourceManager.getStringSync($r('app.string.call_camera_on'))
            : getContext(this).resourceManager.getStringSync($r('app.string.call_camera_off')),
          textColor: CallColors.colorG7,
          imgHeight: this.bigBtnHeight,
          onBtnTap: () => {
            if (this.deviceStore.cameraStatus === DeviceStatus.on) {
              this.deviceStore.closeLocalCamera();
            } else {
              this.deviceStore.openLocalCamera(this.deviceStore.isFrontCamera);
            }
          },
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)

      // 第二行：挂断
      Row() {
        ControlsButton({
          imgUrl: $rawfile('call/hangup.png'),
          tips: '',
          textColor: CallColors.colorG7,
          imgHeight: this.bigBtnHeight,
          onBtnTap: () => {
            this.callStore.hangup();
          },
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 8 })
    }
  }

  /**
   * 收起状态控制按钮
   */
  @Builder
  CollapsedControls() {
    Row() {
      // 麦克风（小图标）
      ControlsButton({
        imgUrl: this.deviceStore.microphoneStatus === DeviceStatus.on
          ? $rawfile('call/mute.png')
          : $rawfile('call/mute_on.png'),
        tips: '',
        textColor: CallColors.colorG7,
        imgHeight: this.smallBtnHeight,
        onBtnTap: () => {
          if (this.deviceStore.microphoneStatus === DeviceStatus.on) {
            this.deviceStore.closeLocalMicrophone();
          } else {
            this.deviceStore.openLocalMicrophone();
          }
        },
      })

      // 扬声器（小图标）
      ControlsButton({
        imgUrl: this.deviceStore.currentAudioRoute === AudioRoute.speakerphone
          ? $rawfile('call/handsfree_on.png')
          : $rawfile('call/handsfree.png'),
        tips: '',
        textColor: CallColors.colorG7,
        imgHeight: this.smallBtnHeight,
        onBtnTap: () => {
          if (this.deviceStore.currentAudioRoute === AudioRoute.speakerphone) {
            this.deviceStore.setAudioRoute(AudioRoute.earpiece);
          } else {
            this.deviceStore.setAudioRoute(AudioRoute.speakerphone);
          }
        },
      })

      // 摄像头（小图标）
      ControlsButton({
        imgUrl: this.deviceStore.cameraStatus === DeviceStatus.on
          ? $rawfile('call/camera_on.png')
          : $rawfile('call/camera_off.png'),
        tips: '',
        textColor: CallColors.colorG7,
        imgHeight: this.smallBtnHeight,
        onBtnTap: () => {
          if (this.deviceStore.cameraStatus === DeviceStatus.on) {
            this.deviceStore.closeLocalCamera();
          } else {
            this.deviceStore.openLocalCamera(this.deviceStore.isFrontCamera);
          }
        },
      })

      // 挂断（小图标）
      ControlsButton({
        imgUrl: $rawfile('call/hangup.png'),
        tips: '',
        textColor: CallColors.colorG7,
        imgHeight: this.smallBtnHeight,
        onBtnTap: () => {
          this.callStore.hangup();
        },
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding({ bottom: 16 })
  }
}
