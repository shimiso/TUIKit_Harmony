import { MMKV } from '@tencent/mmkv';

/**
 * 与 Android com.zlxt.histar.bean.LoginUserInfo 对齐的鸿蒙登录态数据类。
 *
 * 设计要点：
 * - 单例：通过 `getInstance()` 全局访问，避免多处持有不同实例造成数据不一致。
 * - 持久化：内部用 MMKV 保存为 JSON 字符串（key = PER_USER_MODEL），下次冷启动自动恢复。
 * - 写时即刻持久化：每个 setter 内部都会调用 `save()`，行为与 Android `setUserInfo(this)` 等价。
 * - `updateFromLoginSuccess(args)`：把 Flutter `flutter_pushLoginSuccess` 的字段一次性写入并持久化。
 *
 * 当前只覆盖鸿蒙侧目前会用到的字段（token/refreshToken/expiresIn/isLoginFlag 等核心 + 一些常用字段），
 * 不影响 Android 的兼容字段，需要时按需新增即可。
 */

/** MMKV 落盘 key，与 Android 中 PER_USER_MODEL 保持一致便于对齐。 */
const PER_USER_MODEL = 'per_user_model';

interface PersistShape {
  token: string;
  refreshToken: string;
  expiresIn: number;
  isLoginFlag: boolean;
  userId: string;
  phoneNumber: string;
  zone: string;
  nickname: string;
  avatarUrl: string;
  autoLogin: boolean;
}

export class LoginUserInfo {
  private static sInstance: LoginUserInfo | null = null;

  // ============ 核心登录态 ============
  private token: string = '';
  private refreshToken: string = '';
  private expiresIn: number = 0;
  /** 登录态标记；setLogin(true) 后才视为已登录（且 token 非空）。 */
  private isLoginFlag: boolean = false;

  // ============ 常用扩展字段（按需使用） ============
  private userId: string = '';
  private phoneNumber: string = '';
  private zone: string = '';
  private nickname: string = '';
  private avatarUrl: string = '';
  private autoLogin: boolean = false;

  private constructor() {
    this.loadFromDisk();
  }

  /** 全局单例入口；线程模型为 UI 线程顺序执行，无需额外加锁。 */
  static getInstance(): LoginUserInfo {
    if (LoginUserInfo.sInstance === null) {
      LoginUserInfo.sInstance = new LoginUserInfo();
    }
    return LoginUserInfo.sInstance;
  }

  // ===== getter / setter（setter 内部即刻持久化）=====

  getToken(): string {
    return this.token;
  }

  setToken(token: string): void {
    this.token = token ?? '';
    this.save();
  }

  getRefreshToken(): string {
    return this.refreshToken;
  }

  setRefreshToken(refreshToken: string): void {
    this.refreshToken = refreshToken ?? '';
    this.save();
  }

  getExpiresIn(): number {
    return this.expiresIn;
  }

  setExpiresIn(expiresIn: number): void {
    this.expiresIn = expiresIn;
    this.save();
  }

  /** Token 不为空 且 显式登录成功 才视为已登录。 */
  isLogin(): boolean {
    return this.isLoginFlag && this.token.length > 0;
  }

  setLogin(isLogin: boolean): void {
    this.isLoginFlag = isLogin;
    this.save();
  }

  getUserId(): string {
    return this.userId;
  }

  setUserId(userId: string): void {
    this.userId = userId ?? '';
    this.save();
  }

  getPhoneNumber(): string {
    return this.phoneNumber;
  }

  setPhoneNumber(phoneNumber: string): void {
    this.phoneNumber = phoneNumber ?? '';
    this.save();
  }

  getZone(): string {
    return this.zone;
  }

  setZone(zone: string): void {
    this.zone = zone ?? '';
    this.save();
  }

  getNickname(): string {
    return this.nickname;
  }

  setNickname(nickname: string): void {
    this.nickname = nickname ?? '';
    this.save();
  }

  getAvatarUrl(): string {
    return this.avatarUrl;
  }

  setAvatarUrl(avatarUrl: string): void {
    this.avatarUrl = avatarUrl ?? '';
    this.save();
  }

  isAutoLogin(): boolean {
    return this.autoLogin;
  }

  setAutoLogin(autoLogin: boolean): void {
    this.autoLogin = autoLogin;
    this.save();
  }

