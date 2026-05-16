import { window } from '@kit.ArkUI';
import { Context } from '@kit.AbilityKit';

/**
 * 窗口沉浸式状态栏 / 恢复默认系统栏，以及与状态栏避让相关的顶部 inset（vp）。
 * 供 LoginPage、MainPage 等页面复用。
 */
export class WindowImmersiveHelper {
  /** 全屏布局 + 透明状态栏 / 导航条区域（与 LoginPage 原实现一致） */
  static async enableImmersiveStatusBar(context: Context): Promise<void> {
    try {
      const win = await window.getLastWindow(context);
      await win.setWindowLayoutFullScreen(true);
      await win.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        statusBarContentColor: '#FF131212',
        navigationBarColor: '#00000000',
        navigationBarContentColor: '#FF131212',
      });
    } catch (_) {
    }
  }

  /** 非全屏 + 不透明白底系统栏 */
  static async restoreDefaultSystemBars(context: Context): Promise<void> {
    try {
      const win = await window.getLastWindow(context);
      await win.setWindowLayoutFullScreen(false);
      await win.setWindowSystemBarProperties({
        statusBarColor: '#FFFFFFFF',
        statusBarContentColor: '#FF131212',
        navigationBarColor: '#FFFFFFFF',
        navigationBarContentColor: '#FF131212',
      });
    } catch (_) {
    }
  }

  /**
   * 沉浸式布局下，正文整体下移所需的顶部留白（状态栏高度，vp）。
   * 建议在 enableImmersiveStatusBar 成功之后调用。
   */
  static async getStatusBarInsetVp(context: Context): Promise<number> {
    try {
      const win = await window.getLastWindow(context);
      const topArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      return px2vp(topArea.topRect.height);
    } catch (_) {
      return 0;
    }
  }
}

export default WindowImmersiveHelper;
