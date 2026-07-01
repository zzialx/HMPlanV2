import dataPreferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';
import { AppUtil } from '@pura/harmony-utils';

let context = getContext(this);
const preferencesName: string = 'CommonPreferences';

export class PreferencesManager {
  // 设置数据
  static set(key: string, value: dataPreferences.ValueType) {
    if (context==undefined) {
      context = AppUtil.getContext()
    }
    let preferences = dataPreferences.getPreferencesSync(context, { name: preferencesName });
    preferences?.putSync(key, value);
    preferences?.flush();
  }
  // 获取数据
  static get(key: string): dataPreferences.ValueType | null | undefined {
    if (context==undefined) {
       context = AppUtil.getContext()
    }
    let preferences = dataPreferences.getPreferencesSync(context, { name: preferencesName });
    let value = preferences.getSync(key, null);;
    return value;
  }
  // 删除数据
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
  //清除所有数据
  static async clear(){
    if (context==undefined) {
      context = AppUtil.getContext()
    }
    let preferences = dataPreferences.getPreferencesSync(context, { name: preferencesName });
    await preferences.clear();
    return await preferences.flush()
  }
}