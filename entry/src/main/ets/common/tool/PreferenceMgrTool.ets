import { JSONUtil, PreferencesUtil, StrUtil } from "@pura/harmony-utils";
import WinLog from "../../utils/WinLog";
import CommonGlobalConstants from "../constants/CommonGlobalConstants";
import preferences from "@ohos.data.preferences";

export  class PreferenceMgrTool {
  /**
   * 存储App初始化的相关数据
   */
  public static saveAppInitData(params:string){
    if (StrUtil.isEmpty(params)) {
       WinLog.error('init data is null');
       return;
    }
    let infoMap:Map<string,object> = JSONUtil.jsonToMap(params);
    PreferenceMgrTool.putSync(CommonGlobalConstants.AppProjectName,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.BaseUrl,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.AppEnv,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.Cookie,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.UserName,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.UserId,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.IsOffline,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.AppVersion,infoMap);
    PreferenceMgrTool.putSync(CommonGlobalConstants.CameraCompress,infoMap);

  }
  private static putSync(key:string,infoMap:Map<string,object>){
    if (infoMap.has(key)) {
      let value = infoMap.get(key);
      PreferencesUtil.putSync(key,value);
    }
  }
  /**
   * 存储数据公用方法
   */
  public static putUserDefaultSync(key:string,value: preferences.ValueType){
    PreferencesUtil.putSync(key,value);
  }
  /**
   * 获取存储数据公用方法
   */
  public static getUserDefaultSyncByKey(key:string){
    return PreferencesUtil.getSync(key,'');
  }

}
/**
 * 快速获取 userId 的方法
 */
export function userId(){
  return PreferencesUtil.getSync(CommonGlobalConstants.UserId,'') as string;
}
export function userCookie(){
  return PreferencesUtil.getSync(CommonGlobalConstants.Cookie,'') as string;
}
export function userTenantId(){
  return PreferencesUtil.getSync(CommonGlobalConstants.TenantId,'') as string;
}