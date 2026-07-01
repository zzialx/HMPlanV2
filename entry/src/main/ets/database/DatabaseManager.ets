import { relationalStore, ValuesBucket } from '@kit.ArkData';
import { DatabaseHelper } from './DatabaseHelper';
import { AppUtil, FileUtil, ToastUtil } from '@pura/harmony-utils';
import zlib from '@ohos.zlib';
import { BusinessError } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { DatabaseSqlUtil } from './DatabaseSqlUtil';
import WinLog from '../utils/WinLog';
import { CommonFileConstants } from '../common/constants/CommonFileConstants';

/**
 * 创建数据库及相关表.
 */
export class DatabaseManager{
  /**
   * 单条插入数据库.
   * @param context
   * @param tableName
   * @param bucketArray
   */
  static insertTableData(tableName:string, valuesBucket:ValuesBucket){
    WinLog.info(`单条插入数据到 ${tableName} 表`);
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      try {
        (rdbStore as relationalStore.RdbStore).insertSync(tableName, valuesBucket)
      } catch (err) {
        WinLog.info(`insertTableData ${tableName}表 err: ${err.message} ` );
      }
    } else {
      WinLog.info(`insertTableData ${tableName}表 获取数据库失败`);
    }
  }
  /**
   * 批量插入数据库.
   * @param context
   * @param tableName
   * @param bucketArray
   */
  static batchInsertTableData(tableName:string, bucketArray:ValuesBucket[] ){
    WinLog.info(`批量插入数据到 ${tableName} 表`);
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      try {
        (rdbStore as relationalStore.RdbStore).batchInsertSync(tableName, bucketArray)
      } catch (err) {
        WinLog.error(`batchInsertTableData ${tableName}表 err: ${err.message} ` );
      }
    } else {
      WinLog.error(`batchInsertTableData ${tableName}表 获取数据库失败`);
    }
  }
  /**
   * 批量插入数据（sql list形式）.
   * @param context
   * @param rdbPredicates
   */
  static batchInsertTableDataBySqlStr(tableName:string,sqlString:string[]) {
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      rdbStore.beginTransaction()
      sqlString.forEach(sqlStr=>{
        rdbStore.executeSql(sqlStr).then(() => {
          console.info(`batchInsert table:${tableName} column success.`)
        }).catch((err: BusinessError) => {
          console.info(`batchInsert table :${tableName}column failed, err:  + err`)
        })
      })
      rdbStore.commit()
    } else {
      WinLog.info(`deleteTableDataByTabName ${tableName} 表 获取数据库失败`);
    }
  }
  /**
   * 删除数据.
   * @param context
   * @param rdbPredicates
   */
  static deleteTableDataByTabName(context:Context, tableName:string,serverNode?:string){
    WinLog.info(`删除 ${tableName} 表数据 `);
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      //创建谓词，进行删除
      let rdbPredicates = new relationalStore.RdbPredicates(tableName);
      if (serverNode){
        rdbPredicates.equalTo("server_node",serverNode);
      }
      try {
        (rdbStore as relationalStore.RdbStore).deleteSync(rdbPredicates)
      } catch (err) {
        WinLog.info(`deleteTableDataByTabName ${tableName}表  err: ${err.message} ` );
      }

    } else {
      WinLog.info(`deleteTableDataByTabName ${tableName} 表 获取数据库失败`);
    }
  }
  /**
   * 删除数据.
   * @param context
   * @param rdbPredicates
   */
  static deleteTableDataBySqlStr(context:Context,tableName:string,sqlString:string) {
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      rdbStore.executeSql(sqlString).then(() => {
        console.info('Delete table column success.')
      }).catch((err: BusinessError) => {
        console.info("Delete table column failed, err: " + err)
      })
    } else {
      WinLog.info(`deleteTableDataByTabName ${tableName} 表 获取数据库失败`);
    }
  }
  /**
   * 批量删除数据.
   * @param context
   * @param rdbPredicates
   */
  static batchDeleteTableDataBySqlStr(tableName:string,sqlString:string[]) {
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      rdbStore.beginTransaction()
      sqlString.forEach(sqlStr=>{
        rdbStore.executeSql(sqlStr).then(() => {
          console.info(`Delete table:${tableName} column success.`)
        }).catch((err: BusinessError) => {
          console.info(`Delete table :${tableName}column failed, err:  + err`)
        })
      })
      rdbStore.commit()
    } else {
      WinLog.info(`deleteTableDataByTabName ${tableName} 表 获取数据库失败`);
    }
  }
  /**
   * 更新表数据.
   * @param context
   * @param rdbPredicates
   */
  static updateTableDataBySqlStr(tableName:string,sqlString:string){
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      rdbStore.executeSql(sqlString, (err) => {
        if (err) {
          WinLog.error(`ExecuteSql ${tableName} failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        WinLog.info(`ExecuteSql ${tableName} done.`);
      })
    }
  }
  /**
   * 查询表数据.
   * @param context
   * @param rdbPredicates
   */
  static queryVisitStoreTableDataBySqlStr(tableName:string,sqlString:string){
    // return new Promise<BaseVisitStoreStatusModel[]>((resolve)=>{
    //   let rdbStore = DatabaseHelper.getRdbStore();
    //   if(rdbStore != undefined) {
    //     let context =  AppUtil.getContext();
    //     relationalStore.getRdbStore(context, DatabaseSqlUtil.STORE_CONFIG, async (err, rdbStore) => {
    //       if (err) {
    //         WinLog.error(`query ${tableName} rdbStore error: ${err.message}}`)
    //         resolve([]);
    //         return
    //       }
    //       if (!rdbStore) {
    //         WinLog.error(`query ${tableName} rdbStore is null`)
    //         resolve([]);
    //         return
    //       }
    //       rdbStore.querySql(sqlString,(err:BusinessError,resultSet:relationalStore.ResultSet)=>{
    //         WinLog.info(`查询${tableName}条数--->${resultSet.rowCount}`);
    //         let resultArr:BaseVisitStoreStatusModel[] = [];
    //         resultSet.goToFirstRow();
    //         while (!resultSet.isEnded) {
    //           let visitStoreModel: BaseVisitStoreStatusModel = new BaseVisitStoreStatusModel(resultSet);
    //           if (!resultArr.includes(visitStoreModel)) {
    //             resultArr.push(visitStoreModel);
    //           }
    //           resultSet.goToNextRow();
    //         }
    //         resultSet.close();
    //         resolve(resultArr)
    //       })
    //     })
    //   }
    // })
  }
  /**
 * 查询数据库数据.
 * @param store
 * @param rdbPredicates
 * @param columns
 * @returns
 */
  static queryData(store:relationalStore.RdbStore, rdbPredicates: relationalStore.RdbPredicates, columns?: Array<string>): Promise<relationalStore.ResultSet> {
    return new Promise<relationalStore.ResultSet>((success, error) => {
      if (store) {
        store.query(rdbPredicates, columns).then((dataSet: relationalStore.ResultSet) => {
          WinLog.info('查询数据执行成功');
          success(dataSet);
          // dataSet.close(); // 此处将结果集ResultSet关闭，导致返回的结果集中无数据
        }).catch((err: Error) => {
          WinLog.info('查询数据执行失败');
          error(err);
        });
      } else if (store === undefined) {
        WinLog.info('this.store is undefined');
      } else if (store === null) {
        WinLog.info('this.store is null');
      }
    });
  }
  /**
   * 查询数据库数据 同步方法.
   * @param store
   * @param rdbPredicates
   * @param columns
   * @returns
   */
  static queryDataSync(store:relationalStore.RdbStore, rdbPredicates: relationalStore.RdbPredicates, columns?: Array<string>): relationalStore.ResultSet|undefined {
    if (store != undefined) {
      try {
        let resultSet: relationalStore.ResultSet = (store as relationalStore.RdbStore).querySync(rdbPredicates, columns);
        console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
        // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
        // resultSet.close();
        return resultSet;
      } catch (err) {
        console.error(`Query failed, code is ${err.code},message is ${err.message}`);
        return undefined;
      }
    }
    return undefined;
  }
  /**
   * 查询数据库数据 同步方法.
   * @param store
   * @param sqlString
   * @returns
   */
  static queryDataSyncBySql(rdbStore:relationalStore.RdbStore, sqlString:string): relationalStore.ResultSet|undefined {
    if (rdbStore != undefined) {
      try {
        let resultSet: relationalStore.ResultSet = (rdbStore as relationalStore.RdbStore).querySqlSync(sqlString);
        return resultSet;
      }catch (err){
        WinLog.error(`Query failed, code is ${err.code},message is ${err.message}`);
        return undefined;
      }
    }
    return undefined;
  }
  /**
   * 备份数据库.
   * @param context
   * @param rdbPredicates
   */
  static backupRDBTable(){
    WinLog.info(`备份数据库`);
    let rdbStore = DatabaseHelper.getRdbStore();
    if(rdbStore != undefined) {
      try {
        let backupDatabasePath = CommonFileConstants.TempUploadLogDir + '/backup.db';
        (rdbStore as relationalStore.RdbStore).backup(backupDatabasePath,(err)=>{
          if (err) {
            WinLog.info(`Backup failed, code is ${err.code},message is ${err.message}`);
            return;
          }
          WinLog.info('backupRDBTable 备份数据库成功');
        });
      } catch (err) {
        WinLog.info(`backupRDBTable err: ${err.message} ` );
      }
    } else {
      WinLog.info(`backupRDBTable 备份数据库失败`);
    }
  }

}