/**
 * 单人通话控制组件
 * 对应Flutter的SingleCallControlsWidget
 * 根据通话类型（音频/视频）和角色（主叫/被叫）及状态（等待/已接听）显示不同的控制按钮
 */
import { ControlsButton } from './ControlsButton';
import {
  CallStore,
  DeviceStore,
  CallMediaType,
  CallParticipantStatus,
  AudioRoute,
  DeviceStatus,
} from '../common/CallStore';
import { CallColors } from '../common/CallColors';

@Component
export struct SingleCallControlsWidget {
  @ObjectLink callStore: CallStore;
  @ObjectLink deviceStore: DeviceStore;

  build() {
    Column() {
      if (this.callStore.activeCall.mediaType !== null) {
        if (this.callStore.selfInfo.id === this.callStore.activeCall.inviterId) {
          // 主叫方
          this.CallerView()
        } else {
          // 被叫方
          this.CalleeView()
        }
      }
    }
  }

  /**
   * 主叫方视图
   */
  @Builder
  CallerView() {
    if (this.callStore.selfInfo.status === CallParticipantStatus.waiting) {
      if (this.callStore.activeCall.mediaType === CallMediaType.video) {
        // 视频通话 - 主叫等待中
        this.VideoCallerWaitingView()
      } else {
        // 语音通话 - 主叫等待中
        this.AudioCallerWaitingView()
      }
    } else if (this.callStore.selfInfo.status === CallParticipantStatus.accept) {
      if (this.callStore.activeCall.mediaType === CallMediaType.video) {
        // 视频通话 - 已接听
        this.VideoAcceptedView()
      } else {
        // 语音通话 - 已接听
        this.AudioAcceptedView()
      }
    }
  }

  /**
   * 被叫方视图
   */
  @Builder
  CalleeView() {
    if (this.callStore.selfInfo.status === CallParticipantStatus.waiting) {
      // 被叫等待中（音频和视频通用）
      this.CalleeWaitingView()
    } else if (this.callStore.selfInfo.status === CallParticipantStatus.accept) {
      if (this.callStore.activeCall.mediaType === CallMediaType.video) {
        this.VideoAcceptedView()
      } else {
        this.AudioAcceptedView()
      }
    }
  }

