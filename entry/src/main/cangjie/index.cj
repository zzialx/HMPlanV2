package ohos_app_cangjie_entry

internal import ohos.base.LengthProp
internal import ohos.component.CustomView
internal import ohos.component.CJEntry
internal import ohos.component.loadNativeView
internal import ohos.state_manage.SubscriberManager
internal import ohos.state_manage.ObservedProperty
internal import ohos.state_manage.LocalStorage
import ohos.component.*
import ohos.state_macro_manage.Entry
import ohos.state_macro_manage.Component
import ohos.state_macro_manage.State
import ohos.state_macro_manage.r
import ohos.router.Router
import ohos_app_cangjie_entry.utils.AppLogUtil
import ohos.preferences.Preferences
import ohos.preferences.ValueType
import ohos_app_cangjie_entry.constants.CommonTagConstants
import ohos.component.TextTimer
import ohos.state_macro_manage.*
import ohos.state_manage.*
import ohos.base.*
import std.sync.*
import std.time.{Duration, DurationExtension}

@Entry
@Component
class EntryView {
    @State
    var message: String = "引导页"
    var content: String = 'Welcome WINC SFA 下一步'
    func getWelocmeMethod(){

//        Timer.once(3 * Duration.second) { =>
//            println("run only once")
//            AppLogUtil.info('结束')
//            Router.push(url: "LoginView")
//        }
    }
    //index的生命周期
    protected override func  aboutToAppear(){
        AppLogUtil.info("EntryView aboutToAppear");
        AppLogUtil.debugInfo("EntryView aboutToAppear");
        AppLogUtil.warnInfo("EntryView aboutToAppear");
        AppLogUtil.errorInfo("EntryView aboutToAppear");
        AppLogUtil.fatalInfo("EntryView aboutToAppear");
        this.getWelocmeMethod()

        //自动跳转至登录页面
//       Router.push(url: "LoginView")

    }
    func build() {
        Row {
            Column {
                Button(message)
                .onClick {
                    evt => AppLog.info("Hello Cangjie")
                    this.message = 'Test'
                    putPreferencesInfo("name",ValueType.string('zzialx'))
                }
                .fontSize(20)
                .height(20)
                Text(content)
                .onClick{
                      evt => AppLog.info("Hello test")
                    Router.push(url: "LoginView")
                }
                .fontSize(40)
                .height(40)
            }
            .width(100.percent)
        }.height(100.percent)
    }
}
//存储沙盒数据的Method
public  func putPreferencesInfo(key:String,value:ValueType){
        var  my_preference = Preferences.getPreferences(get_app_Context(),CommonTagConstants.PRE_TAG);
        my_preference.put(key, value)
        my_preference.flush();
    }

//获取沙盒存储数据的值
public  func getPreferencesInfo(key:String){
        var my_preference = Preferences.getPreferences(get_app_Context(), CommonTagConstants.PRE_TAG);
        if (my_preference.has(key)){
            let value = my_preference.get(key,ValueType.string(''))
            match (value) {
                case ValueType.string(n) => return  n
                case _ => return ''
            }
        }
       return ''
    }
