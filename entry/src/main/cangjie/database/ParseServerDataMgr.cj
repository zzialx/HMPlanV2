/**
 * Created on 2025/9/3
 */
package ohos_app_cangjie_entry.database
import ohos_app_cangjie_entry.utils.AppLogUtil
import ohos_app_cangjie_entry.extends.WinStringAddtions
import encoding.json.JsonObject
import encoding.json.stream.JsonDeserializable
import encoding.json.JsonValue
import crypto.x509.Key
import std.collection.EquatableCollection
import ohos_app_cangjie_entry.constants.CommonTableNameConstants
import ohos_app_cangjie_entry.model.WinBaseStore
import std.sync.*

public class ParseServerDataMgr{
    public  static func parseLoginData(jsData:String){
        AppLogUtil.info('parseLoginData：开始解析登录数据');
        if (WinStringAddtions.isNull(jsData)) {
            AppLogUtil.errorInfo('登录数据为空，请检查登录数据');
        	return ;
        }
        let json = JsonValue.fromStr(jsData).asObject();
        let allKeys:EquatableCollection<String> = json.getFields().keys();
        AppLogUtil.info('登录data所有keys的size===${allKeys.size}')
        AppLogUtil.info('登录data所有的key：${allKeys.toArray()}');
        for (key in allKeys) {
            if (WinStringAddtions.isNull(key)) {
                break;
            }
            if (key == 'stores' || key.startsWith('stores:')) {
               parseBaseStoreData(jsData, key);
            }
        }
//        let json = JsonValue.fromStr(text).asObject()
//        let choices = json.getFields()['choices'].asArray()
//        // 流式和非流式情况下，这个字段名称不同
//        let key = if (stream) { 'delta' } else { 'message' }
    }
    /**
     * 门店数据储存
     */
    public static func  parseBaseStoreData(jsonData:String,serverNode:String){
        try {
            DatabaseManager.deleteTablenByTableName(CommonTableNameConstants.Store, serverNode);
            let json = JsonValue.fromStr(jsonData).asObject();
            let storeInfoList  = json.get(serverNode);

            AppLogUtil.info('解析门店数据：${storeInfoList}');

        }catch (error:Exception) {
        	AppLogUtil.errorInfo('delete store table data error：${error.toString()}')
        }
    }
}