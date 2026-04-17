/**
 * 通话模块常量定义
 * 对应Flutter constants.dart
 */
export class CallConstants {
  static readonly groupCallMaxUserCount: number = 9;
  static readonly roomIdMaxValue: number = 2147483647; // 2^31 - 1
  static readonly spKeyEnableMuteMode: string = 'enableMuteMode';
  static readonly defaultAvatar: string =
    'https://dldir1.qq.com/hudongzhibo/TUIKit/resource/picture/user_default_icon.png';
  static readonly blurLevelHigh: number = 3;
  static readonly blurLevelClose: number = 0;
}
