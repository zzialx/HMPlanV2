import { relationalStore } from '@kit.ArkData';

export class WinBaseStoreAcvtBean {

  _id: number = 0;
  sid: string = '';
  acvtId: string = '';
  uploadCount: string = '';
  hasUploadedCount: string = '';
  server_node: string = '';

  constructor(resultSet?: relationalStore.ResultSet) {

    if (resultSet) {
      this._id = resultSet.getLong(resultSet.getColumnIndex('_id'));
      this.sid = resultSet.getString(resultSet.getColumnIndex('sid'));
      this.acvtId = resultSet.getString(resultSet.getColumnIndex('acvtId'));
      this.uploadCount = resultSet.getString(resultSet.getColumnIndex('uploadCount'));
      this.hasUploadedCount = resultSet.getString(resultSet.getColumnIndex('hasUploadedCount'));
      this.server_node = resultSet.getString(resultSet.getColumnIndex('server_node'));
    }
  }
}