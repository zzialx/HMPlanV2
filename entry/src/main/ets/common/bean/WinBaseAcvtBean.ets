import { relationalStore } from "@kit.ArkData";

export class WinBaseAcvtBean {

  _id: number = 0;
  acvtId: string = '';
  acvtCode: string = '';
  acvtName: string = ''
  typ: string = '';
  isblock: string = '';
  isReq: string = '';
  ftext: string = '';
  server_node: string = '';
  acvtIconUrl: string = '';
  originalAcvtId: string = '';
  empId: string = '';
  acvtObj: string = '';
  publisher:string = '';
  private _qsts: WinBaseAcvtBean[] = [];

  constructor(resultSet?: relationalStore.ResultSet) {

    if (resultSet) {
      this._id = resultSet.getLong(resultSet.getColumnIndex('_id'));
      this.acvtId = resultSet.getString(resultSet.getColumnIndex('acvtId'));
      this.acvtCode = resultSet.getString(resultSet.getColumnIndex('acvtCode'));
      this.acvtName = resultSet.getString(resultSet.getColumnIndex('acvtName'));
      this.typ = resultSet.getString(resultSet.getColumnIndex('typ'));
      this.isblock = resultSet.getString(resultSet.getColumnIndex('isblock'));
      this.isReq = resultSet.getString(resultSet.getColumnIndex('isReq'));
      this.ftext = resultSet.getString(resultSet.getColumnIndex('ftext'));
      this.server_node = resultSet.getString(resultSet.getColumnIndex('server_node'));
      this.acvtIconUrl = resultSet.getString(resultSet.getColumnIndex('acvtIconUrl'));
      this.originalAcvtId = resultSet.getString(resultSet.getColumnIndex('originalAcvtId'));
      this.empId = resultSet.getString(resultSet.getColumnIndex('empId'));
      this.acvtObj = resultSet.getString(resultSet.getColumnIndex('acvtObj'));
      this.publisher = resultSet.getString(resultSet.getColumnIndex('publisher'));
    }
  }

  public set qsts(value: WinBaseAcvtBean[]) {
    this._qsts = value;
  }

  public get qsts(): WinBaseAcvtBean[] {
    return this._qsts;
  }
}