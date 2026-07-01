import { relationalStore } from '@kit.ArkData';

@Observed
export class WinBaseAcvtQstOptBean {
  private _id: number = 0;

  public set id(value: number) {
    this._id = value;
  }

  public get id(): number {
    return this._id;
  }

  private _acvtQstId: string = '';

  public set acvtQstId(value: string) {
    this._acvtQstId = value;
  }

  public get acvtQstId(): string {
    return this._acvtQstId;
  }

  private _qstId: string = '';

  public set qstId(value: string) {
    this._qstId = value;
  }

  public get qstId(): string {
    return this._qstId;
  }

  private _optId: string = '';

  public set optId(value: string) {
    this._optId = value;
  }

  public get optId(): string {
    return this._optId;
  }
  private _optName: string = '';

  public set optName(value: string) {
    this._optName = value;
  }

  public get optName(): string {
    return this._optName;
  }
  server_node: string = '';
  private _isActive: boolean = false;

  public set isActive(value: boolean) {
    this._isActive = value;
  }

  public get isActive(): boolean {
    return this._isActive;
  }


  constructor(resultSet?: relationalStore.ResultSet) {

    if (resultSet) {
      this._id = resultSet.getLong(resultSet.getColumnIndex('_id'));
      this._acvtQstId = resultSet.getString(resultSet.getColumnIndex('acvtQstId'));
      this._qstId = resultSet.getString(resultSet.getColumnIndex('qstId'));
      this._optId = resultSet.getString(resultSet.getColumnIndex('optId'));
      this._optName = resultSet.getString(resultSet.getColumnIndex('optName'));
      this.server_node = resultSet.getString(resultSet.getColumnIndex('server_node'));
      this.isActive = false;
    }
  }
}