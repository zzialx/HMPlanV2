import { deviceInfo } from "@kit.BasicServicesKit";

export class WinCommonUtils {
  public getUserAgent(): string {
    let userAgent: string =
      '(' + deviceInfo.deviceType + ';' + deviceInfo.osFullName + ';' + deviceInfo.displayVersion + ')'
    deviceInfo.versionId
    //TODO 假数据
    userAgent = '(null);wincrm;winchannel;crmi_winretailsaler';
    return userAgent
  }
}
export default new WinCommonUtils();