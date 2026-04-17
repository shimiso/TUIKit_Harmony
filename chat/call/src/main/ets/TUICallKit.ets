import { TUICallParams } from 'rtcroomengine';

export abstract class TUICallKit {

  /**
   * Set user profile
   * @param nickname: User name, which can contain up to 500 bytes
   * @param avatar:   User profile photo URL, which can contain up to 500 bytes
   * For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
   * @returns
   */
  abstract setSelfInfo(nickname: string, avatar: string): Promise<void>;

  abstract login(sdkAppId: number, userId: string, userSig: string): Promise<void>;
  /**
   * Make a 1VN calls
   * @param userIdList: List of userId
   * @param mediaType: Call media type
   * @param params: Extension param: eg: offlinePushInfo
   * @returns
   */
  abstract calls(userIdList: string[], mediaType: number,
    params: TUICallParams | null): Promise<void>;

  /**
   * Join a current call
   * @param callId: current call Id
   * @returns
   */
  abstract join(callId: string): Promise<void>;

  /**
   *
   * @param filePath:  only support uri or rawFile in the app.
   * test uri: setCallingBell("https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/calling-bell-1.mp3")
   * test raw file: setCallingBell('rain.mp3')
   * ohos did not support to access to data/local/tmp/ directory.
   */
  abstract setCallingBell(filePath: string);

  /**
   *
   * @param enable Enable the mute mode (the callee doesn't ring)
   */
  abstract enableMuteMode(enable: boolean);

  /**
   * Enable Virtual Background
   * @param enable
   */
  abstract enableVirtualBackground(enable: boolean);
}