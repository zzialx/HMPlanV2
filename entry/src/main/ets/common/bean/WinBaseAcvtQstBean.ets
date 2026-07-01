import { relationalStore } from '@kit.ArkData'
import { WinBaseAcvtQstOptBean } from './WinBaseAcvtQstOptBean';


@Observed
export class WinBaseAcvtQstBean {

  _id:number = 0;
  acvtId: string = '';
  acvtQstId: string = '';
  qstId: string = '';
  qstCod: string = '';
  qstName: string = '';
  qstType: string = '';
  is_req: string = '';
  readonly: string = '';
  orientation: string = '';
  mlen: string = '';
  dlen: string = '';
  mnum: string = '';
  snum: string = '';
  mc: string = '';
  ds: string = '';
  filter: string = '';
  isAcvtName: string = '';
  isSupperLocalPhoto: string = '';
  defaultValue: string = '';
  acvtNestedId: string = '';
  ishidden: string = '';
  Js : string = '';
  memo : string = '';
  displayMode:string = '';
  hideQstName:string = '';
  isCoverNewId:string = '';
  memo3 : string = '';
  parentQstId:string = '';

  private _opts: WinBaseAcvtQstOptBean[] = [];

  public set opts(value: WinBaseAcvtQstOptBean[]) {
    this._opts = value;
  }

  public get opts(): WinBaseAcvtQstOptBean[] {
    return this._opts;
  }

  constructor(resultSet?: relationalStore.ResultSet) {

    if (resultSet){
      this._id = resultSet.getLong(resultSet.getColumnIndex('_id'));
      this.acvtId = resultSet.getString(resultSet.getColumnIndex('acvtId'));
      this.acvtQstId = resultSet.getString(resultSet.getColumnIndex('acvtQstId'));
      this.qstId = resultSet.getString(resultSet.getColumnIndex('qstId'));
      this.qstCod = resultSet.getString(resultSet.getColumnIndex('qstCod'));
      this.qstName = resultSet.getString(resultSet.getColumnIndex('qstName'));
      this.qstType = resultSet.getString(resultSet.getColumnIndex('qstType'));
      this.is_req = resultSet.getString(resultSet.getColumnIndex('is_req'));
      this.readonly = resultSet.getString(resultSet.getColumnIndex('readonly'));
      this.orientation = resultSet.getString(resultSet.getColumnIndex('orientation'));
      this.mlen = resultSet.getString(resultSet.getColumnIndex('mlen'));
      this.snum = resultSet.getString(resultSet.getColumnIndex('snum'));
      this.dlen = resultSet.getString(resultSet.getColumnIndex('dlen'));
      this.mnum = resultSet.getString(resultSet.getColumnIndex('mnum'));
      this.mc = resultSet.getString(resultSet.getColumnIndex('mc'));
      this.ds = resultSet.getString(resultSet.getColumnIndex('ds'));
      this.filter = resultSet.getString(resultSet.getColumnIndex('filter'));
      this.isAcvtName = resultSet.getString(resultSet.getColumnIndex('isAcvtName'));
      this.isSupperLocalPhoto = resultSet.getString(resultSet.getColumnIndex('isSupperLocalPhoto'));
      this.defaultValue = resultSet.getString(resultSet.getColumnIndex('defaultValue'));
      this.acvtNestedId = resultSet.getString(resultSet.getColumnIndex('acvtNestedId'));
      this.ishidden = resultSet.getString(resultSet.getColumnIndex('ishidden'));
      this.Js = resultSet.getString(resultSet.getColumnIndex('Js'));
      this.memo = resultSet.getString(resultSet.getColumnIndex('memo'));
      this.displayMode = resultSet.getString(resultSet.getColumnIndex('displayMode'));
      this.hideQstName = resultSet.getString(resultSet.getColumnIndex('hideQstName'));
      this.isCoverNewId = resultSet.getString(resultSet.getColumnIndex('isCoverNewId'));
      this.memo3 = resultSet.getString(resultSet.getColumnIndex('memo3'));
      this.parentQstId = resultSet.getString(resultSet.getColumnIndex('parentQstId'));
    }
  }
}
