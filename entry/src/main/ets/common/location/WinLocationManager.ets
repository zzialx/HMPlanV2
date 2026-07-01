import { LocationUtil, ToastUtil, WantUtil } from "@pura/harmony-utils";
import { geoLocationManager } from "@kit.LocationKit";
import WinLog from "../../utils/WinLog";
import { WinLocationInfo } from "./WinLocationType";

/**
 * 定位管理类（大厂标准单例模式）
 * 统一处理：定位开关、权限、获取位置、逆地理编码
 */
export class WinLocationManager {
  public static readonly instance = new WinLocationManager();

  private constructor() {}

  /**
   * 获取定位（整合：开关检查 + 权限申请 + 经纬度 + 地址）WGS-84坐标系
   */
  public async getCurrentLocation(): Promise<WinLocationInfo | null> {
    try {
      // 1. 检查定位开关
      if (!LocationUtil.isLocationEnabled()) {
        WinLog.error("[LocationManager] 未开启定位");
        ToastUtil.showToast("未开启定位");
        return null;
      }

      // 2. 申请权限
      const isPermissionGranted = await LocationUtil.requestLocationPermissions();
      if (!isPermissionGranted) {
        WinLog.error("[LocationManager] 定位权限被拒绝");
        ToastUtil.showToast("请在设置中开启定位权限");
        WantUtil.toAppSetting();
        return null;
      }

      // 3. 配置定位参数
      const request: geoLocationManager.CurrentLocationRequest = {
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.NAVIGATION,
        timeoutMs: 10000,
        maxAccuracy: 10
      };

      // 4. 获取经纬度
      const location = await LocationUtil.getCurrentLocation(request);
      WinLog.info("[LocationManager] 当前经纬度：" + JSON.stringify(location));
      let  address:geoLocationManager.GeoAddress | undefined = undefined;
      // 5. 获取地址信息
      try {
        address = await LocationUtil.getAddressFromLocation(
          location.latitude,
          location.longitude
        );
        WinLog.info("[LocationManager] 当前地址：" + JSON.stringify(address));
      } catch (error) {
        WinLog.error("[LocationManager] 逆地理编码失败" + JSON.stringify(error));
      }

      return {
        longitude: location.longitude,
        latitude: location.latitude,
        altitude: location.altitude,
        accuracy: location.accuracy,
        speed: location.speed,
        address: address?.placeName || '',
        province: address?.administrativeArea || '',
        city: address?.subAdministrativeArea || '',
        district: address?.subLocality || ''
      };

    } catch (error) {
      WinLog.error("[LocationManager] 获取定位失败：" + JSON.stringify(error));
      return null;
    }
  }
}