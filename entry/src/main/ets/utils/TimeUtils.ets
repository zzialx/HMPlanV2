import CommonGlobalConstants from "../common/constants/CommonGlobalConstants";
import { PreferenceMgrTool } from "../common/tool/PreferenceMgrTool";
import { process } from "@kit.ArkTS";
import { DateUtil, DATE_FORMAT1, StrUtil } from "@pura/harmony-utils";
import WinLog from "./WinLog";

export class TimeUtils{
  //1.计算当前时间，根据服务器时间和 cpu 运行时间差值
  public static getCurrentTime(): string{
    let serverTime = PreferenceMgrTool.getUserDefaultSyncByKey(CommonGlobalConstants.ServerTime)  as string;
    if (StrUtil.isEmpty(serverTime)) {
      return TimeUtils.getLocalTime(DATE_FORMAT1);
    }
    let openTimeUntilNowLast = PreferenceMgrTool.getUserDefaultSyncByKey(CommonGlobalConstants.OpenTimeUntilNow);
    let currentCpuTime = process.uptime() * 1000;
    //计算时间差值
    let duringTime = currentCpuTime - Number(openTimeUntilNowLast);
    if (duringTime<=0) {
      return TimeUtils.getLocalTime(DATE_FORMAT1);
    }
      let nowTimeStamp = Number(serverTime) + duringTime;
      //将时间戳转化为时间
      let time = DateUtil.getFormatDateStr(nowTimeStamp,DATE_FORMAT1)
      WinLog.info('服务器时间：'+ time);
      return time;
  }
  //2.获取系统本机时间
  public static getLocalTime(format?: string){
    let currentLocalTimeStr = DateUtil.getTodayStr(format);
    return currentLocalTimeStr;
  }
}