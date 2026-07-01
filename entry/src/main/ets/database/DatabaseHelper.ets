import { relationalStore } from '@kit.ArkData';
import CommonSqlConstants from '../common/constants/CommonSqlConstants';
import WinLog from '../utils/WinLog';
import { DatabaseSqlUtil } from './DatabaseSqlUtil';
let mRdbStore: relationalStore.RdbStore
/**
 * 创建数据库及相关表.
 */
export class DatabaseHelper{
  /**
   * 初始化，获取数据库Store
   * @param context
   */
  constructor(context:Context) {
    relationalStore.getRdbStore(context, DatabaseSqlUtil.STORE_CONFIG, (err, rdbStore) => {
      if (err) {
        WinLog.info(`Failed to get RdbStore. Code:${err.code}, message:${err.message}`);
        return;
      }
      WinLog.info('WINLOG Succeeded in getting RdbStore--->' + context.databaseDir);
      this.createTable(rdbStore)
    });
  }
  public static getRdbStore():relationalStore.RdbStore {
    return mRdbStore;
  }
  /**
   * 创建表.
   * @param rdbStore
   */
  private createTable(rdbStore: relationalStore.RdbStore):void {
    // 判断数据库版本，如果不匹配则需进行升降级操作
    if (rdbStore == undefined){
      WinLog.info('WINLOG rdbStore undefined');
      return
    }
    mRdbStore = rdbStore;
    WinLog.info('WINLOG store.version--->' + rdbStore.version);
    // 当数据库创建时，数据库默认版本为0
    if (rdbStore.version === 0) {
      rdbStore.executeSql(CommonSqlConstants.CREATE_BASE_STORE_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREATE_BASE_ACVT_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREATE_BASE_ACVT_QST_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREATE_BASE_ACVT_QST_OPT_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_FUNCS_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_Plan_Route_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_STORE_ACVT_DIS);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_STORE_PRODUCT);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_STORE_PROD_DIS);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_STORE_OTHER_DATA);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_STORE_VISIT_PLAN);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_STORE_ACVT_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_BASE_DICTS);
      // rdbStore.executeSql(CommonSqlConstants.CREAT_DOWN_FILE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_VISIT_STORE_ACVT_DATA_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_INOUT_STORE_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_OFFLINE_UPLOAD_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_VISIT_STORE_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREAT_VISIT_STORE_ACTION_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREATE_IMAGE_PATH_TABLE);
      rdbStore.executeSql(CommonSqlConstants.CREATE_BASE_IN_STORE_PRODUCT_TABLE);

      // 设置数据库的版本，入参为大于0的整数
      rdbStore.version = 1;
      WinLog.info('WINLOG version 0 action');
    }
    // 如果数据库版本不为0且和当前数据库版本不匹配，需要进行升降级操作
    // 当数据库存在并假定版本为1时，例应用从某一版本升级到当前版本，数据库需要从1版本升级到2版本
    if (rdbStore.version === 1) {
      // version = 1：表结构：EMPLOYEE (NAME, SALARY, CODES, ADDRESS) => version = 2：表结构：EMPLOYEE (NAME, AGE, SALARY, CODES, ADDRESS)
      if (rdbStore !== undefined) {
        (rdbStore as relationalStore.RdbStore).executeSql(CommonSqlConstants.ALTER_BASE_ACVT_QST_COLUMN_memo);
        rdbStore.version = 2;
      }
      WinLog.info('WINLOG version 1 action');
    }
  }
}