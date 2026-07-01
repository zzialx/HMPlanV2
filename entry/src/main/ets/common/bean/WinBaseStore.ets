import { relationalStore } from "@kit.ArkData";

//查询数据库门店表对象
@ObservedV2
export class WinStoreInfoModel implements WinBaseStore{
  private _Id: string = '';
  public set Id(value: string) {
    this._Id = value;
  }
  public get Id(): string {
    return this._Id;
  }
  private _name: string = '';
  public set name(value: string) {
    this._name = value;
  }
  public get name(): string {
    return this._name;
  }
  empId: string = '';
  code: string = '';
  seq?:string = '';
  styp: string  = '';
  sv?:string = '';
  plan?:string = '';
  addr?:string = '';
  longitude: number | undefined = undefined;
  latitude: number | undefined = undefined;
  noteName?:string = '';
  drId?:string = '';
  qrcode?:string = '';
  biz_date?:string = '';
  storeImg?:string = '';
  local_ImageID?:string = '';
  inTime?:string = '';
  outTime?:string = '';
  phone?:string = '';
  time?:string = '';
  attri?:string = '';
  prepareState?:string = '';
  storesFilter?:string = '';
  state?:string = '';
  last_man?:string = '';
  last_date?:string = '';
  distance?:string = '';
  departmentId ?:string = '';
  actionStateSeq?:string = '';
  ctyp ?:string = '';
  optName ?:string = '';
  answer ?:string = '';
  server_node ?: string = '';
  private _actionState?: string | undefined = '';
  public set actionState(value: string | undefined) {
    this._actionState = value;
  }
  public get actionState(): string | undefined {
    return this._actionState;
  }
  constructor(resultSet?: relationalStore.ResultSet) {
    if (resultSet) {
      this._Id = resultSet.getString(resultSet.getColumnIndex('storeId'));
      this._name = resultSet.getString(resultSet.getColumnIndex('name'));
      this.longitude = resultSet.getDouble(resultSet.getColumnIndex('longitude'));
      this.latitude = resultSet.getDouble(resultSet.getColumnIndex('latitude'));
      this.code = resultSet.getString(resultSet.getColumnIndex('code'));
      this.styp = resultSet.getString(resultSet.getColumnIndex('styp'));
      this.addr = resultSet.getString(resultSet.getColumnIndex('addr'));
      this.server_node = resultSet.getString(resultSet.getColumnIndex('server_node'));
      this.distance = resultSet.getString(resultSet.getColumnIndex('distance'));
      this.optName = resultSet.getString(resultSet.getColumnIndex('optName'));
      this.attri = resultSet.getString(resultSet.getColumnIndex('attri'));
      this.sv = resultSet.getString(resultSet.getColumnIndex('sv'));
      this.local_ImageID = resultSet.getString(resultSet.getColumnIndex('local_ImageID'));
      this.drId = resultSet.getString(resultSet.getColumnIndex('drId'));
      this._actionState  = resultSet.getString(resultSet.getColumnIndex('actionState'));
    }
  }
}

export interface WinBaseStore {
  Id: string;
  name?: string;
  empId?: string;
  code?: string;
  seq?: string;
  styp?: string;
  sv?:string;
  plan?:string;
  actionState?:string;
  addr?:string;
  longitude?: number ;
  latitude?: number;
  noteName?: string;
  drId?: string;
  qrcode?: string;
  biz_date?: string;
  storeImg?: string;
  local_ImageID?: string ;
  inTime?: string ;
  outTime?: string ;
  phone?: string;
  time?: string ;
  attri?: string;
  prepareState?: string ;
  storesFilter?: string;
  state?: string ;
  last_man?: string ;
  last_date?: string ;
  distance?: string;
  departmentId ?: string;
  actionStateSeq?: string ;
  ctyp ?: string ;
  optName ?: string ;
  answer ?: string;
  server_node ?: string;
}