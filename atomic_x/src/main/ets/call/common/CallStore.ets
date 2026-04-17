/**
 * 通话状态管理
 * 对应Flutter的CallStore、DeviceStore、CallCoreController等
 * 提供通话状态、设备状态的响应式管理
 */

// ==================== 枚举定义 ====================

/**
 * 通话媒体类型
 */
export enum CallMediaType {
  audio = 'audio',
  video = 'video',
}

/**
 * 通话参与者状态
 */
export enum CallParticipantStatus {
  waiting = 'waiting',
  accept = 'accept',
  reject = 'reject',
  timeout = 'timeout',
  leave = 'leave',
}

/**
 * 音频路由
 */
export enum AudioRoute {
  earpiece = 'earpiece',
  speakerphone = 'speakerphone',
}

/**
 * 设备状态
 */
export enum DeviceStatus {
  on = 'on',
  off = 'off',
}

/**
 * 网络质量
 */
export enum NetworkQuality {
  unknown = 'unknown',
  excellent = 'excellent',
  good = 'good',
  poor = 'poor',
  bad = 'bad',
  veryBad = 'veryBad',
  down = 'down',
}

/**
 * 音量等级
 */
export enum VolumeLevel {
  mute = 'mute',
  low = 'low',
  medium = 'medium',
  high = 'high',
  peak = 'peak',
}

// ==================== 数据模型 ====================

/**
 * 通话参与者信息
 */
@Observed
export class CallParticipantInfo {
  id: string = '';
  name: string = '';
  remark: string = '';
  avatarURL: string = '';
  status: CallParticipantStatus = CallParticipantStatus.waiting;

  constructor(id: string, name?: string, avatarURL?: string) {
    this.id = id;
    this.name = name ?? '';
    this.avatarURL = avatarURL ?? '';
  }

  /**
   * 获取显示名称（优先备注 > 昵称 > ID）
   */
  getDisplayName(): string {
    if (this.remark.length > 0) {
      return this.remark;
    } else if (this.name.length > 0) {
      return this.name;
    }
    return this.id;
  }
}

/**
 * 活跃通话信息
 */
@Observed
export class ActiveCallInfo {
  callId: string = '';
  inviterId: string = '';
  inviteeIds: string[] = [];
  chatGroupId: string = '';
  mediaType: CallMediaType | null = null;
  duration: number = 0;

  /**
   * 是否为群组通话
   */
  isGroupCall(): boolean {
    return this.chatGroupId.length > 0 || this.inviteeIds.length > 1;
  }
}

// ==================== CallStore ====================

/**
 * 通话状态管理Store（单例）
 * 对应Flutter的CallStore.shared
 */
@Observed
export class CallStore {
  private static _instance: CallStore | null = null;

  // 当前活跃通话信息
  @Track activeCall: ActiveCallInfo = new ActiveCallInfo();
  // 自身信息
  @Track selfInfo: CallParticipantInfo = new CallParticipantInfo('');
  // 所有参与者
  @Track allParticipants: CallParticipantInfo[] = [];
  // 网络质量映射
  @Track networkQualities: Map<string, NetworkQuality> = new Map();
  // 通话计时器
  private _timerInterval: number = -1;

  private constructor() {
  }

  static get shared(): CallStore {
    if (!CallStore._instance) {
      CallStore._instance = new CallStore();
    }
    return CallStore._instance;
  }

  /**
   * 发起通话
   */
  call(userId: string, mediaType: CallMediaType): void {
    this.activeCall.inviteeIds = [userId];
    this.activeCall.mediaType = mediaType;
    this.activeCall.inviterId = this.selfInfo.id;
    this.selfInfo.status = CallParticipantStatus.waiting;
    console.info(`[CallStore] 发起${mediaType}通话, 目标用户: ${userId}`);
  }

  /**
   * 发起群组通话
   */
  groupCall(groupId: string, userIds: string[], mediaType: CallMediaType): void {
    this.activeCall.chatGroupId = groupId;
    this.activeCall.inviteeIds = userIds;
    this.activeCall.mediaType = mediaType;
    this.activeCall.inviterId = this.selfInfo.id;
    this.selfInfo.status = CallParticipantStatus.waiting;
    console.info(`[CallStore] 发起群组${mediaType}通话, 群ID: ${groupId}, 人数: ${userIds.length}`);
  }

