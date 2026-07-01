/**
 * Created on 2025/8/28
 */
package ohos_app_cangjie_entry.extends
import ohos_app_cangjie_entry.utils.AppLogUtil

extend String{
    public func printSize(){
        println("this size is ${this.size}")
    }
    public func getStringSize(): Int64{
        return this.size;
    }
}
public class  WinStringAddtions{
    /**
    * 判断字符串是否为空1
    */
    public static func isNull(param:String): Bool{
       let length: Int64 = param.getStringSize();
//        AppLogUtil.info('字符串size：${length}');
        if (length >0){
            return false;
        }
        return true;
    }
    /**
    * 判断字符串是否为空2
    */
    public static func isNotNull(param:String): Bool{
       let length: Int64 = param.getStringSize();
        if (length >0){
            return true;
        }
        return false;
    }
}