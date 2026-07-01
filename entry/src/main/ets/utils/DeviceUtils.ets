import { AppUtil, DeviceUtil } from "@pura/harmony-utils";
import WinLog from "./WinLog";

export function getUserAgent(){
  const systemVersion = DeviceUtil.getOsVersion();
  WinLog.info('os version:'+ systemVersion);
  const  deviceModel = DeviceUtil.getMarketName();
  WinLog.info('os name:' + deviceModel);
  const bundleVersion = DeviceUtil.getBuildVersion();
  WinLog.info('app build version:' + bundleVersion);
  const displayVersion = DeviceUtil.getDisplayVersion();
  WinLog.info('app displayVersion version:' + displayVersion);
  const deviceType = DeviceUtil.getDeviceTypeStr();
  WinLog.info('device type:' + deviceType);
  const osFullName = DeviceUtil.getOsFullName;
  WinLog.info('系统版本 name :' + osFullName);
  const udid = DeviceUtil.getUdid();
  WinLog.info('系统udid :' + udid);
  const language = AppUtil.getLanguage();
  WinLog.info('App语言 :' + language);
}