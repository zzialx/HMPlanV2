/**
 * Created on 2025/8/29
 */
package ohos_app_cangjie_entry.database
import ohos_app_cangjie_entry.utils.AppLogUtil
import std.collection.HashMap
import std.collection.Map
import ohos.relational_store.ValueType as RelationValueType
import ohos.relational_store.RdbPredicates
import ohos.relational_store.RdbStore

//TODO ValueType as RelationValueType为什么要转，不转报错
public class DatabaseManager{
    /**
    * 数据库单条插入数据
    */
    public static func insertTableData(tableName:String,values:Map<String,RelationValueType>){
        AppLogUtil.info('单条数据插入到表：${tableName}');
        try {
        	let rdbStore = DatabaseHelper.getRdbStore().getOrThrow();
            rdbStore.insert(tableName, values);
            rdbStore.commit();
        }catch (error:Exception) {
        	AppLogUtil.info('db get rdbStore, error: ${error.toString()}')
        }
    }
    /**
     * 数据库批量插入数据
     */
    public static func  batchInsertTableData(tableName:String,values:Array<Map<String,RelationValueType>>){
         AppLogUtil.info('批量数据插入到表：${tableName}');
        try {
        	let rdbStore = DatabaseHelper.getRdbStore().getOrThrow();
            rdbStore.batchInsert(tableName, values);
            rdbStore.commit();
        }catch (error:Exception) {
        	AppLogUtil.info('db get rdbStore, error: ${error.toString()}')
        }
    }
    /**
     * 数据库删除数据
     */
    public static func deleteTablenByTableName(tableName:String,serverNode:String){
        AppLogUtil.info('删除表：${tableName}数据');
        try {
        	let rdbStore = DatabaseHelper.getRdbStore().getOrThrow();
            let predicates = RdbPredicates(tableName);
            predicates.equalTo("server_node",RelationValueType.string(serverNode));
            rdbStore.delete(predicates);
            rdbStore.commit();
        }catch (error:Exception) {
        	AppLogUtil.info('db delete rdbStore, error: ${error.toString()}')
        }
    }
}