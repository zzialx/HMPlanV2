import { relationalStore } from "@kit.ArkData";

export class WinBaseProductBean {
  cod:string = '';
  id:string = '';
  name:string = '';
  pTyp?:string = '';
  price?:string = '';
  searchcod?:string = '';
  brand?:string = '';
  size?:string = '';
  memo?:string = '';
  memo1?:string = '';
  memo2?:string = '';
  memo3?:string = '';
  memo4?:string = '';
  expirydate?:string = '';
  server_node?:string = '';
  seq?:number;
  pinyin?:string = '';
  constructor(resultSet?: relationalStore.ResultSet) {
    if (resultSet) {
      this.id = resultSet.getString(resultSet.getColumnIndex('Id'));
      this.cod = resultSet.getString(resultSet.getColumnIndex('cod'));
      this.name = resultSet.getString(resultSet.getColumnIndex('name'));
      this.pTyp = resultSet.getString(resultSet.getColumnIndex('pTyp'));
      this.price = resultSet.getString(resultSet.getColumnIndex('price'));
      this.searchcod = resultSet.getString(resultSet.getColumnIndex('searchcod'));
      this.brand = resultSet.getString(resultSet.getColumnIndex('brand'));
      this.size = resultSet.getString(resultSet.getColumnIndex('size'));
      this.memo = resultSet.getString(resultSet.getColumnIndex('memo'));
      this.memo1 = resultSet.getString(resultSet.getColumnIndex('memo1'));
      this.memo2 = resultSet.getString(resultSet.getColumnIndex('memo2'));
      this.memo3 = resultSet.getString(resultSet.getColumnIndex('memo3'));
      this.memo4 = resultSet.getString(resultSet.getColumnIndex('memo4'));
      this.expirydate = resultSet.getString(resultSet.getColumnIndex('expirydate'));
      this.server_node = resultSet.getString(resultSet.getColumnIndex('server_node'));
      this.seq = resultSet.getLong(resultSet.getColumnIndex('seq'));
      this.pinyin = resultSet.getString(resultSet.getColumnIndex('pinyin'));
    }
  }
}