  /**
   * Flutter 端 `flutter_pushLoginSuccess` 事件参数 → 一次性写入登录态并落盘。
   * Flutter `UserSessionManager.notifyLoginSuccess` 发包结构为：
   * `{ code, message, data: { token, refresh_token, expires_in } }`，字段在嵌套 `data` 内；
   * 此处优先从 `data` 取值，若无则回退到顶层（兼容旧版或其它端扁平结构）。
   * 兼容 snake_case / camelCase 两种字段命名。
   */
  updateFromLoginSuccess(args: Record<string, Object>): void {
    const p = LoginUserInfo.loginPayloadFromFlutterArgs(args);
    const tokenVal: Object | undefined = p['token'] ?? args['token'];
    const refreshTokenVal: Object | undefined =
      p['refresh_token'] ?? p['refreshToken'] ?? args['refresh_token'] ?? args['refreshToken'];
    const expiresInVal: Object | undefined =
      p['expires_in'] ?? p['expiresIn'] ?? args['expires_in'] ?? args['expiresIn'];

    if (typeof tokenVal === 'string') {
      this.token = tokenVal;
    }
    if (typeof refreshTokenVal === 'string') {
      this.refreshToken = refreshTokenVal;
    }
    if (typeof expiresInVal === 'number') {
      this.expiresIn = expiresInVal;
    } else if (typeof expiresInVal === 'string') {
      const parsed = Number.parseInt(expiresInVal, 10);
      if (!Number.isNaN(parsed)) {
        this.expiresIn = parsed;
      }
    }

    this.isLoginFlag = this.token.length > 0;
    this.save();
  }

  /** 取出 Flutter 事件里的业务字段所在 Map（通常在 `data` 内）。 */
  private static loginPayloadFromFlutterArgs(args: Record<string, Object>): Record<string, Object> {
    const wrapped = args['data'];
    if (wrapped !== undefined && wrapped !== null && typeof wrapped === 'object') {
      return wrapped as Record<string, Object>;
    }
    return {} as Record<string, Object>;
  }

  /**
   * 登出 / 清理：核心登录字段置空并持久化；
   * 业务相关的字段（nickname、avatarUrl 等）保持与 Android 一致也一起清理。
   */
  cleanUserInfo(): void {
    this.token = '';
    this.refreshToken = '';
    this.expiresIn = 0;
    this.isLoginFlag = false;
    this.userId = '';
    this.phoneNumber = '';
    this.zone = '';
    this.nickname = '';
    this.avatarUrl = '';
    this.autoLogin = false;
    this.save();
  }

  /**
   * 调试专用：汇总当前内存中的登录态字段（含原始 isLoginFlag 与计算属性 isLogin）。
   * 勿在生产环境对外日志中全文打印 token。
   */
  debugDumpForTest(): string {
    const lines: string[] = [
      '=== LoginUserInfo 调试快照 ===',
      `isLogin(): ${this.isLogin()}`,
      `isLoginFlag: ${this.isLoginFlag}`,
      `token: ${this.token}`,
      `refreshToken: ${this.refreshToken}`,
      `expiresIn: ${this.expiresIn}`,
      `userId: ${this.userId}`,
      `phoneNumber: ${this.phoneNumber}`,
      `zone: ${this.zone}`,
      `nickname: ${this.nickname}`,
      `avatarUrl: ${this.avatarUrl}`,
      `autoLogin: ${this.autoLogin}`,
      '==============================',
    ];
    return lines.join('\n');
  }

  // ===== 持久化（MMKV）=====

  private getMMKV(): MMKV | null {
    try {
      return MMKV.defaultMMKV();
    } catch (_) {
      // MMKV 未初始化（异常场景，例如未走 EntryAbility.onCreate 的单元测试）
      return null;
    }
  }

  private loadFromDisk(): void {
    const mmkv = this.getMMKV();
    if (mmkv === null) {
      return;
    }
    const json = mmkv.decodeString(PER_USER_MODEL);
    if (json === null || json === undefined || json.length === 0) {
      return;
    }
    try {
      const data = JSON.parse(json) as PersistShape;
      this.token = data.token ?? '';
      this.refreshToken = data.refreshToken ?? '';
      this.expiresIn = data.expiresIn ?? 0;
      this.isLoginFlag = data.isLoginFlag ?? false;
      this.userId = data.userId ?? '';
      this.phoneNumber = data.phoneNumber ?? '';
      this.zone = data.zone ?? '';
      this.nickname = data.nickname ?? '';
      this.avatarUrl = data.avatarUrl ?? '';
      this.autoLogin = data.autoLogin ?? false;
    } catch (err) {
      console.error(`LoginUserInfo loadFromDisk parse failed: ${JSON.stringify(err)}`);
    }
  }

  private save(): void {
    const mmkv = this.getMMKV();
    if (mmkv === null) {
      return;
    }
    const data: PersistShape = {
      token: this.token,
      refreshToken: this.refreshToken,
      expiresIn: this.expiresIn,
      isLoginFlag: this.isLoginFlag,
      userId: this.userId,
      phoneNumber: this.phoneNumber,
      zone: this.zone,
      nickname: this.nickname,
      avatarUrl: this.avatarUrl,
      autoLogin: this.autoLogin,
    };
    try {
      mmkv.encodeString(PER_USER_MODEL, JSON.stringify(data));
    } catch (err) {
      console.error(`LoginUserInfo save failed: ${JSON.stringify(err)}`);
    }
  }
}

export default LoginUserInfo;
