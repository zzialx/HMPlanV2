import { AppUtil, JSONUtil, PreferencesUtil, StrUtil } from "@pura/harmony-utils";
import WinLog from "../../utils/WinLog";
import CommonGlobalConstants from "../constants/CommonGlobalConstants";
import preferences from "@ohos.data.preferences";
import dataPreferences from '@ohos.data.preferences';
import CommonRequestConstants from "../constants/CommonRequestConstants";

let context = AppUtil.getContext();
const preferencesName: string = 'CommonPreferences';


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

  /**
   * 存储数据
   * @param key
   * @param value
   */
  static set(key: string, value: dataPreferences.ValueType) {
    if (context==undefined) {
      context = AppUtil.getContext()
    }
    let preferences = dataPreferences.getPreferencesSync(context, { name: preferencesName });
    preferences?.putSync(key, value);
    preferences?.flush();
  }
  /**
   * 获取存储数据
   * @param key
   * @returns
   */
  static get(key: string): dataPreferences.ValueType | null | undefined {
    if (context==undefined) {
      context = AppUtil.getContext()
    }
    let preferences = dataPreferences.getPreferencesSync(context, { name: preferencesName });
    let value = preferences.getSync(key, null);;
    return value;
  }
  /**
   * 删除数据
   * @param key
   */
  static delete(key: string) {
    if (context==undefined) {
      context = AppUtil.getContext()
    }
    let preferences = dataPreferences.getPreferencesSync(context, { name: preferencesName });
    if (preferences?.hasSync(key)) {
      preferences.deleteSync(key);
      preferences.flush();
    }
  }
  /**
   * 清除所有数据
   * @returns
   */
  static async clear(){
    if (context==undefined) {
      context = AppUtil.getContext()
    }
    let preferences = dataPreferences.getPreferencesSync(context, { name: preferencesName });
    await preferences.clear();
    return await preferences.flush()
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
export function getEmpId(){
  return PreferencesUtil.getSync(CommonRequestConstants.UserInfo_EMPID,'') as string;
}