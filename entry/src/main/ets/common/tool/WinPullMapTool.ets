import { AppUtil, LocationUtil, ToastUtil } from "@pura/harmony-utils"
import { Want } from "@kit.AbilityKit"
import { BusinessError, zlib } from "@kit.BasicServicesKit"
import WinLog from "../../utils/WinLog"
import { bundleManager } from "@kit.AbilityKit"

export enum WinMapType{
  GD,
  BD
}
export class WinPullMapTool{
  //1.跳转地图
  static async pullMap(address:string,map:WinMapType){
    const location = await LocationUtil.getAddressFromLocationName(address)
    console.log('location' + JSON.stringify(location))
    if (map === WinMapType.GD) {
      let isInstallGD = bundleManager.canOpenLink('amapuri://com.amap.hmapp');
      if (!isInstallGD) {
        ToastUtil.showToast('高德地图未安装');
        return;
      }
      let want: Want = {
        uri: `amapuri://route/plan?dlat=${location.latitude}&dlon=${location.longitude}&dname=${address}&t=0`
      }
      const context = AppUtil.getContext();
      context.startAbility(want, (err: BusinessError) => {
        if (err.code) {
          WinLog.error(`跳转高德业务逻辑错误 startAbility failed,code is ${err.code},message is ${err.message}`);
          return
        }
      })
    } else if (map === WinMapType.BD) {
      let isInstallBD = bundleManager.canOpenLink('baidumap://map/direction');
      if (!isInstallBD) {
        ToastUtil.showToast('百度地图未安装');
        return;
      }
      let uri = 'baidumap://map/direction?' +
        `destination=latlng:${location.latitude},${location.longitude},|name:${address}&mode=driving`
      let want: Want = { uri: uri }
      const context = AppUtil.getContext();
      context.startAbility(want, (err: BusinessError) => {
        if (err.code) {
          WinLog.error(`跳转百度业务逻辑错误 startAbility failed,code is ${err.code},message is ${err.message}`);
        }
      })
    }
  }
}