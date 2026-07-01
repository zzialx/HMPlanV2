import { DateUtil, DATE_FORMAT1, NumberUtil, StrUtil, ToastUtil } from "@pura/harmony-utils";
import { getServerTime } from "../common/api/serverTimeApi";
import { WinConfigRespCast } from "../common/bean/LoginConfigResp";
import CommonGlobalConstants from "../common/constants/CommonGlobalConstants";
import { PreferenceMgrTool } from "../common/tool/PreferenceMgrTool";
import WinLog from "../utils/WinLog";
import { process } from "@kit.ArkTS";
import { uploadResource } from "../common/api/uploadFileApi";
import { getBaseLoginConfig } from "../common/api/loginConfigApi";
import { ScanUtil } from "@pura/picker_utils";
import { Utils } from "@pura/picker_utils/src/main/ets/Utils";

/**
 * 主页面业务逻辑 VM
 * 统一处理：服务器时间、登录配置、文件上传
 */
export class MainPageViewModel {

  /**
   * 1. 获取服务器时间
   * 成功：缓存标准时间
   * 失败：使用本地假数据降级 + 缓存CPU运行时长
   */
  public static async getServerTime(): Promise<void> {
    try {
      const res = await getServerTime();
      if (!StrUtil.isEmpty(res.data)) {
        const serverTime:string = res.data??DateUtil.getTodayStr(DATE_FORMAT1);
        const currentServerTime = DateUtil.getFormatDateStr(serverTime, DATE_FORMAT1);
        DateUtil.getTipDateStr(currentServerTime);

        PreferenceMgrTool.putUserDefaultSync(
          CommonGlobalConstants.ServerTime,
          currentServerTime
        );

        // 缓存系统CPU运行时间
        const uptime = process.uptime();
        const uptimeMs = uptime * 1000;
        WinLog.info(`[getServerTime] CPU运行时间：${uptimeMs} ms`);
        WinLog.info(`[getServerTime] CPU运行时间：${uptime / 60 / 60} 小时`);

        PreferenceMgrTool.putUserDefaultSync(
          CommonGlobalConstants.OpenTimeUntilNow,
          uptimeMs
        );
      }
    } catch (error) {
      // 异常降级：使用本机手机时间
      const currentTime:string = DateUtil.getTodayStr(DATE_FORMAT1);
      const currentServerTime = DateUtil.getFormatDateStr(currentTime, DATE_FORMAT1);
      const date = DateUtil.getFormatDateStr(currentServerTime);
      const currentServerTimeStamp = DateUtil.getFormatDate(date).getTime();

      WinLog.error(`[getServerTime error] 时间戳：${currentServerTimeStamp}`);
      PreferenceMgrTool.putUserDefaultSync(
        CommonGlobalConstants.ServerTime,
        currentServerTimeStamp
      );

      // 缓存系统CPU运行时间
      const uptime = process.uptime();
      const uptimeMs = uptime * 1000;
      WinLog.info(`[getServerTime] CPU运行时间：${uptimeMs} ms`);
      WinLog.info(`[getServerTime] CPU运行时间：${uptime / 60 / 60} 小时`);

      PreferenceMgrTool.putUserDefaultSync(
        CommonGlobalConstants.OpenTimeUntilNow,
        uptimeMs
      );
    }
  }

  /**
   * 2. 获取登录下发配置
   */
  public static async getLaunchVersionInfo(): Promise<void> {
    try {
      const res = await getBaseLoginConfig(2.25, "Native");
      WinLog.info(`[getLaunchVersionInfo] res: ${JSON.stringify(res)}`);
      const updatedTime = (res.data&&res.data.updatedTime)??'';
      WinLog.info(`[getLaunchVersionInfo] updatedTime: ${updatedTime}`);
      if (res.data === undefined) {
        WinLog.error('登录配置信息为空');
        return;
      }
      MainPageViewModel.dealSuccessData(res.data);
    } catch (error) {
      WinLog.error(`[getLaunchVersionInfo] 请求失败：${JSON.stringify(error)}`);
    }
  }

  /**
   * 处理登录配置成功数据
   * @param params 配置模型
   */
  private static async dealSuccessData(params: WinConfigRespCast): Promise<void> {
    if (!NumberUtil.isNaN(params.version)) {
      PreferenceMgrTool.putUserDefaultSync(
        CommonGlobalConstants.LaunchVersion,
        params.version??''
      );
    }

    if (!StrUtil.isEmpty(params.bgColor)) {
      PreferenceMgrTool.putUserDefaultSync(
        CommonGlobalConstants.StatusBarColor,
        params.bgColor??''
      );
    }

    if (!StrUtil.isEmpty(params.fontColor)) {
      PreferenceMgrTool.putUserDefaultSync(
        CommonGlobalConstants.StatusFontColor,
        params.fontColor??''
      );
    }
    if (!StrUtil.isEmpty(params.fileHost)) {
      PreferenceMgrTool.putUserDefaultSync(
        CommonGlobalConstants.OpenFileHost,
        params.fileHost??''
      );
    }
    if (!StrUtil.isEmpty(params.thumbnailHost)) {
      PreferenceMgrTool.putUserDefaultSync(
        CommonGlobalConstants.ThumbnailHost,
        params.thumbnailHost??''
      );
    }
  }

  /**
   * 3. 上传单张图片
   * @param path 图片路径
   */
  static async uploadImage(path: string): Promise<void> {
    try {
      // const res = await uploadSingleImage(path);

      const res = await uploadResource('image',path,'image')

      WinLog.info(`[uploadImage] 上传结果：${JSON.stringify(res)}`);
    } catch (error) {
      WinLog.error(`[uploadImage] 上传失败：${JSON.stringify(error)}`);
    }
  }

  /**
   * 4. 调用扫码程序
   * @Return 返回扫码结果
   */
  static async startScanForResult(): Promise<string>{
    let canIUserScan = ScanUtil.canIUseScan();
    if (!canIUserScan) {
      ToastUtil.showToast('当前设备不支持扫码能力！');
      WinLog.error('该设备不支持扫码功能');
      return '';
    }
    ScanUtil.startScanForResult().then((scanResult) =>{
      let result = JSON.stringify(scanResult,null,2);
      ToastUtil.showToast(result);
      return result;
    })
    return '';
  }

}