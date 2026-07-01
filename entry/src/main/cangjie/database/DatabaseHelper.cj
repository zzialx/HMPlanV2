/**
 * Created on 2025/8/29
 */
package ohos_app_cangjie_entry.database
import ohos.ark_interop_helper.StageContext
import ohos.relational_store.*
import ohos_app_cangjie_entry.utils.AppLogUtil
import ohos.concurrency.launch
import ohos.base.Main

var mRdbStore: Option<RdbStore> = Option<RdbStore>.None

public class DatabaseHelper{
    var rdb_store_option: Option<RdbStore> = None

    public init(context:StageContext) {
        AppLogUtil.info('DB Init');
        if (this.rdb_store_option.isNone()) {
              AppLogUtil.info('DB 连接');
        	this.rdb_store_option = getRdbStore(context, DatabaseSqlUtil.STORE_CONFIG);
            let rdb_store = this.rdb_store_option.getOrThrow();
            this.creatTable(rdb_store)
        }
    }
    public static  func getRdbStore(){
        return mRdbStore;
    }
    private func creatTable(rdb_store: RdbStore){
        AppLogUtil.info('DB 新建表');
        mRdbStore = rdb_store;
        try {
            spawn(Main) {
                rdb_store.beginTransaction();
                rdb_store.executeSql(DatabaseSqlUtil.CREATE_BASE_STORE_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREATE_BASE_ACVT_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREATE_BASE_ACVT_QST_OPT_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_FUNCS_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_Plan_Route_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_STORE_ACVT_DIS);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_STORE_PROD_DIS);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_STORE_PRODUCT);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_STORE_OTHER_DATA);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_STORE_VISIT_PLAN);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_DICTS);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_DOWN_FILE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_INOUT_STORE_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_BASE_STORE_ACVT_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_VISIT_STORE_ACVT_DATA_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_OFFLINE_UPLOAD_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_VISIT_STORE_ACTION_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREATE_IMAGE_PATH_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREAT_VISIT_STORE_TABLE);
                rdb_store.executeSql(DatabaseSqlUtil.CREATE_BASE_ACVT_QST_TABLE);
                rdb_store.commit()
               AppLogUtil.info('DB 新建表结束');
            }

        }catch (e: Exception) {
        	AppLogUtil.info('db init failed, error: ${e.toString()}')
        }
    }
}