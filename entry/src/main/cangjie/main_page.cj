
/**
 * Created on 2025/8/25
 */
package ohos_app_cangjie_entry

import ohos.router.Router
import ohos.component.*
import ohos.state_macro_manage.*
import ohos.preferences.*
import ohos_app_cangjie_entry.utils.AppLogUtil
import ohos_app_cangjie_entry.constants.CommonStyleConstants
import ohos.base.*
import ohos_app_cangjie_entry.constants.CommonTagConstants

@Entry
@Component
class MainPage{
    protected override func  aboutToAppear(){
        AppLogUtil.info('Login Page aboutToAppear');
    }
    func build() {
         Column(){
            Text('11111')
         }
        .height(CommonStyleConstants.FULL_SIZE)
        .width(CommonStyleConstants.FULL_SIZE)
        .backgroundColor(Color.RED)

    }
}