  /**
   * 视频通话 - 主叫等待视图
   */
  @Builder
  VideoCallerWaitingView() {
    Row() {
      // 翻转摄像头
      ControlsButton({
        imgUrl: $rawfile('call/switch_camera_group.png'),
        tips: getContext(this).resourceManager.getStringSync($r('app.string.call_switch_camera')),
        textColor: CallColors.colorG7,
        imgHeight: 60,
        onBtnTap: () => {
          this.deviceStore.switchCamera(!this.deviceStore.isFrontCamera);
        },
      })

      // 挂断
      ControlsButton({
        imgUrl: $rawfile('call/hangup.png'),
        tips: getContext(this).resourceManager.getStringSync($r('app.string.call_hangup')),
        textColor: CallColors.colorG7,
        imgHeight: 60,
        onBtnTap: () => {
          this.callStore.hangup();
        },
      })

      // 摄像头开关
      ControlsButton({
        imgUrl: this.deviceStore.cameraStatus === DeviceStatus.on
          ? $rawfile('call/camera_on.png')
          : $rawfile('call/camera_off.png'),
        tips: this.deviceStore.cameraStatus === DeviceStatus.on
          ? getContext(this).resourceManager.getStringSync($r('app.string.call_camera_on'))
          : getContext(this).resourceManager.getStringSync($r('app.string.call_camera_off')),
        textColor: CallColors.colorG7,
        imgHeight: 60,
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
  }

  /**
   * 被叫等待视图（音频和视频通用）
   */
  @Builder
  CalleeWaitingView() {
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

  /**
   * 语音通话 - 主叫等待/已接听视图
   */
  @Builder
  AudioCallerWaitingView() {
    Row() {
      // 麦克风
      this.MicButton()

      // 挂断
      ControlsButton({
        imgUrl: $rawfile('call/hangup.png'),
        tips: getContext(this).resourceManager.getStringSync($r('app.string.call_hangup')),
        textColor: CallColors.colorG7,
        imgHeight: 60,
        onBtnTap: () => {
          this.callStore.hangup();
        },
      })

      // 扬声器
      this.SpeakerButton()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  /**
   * 语音通话 - 已接听视图
   */
  @Builder
  AudioAcceptedView() {
    Row() {
      this.MicButton()

      ControlsButton({
        imgUrl: $rawfile('call/hangup.png'),
        tips: getContext(this).resourceManager.getStringSync($r('app.string.call_hangup')),
        textColor: CallColors.colorG7,
        imgHeight: 60,
        onBtnTap: () => {
          this.callStore.hangup();
        },
      })

      this.SpeakerButton()
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  /**
   * 视频通话 - 已接听视图
   */
  @Builder
  VideoAcceptedView() {
    Column() {
      // 第一行：麦克风、扬声器、摄像头
      Row() {
        this.MicButton()
        this.SpeakerButton()
        this.CameraButton()
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)

      // 第二行：占位、挂断、切换摄像头
      Row() {
        Column().width(100)

        ControlsButton({
          imgUrl: $rawfile('call/hangup.png'),
          tips: getContext(this).resourceManager.getStringSync($r('app.string.call_hangup')),
          textColor: CallColors.colorG7,
          imgHeight: 60,
          onBtnTap: () => {
            this.callStore.hangup();
          },
        })

        if (this.deviceStore.cameraStatus === DeviceStatus.on) {
          ControlsButton({
            imgUrl: $rawfile('call/switch_camera.png'),
            tips: '',
            textColor: CallColors.colorG7,
            imgHeight: 28,
            onBtnTap: () => {
              this.deviceStore.switchCamera(!this.deviceStore.isFrontCamera);
            },
          })
        } else {
          Column().width(100)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ top: 20 })
    }
  }

  /**
   * 麦克风按钮
   */
  @Builder
  MicButton() {
    ControlsButton({
      imgUrl: this.deviceStore.microphoneStatus === DeviceStatus.on
        ? $rawfile('call/mute.png')
        : $rawfile('call/mute_on.png'),
      tips: this.deviceStore.microphoneStatus === DeviceStatus.on
        ? getContext(this).resourceManager.getStringSync($r('app.string.call_mic_on'))
        : getContext(this).resourceManager.getStringSync($r('app.string.call_mic_off')),
      textColor: CallColors.colorG7,
      imgHeight: 60,
      onBtnTap: () => {
        if (this.deviceStore.microphoneStatus === DeviceStatus.on) {
          this.deviceStore.closeLocalMicrophone();
        } else {
          this.deviceStore.openLocalMicrophone();
        }
      },
    })
  }

  /**
   * 扬声器按钮
   */
  @Builder
  SpeakerButton() {
    ControlsButton({
      imgUrl: this.deviceStore.currentAudioRoute === AudioRoute.speakerphone
        ? $rawfile('call/handsfree_on.png')
        : $rawfile('call/handsfree.png'),
      tips: this.deviceStore.currentAudioRoute === AudioRoute.speakerphone
        ? getContext(this).resourceManager.getStringSync($r('app.string.call_speaker_on'))
        : getContext(this).resourceManager.getStringSync($r('app.string.call_speaker_off')),
      textColor: CallColors.colorG7,
      imgHeight: 60,
      onBtnTap: () => {
        if (this.deviceStore.currentAudioRoute === AudioRoute.speakerphone) {
          this.deviceStore.setAudioRoute(AudioRoute.earpiece);
        } else {
          this.deviceStore.setAudioRoute(AudioRoute.speakerphone);
        }
      },
    })
  }

  /**
   * 摄像头按钮
   */
  @Builder
  CameraButton() {
    ControlsButton({
      imgUrl: this.deviceStore.cameraStatus === DeviceStatus.on
        ? $rawfile('call/camera_on.png')
        : $rawfile('call/camera_off.png'),
      tips: this.deviceStore.cameraStatus === DeviceStatus.on
        ? getContext(this).resourceManager.getStringSync($r('app.string.call_camera_on'))
        : getContext(this).resourceManager.getStringSync($r('app.string.call_camera_off')),
      textColor: CallColors.colorG7,
      imgHeight: 60,
      onBtnTap: () => {
        if (this.deviceStore.cameraStatus === DeviceStatus.on) {
          this.deviceStore.closeLocalCamera();
        } else {
          this.deviceStore.openLocalCamera(this.deviceStore.isFrontCamera);
        }
      },
    })
  }
}
