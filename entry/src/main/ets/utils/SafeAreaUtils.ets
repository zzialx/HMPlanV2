import { AppUtil } from "@pura/harmony-utils";

/**
 * 安全区域工具类
 * 用于获取和管理安全区域信息
 */
let uiContext = AppUtil.getUIContext();
export class SafeAreaUtils {
  private static instance: SafeAreaUtils;

  private constructor() {}

  static getInstance(): SafeAreaUtils {
    if (!SafeAreaUtils.instance) {
      SafeAreaUtils.instance = new SafeAreaUtils();
    }
    return SafeAreaUtils.instance;
  }

  /**
   * 获取状态栏高度
   */
  getStatusBarHeight(): number {
    return uiContext.px2vp(AppStorage.get<number>('statusBarHeight')) ?? 0;
  }

  /**
   * 获取底部导航栏高度
   */
  getNavigationBarHeight(): number {
    return uiContext.px2vp(AppStorage.get<number>('navigationBarHeight')) ?? 0;
  }

  /**
   * 获取刘海屏高度
   */
  getCutoutHeight(): number {
    return uiContext.px2vp(AppStorage.get<number>('cutoutHeight')) ?? 0;
  }

  /**
   * 获取总头部安全高度（状态栏 + 导航栏）
   */
  getTotalHeaderHeight(navHeight: number = 56): number {
    return this.getStatusBarHeight() + navHeight;
  }

  /**
   * 获取总底部安全高度
   */
  getTotalFooterHeight(): number {
    return this.getNavigationBarHeight();
  }
}