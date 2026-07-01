// src/main/ets/common/location/LXLocationType.ts

/**
 * 统一定位信息实体
 * 包含：经纬度、海拔、精度、速度、详细地址、省市区
 * 大厂标准：纯数据结构 → 使用 interface
 */
export interface LXLocationInfo {
  /** 经度 */
  longitude: number;
  /** 纬度 */
  latitude: number;
  /** 海拔高度 */
  altitude: number;
  /** 精度（半径米） */
  accuracy: number;
  /** 速度 m/s */
  speed: number;
  /** 详细地址 */
  address: string;
  /** 省 */
  province: string;
  /** 市 */
  city: string;
  /** 区 */
  district: string;
}

/**
 * 逆地理编码地址信息（可选）
 */
export interface LXLocationAddress {
  address: string;
  province: string;
  city: string;
  district: string;
  streetName?: string;
  streetNum?: string;
}