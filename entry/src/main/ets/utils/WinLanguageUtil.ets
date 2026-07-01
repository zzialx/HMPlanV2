import { AppUtil } from "@pura/harmony-utils";

/**
 * 对应 OC: - (void)changeLanguage:(CDVInvokedUrlCommand*)command
 * 功能：切换语言（从前端传入语言标识 → 映射为内部语言代码）
 */
export function changeLanguage(command:string[]): void {
  // 取第 1 个参数（OC: argumentAtIndex:1）
  const jsonCommand = command[1] as string ?? '';

  // 判断是否是字符串类型
  if (typeof jsonCommand === 'string') {
    const jsonString = jsonCommand;
    let language = 'en'; // 默认英文

    // 语言映射逻辑（和你 OC 完全一致）
    if (jsonString === 'en_US') {
      language = 'en';
    } else if (jsonString === 'zh_CN') {
      language = 'zh-Hans';
    } else if (jsonString === 'vi_VN') {
      language = 'vi-VN';
    } else if (jsonString === 'zh_TW') {
      language = 'zh-Hant-TW';
    } else if (jsonString === 'th_TH') {
      language = 'th';
    }
  }

  // 异步执行 → 对应 dispatch_async(dispatch_get_main_queue(), ^{})
  setTimeout(() => {
    console.log(`已切换到语言---> ${getCurrentLanguage()}`);
  }, 0);
}

// ==================== 辅助类（对应你原项目的 WSUWConfig） ====================
export class WinLanguageUtil {
  private static USER_LANGUAGE_KEY = 'USER_LANGUAGE';

  /**
   * 保存用户选择的语言
   */
  static setUserLanguage(lang: string): void {
    AppUtil.setLanguage(lang)
  }

  /**
   * 获取当前语言
   */
  static getUserLanguage(): string {
    return AppUtil.getLanguage() ?? 'zh-Hans';
  }
}

/**
 * 获取当前系统/应用语言（对应 NSBundle currentLanguage）
 */
function getCurrentLanguage(): string {
  return AppUtil.getLanguage()?? 'zh-Hans';
}