/**
 * Created on 2025/8/28
 */
package ohos_app_cangjie_entry.utils
import ohos.prompt_action.PromptAction

public class WinPromptActionUtil {
    //系统的toast弹框，默认显示时间,默认居中
    public static func showToast(msg:String){
        PromptAction.showToast(message: msg,  bottom: '50%');
    }
    public static func showToastWithCustomDuration(msg:String,duration:Int32){
        PromptAction.showToast(message: msg, duration: duration);
    }
}