  /**
   * 接听通话
   */
  accept(): void {
    this.selfInfo.status = CallParticipantStatus.accept;
    this._startTimer();
    console.info('[CallStore] 接听通话');
  }

  /**
   * 拒绝通话
   */
  reject(): void {
    this.selfInfo.status = CallParticipantStatus.reject;
    console.info('[CallStore] 拒绝通话');
    this._endCall();
  }

  /**
   * 挂断通话
   */
  hangup(): void {
    console.info('[CallStore] 挂断通话');
    this._endCall();
  }

  /**
   * 重置通话状态
   */
  reset(): void {
    this._stopTimer();
    this.activeCall = new ActiveCallInfo();
    this.selfInfo = new CallParticipantInfo('');
    this.allParticipants = [];
    this.networkQualities = new Map();
  }

  /**
   * 更新参与者信息
   */
  updateParticipant(info: CallParticipantInfo): void {
    const index = this.allParticipants.findIndex(p => p.id === info.id);
    if (index >= 0) {
      this.allParticipants[index] = info;
    } else {
      this.allParticipants.push(info);
    }
    // 触发数组变更
    this.allParticipants = [...this.allParticipants];
  }

  /**
   * 更新网络质量
   */
  updateNetworkQuality(userId: string, quality: NetworkQuality): void {
    this.networkQualities.set(userId, quality);
    this.networkQualities = new Map(this.networkQualities);
  }

  private _startTimer(): void {
    this._stopTimer();
    this._timerInterval = setInterval(() => {
      this.activeCall.duration += 1;
    }, 1000);
  }

  private _stopTimer(): void {
    if (this._timerInterval !== -1) {
      clearInterval(this._timerInterval);
      this._timerInterval = -1;
    }
  }

  private _endCall(): void {
    this._stopTimer();
  }
}

// ==================== DeviceStore ====================

/**
 * 设备状态管理Store（单例）
 * 对应Flutter的DeviceStore.shared
 */
@Observed
export class DeviceStore {
  private static _instance: DeviceStore | null = null;

  // 麦克风状态
  @Track microphoneStatus: DeviceStatus = DeviceStatus.off;
  // 摄像头状态
  @Track cameraStatus: DeviceStatus = DeviceStatus.off;
  // 当前音频路由
  @Track currentAudioRoute: AudioRoute = AudioRoute.earpiece;
  // 是否前置摄像头
  @Track isFrontCamera: boolean = true;

  private constructor() {
  }

  static get shared(): DeviceStore {
    if (!DeviceStore._instance) {
      DeviceStore._instance = new DeviceStore();
    }
    return DeviceStore._instance;
  }

  /**
   * 打开本地麦克风
   */
  openLocalMicrophone(): void {
    this.microphoneStatus = DeviceStatus.on;
    console.info('[DeviceStore] 打开麦克风');
  }

  /**
   * 关闭本地麦克风
   */
  closeLocalMicrophone(): void {
    this.microphoneStatus = DeviceStatus.off;
    console.info('[DeviceStore] 关闭麦克风');
  }

  /**
   * 打开本地摄像头
   */
  openLocalCamera(isFront: boolean): void {
    this.isFrontCamera = isFront;
    this.cameraStatus = DeviceStatus.on;
    console.info(`[DeviceStore] 打开摄像头, 前置: ${isFront}`);
  }

  /**
   * 关闭本地摄像头
   */
  closeLocalCamera(): void {
    this.cameraStatus = DeviceStatus.off;
    console.info('[DeviceStore] 关闭摄像头');
  }

  /**
   * 切换摄像头
   */
  switchCamera(isFront: boolean): void {
    this.isFrontCamera = isFront;
    console.info(`[DeviceStore] 切换摄像头, 前置: ${isFront}`);
  }

  /**
   * 设置音频路由
   */
  setAudioRoute(route: AudioRoute): void {
    this.currentAudioRoute = route;
    console.info(`[DeviceStore] 设置音频路由: ${route}`);
  }

  /**
   * 重置设备状态
   */
  reset(): void {
    this.microphoneStatus = DeviceStatus.off;
    this.cameraStatus = DeviceStatus.off;
    this.currentAudioRoute = AudioRoute.earpiece;
    this.isFrontCamera = true;
  }
}
