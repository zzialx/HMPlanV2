import { relationalStore } from '@kit.ArkData'

export class WinBaseStoreAcvtDisBean {
  sid?:string = '';
  acvtId?:string = '';
  acvtQstId?:string = '';
  acvt_qst_answer?:string = '';
  gen_id?:string = '';
  assetId?:string = '';
  opt_value?:string = '';
  is_search?:string = '';
  newStoreId?:string = '';
  server_node?:string = '';
  emp_id?:string = '';
  getTime?:string = '';

  constructor(sid?:string,acvtId?:string,acvtQstId?:string,acvt_qst_answer?:string,gen_id?:string,server_node?:string,emp_id?:string) {
    this.sid =  sid;
    this.acvtId =  acvtId;
    this.acvtQstId =  acvtQstId;
    this.acvt_qst_answer =  acvt_qst_answer;
    this.gen_id =  gen_id;
    this.server_node =  server_node;
    this.emp_id =  emp_id;
  }
}

export class  WinBaseStoreAcvtDisModel{
  empId?:string = '';
  p?:string = '';
  gen_id?:string = '';
  sid?:string = '';
}

export class  WinBaseStoreAcvtDisOptValueModel{
  optId?:string = '';
  optName?:string = '';
  constructor(resultSet?: relationalStore.ResultSet) {
    if (resultSet) {
      this.optId =  resultSet.getString(resultSet.getColumnIndex('optId'));
      this.optName = resultSet.getString(resultSet.getColumnIndex('optName'));
    }
  }
}