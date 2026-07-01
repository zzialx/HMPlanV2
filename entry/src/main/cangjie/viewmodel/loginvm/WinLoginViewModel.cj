/**
 * Created on 2025/8/28
 */
package ohos_app_cangjie_entry.viewmodel.loginvm
import ohos_app_cangjie_entry.utils.AppLogUtil
import ohos.prompt_action.PromptAction
import ohos_app_cangjie_entry.extends.WinStringAddtions
import ohos_app_cangjie_entry.utils.WinPromptActionUtil
import std.sync.Timer
import std.time.{Duration, DurationExtension}
import ohos.router.Router
import ohos.base.Callback
//import ohos_app_cangjie_entry.putPreferencesInfo


public class WinLoginViewModel {

    //存储记住用户名状态
    public func saveLoginState(state:Bool){
        if (state) {
//        	putPreferencesInfo('remeberUserState', ValueType.string('zzialx'));
        }else {
//            putPreferencesInfo('remeberUserState', '0');
        }
    }
    //用户登录
    public func loginAction(userName:String,psw:String,callBack:Callback<Bool>){
        AppLogUtil.info('login action');
        if (WinStringAddtions.isNull(userName)) {
            WinPromptActionUtil.showToast('用户名不能为空')
        	return;
        }
        if (WinStringAddtions.isNull(psw)) {
            WinPromptActionUtil.showToast('密码不能为空')
        	return;
        }
         AppLogUtil.info('开始登录')
        //模拟登录数据

        //存储数据
        callBack(true);
//        TODO TimerRouter跳转存在bug,后续待处理
//         Timer.once(3 * Duration.second) { =>
//            AppLogUtil.info('登录结束')
//            callBack(true);
//        }
    }
}