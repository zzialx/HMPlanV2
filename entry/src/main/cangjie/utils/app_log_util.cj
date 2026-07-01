/**
 * Created on 2025/8/25
 */
package ohos_app_cangjie_entry.utils
import ohos.base.AppLog
import ohos.hilog.Hilog
import log.LogLevel

//    fatal > error > warn > info > debug > trace
//    打印控制台信息
public class AppLogUtil{

    private static let DOMAIN: UInt32 = 0;

    private static let TAG: String = 'WinSfa--->';

    public static func info<T>(param:T) where T <: ToString{
        Hilog.info(DOMAIN, TAG, "${param.toString()}")
    }
    public static func debugInfo<T>(param:T) where T <: ToString{
        Hilog.debug(DOMAIN, TAG, "${param.toString()}")
    }
    public static func  warnInfo<T>(param:T) where T <: ToString{
        Hilog.warn(DOMAIN,TAG,"${param.toString()}")
    }
    public static func  errorInfo<T>(param:T) where T <: ToString{
        Hilog.error(DOMAIN,TAG,"${param.toString()}")
    }
    //用于致命错误日志输出
     public static func  fatalInfo<T>(param:T) where T <: ToString{
         Hilog.fatal(DOMAIN,TAG,"${param.toString()}")
     }
}