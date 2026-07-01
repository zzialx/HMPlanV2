import CommonConstants from '../common/constants/CommonConstants';
import StyleConstants from '../common/constants/StyleConstants';
import { bundleManager, common } from '@kit.AbilityKit'
import { HMLifecycle, HMLifecycleContext, HMRouter, HMRouterMgr, IHMLifecycle } from '@hadss/hmrouter';
import { HMRouterMgrTool } from '../common/tool/HMRouterMgrTool';
import WinLog from '../utils/WinLog';
import { PreferenceMgrTool } from '../common/tool/PreferenceMgrTool';
import { PreferencesManager } from '../common/utils/PreferencesUtil';
import PreferencesConstants from '../common/constants/PreferencesConstants';
import { WinBaseFuncBean } from '../common/bean/WinBaseFuncBean';
import loginVM from '../viewModel/login/WinLoginVM'
/**
 * The login page consists of two components.
 * LoginTitle and LoginBottom, which can be invoked by directly referencing the control.
 */

@Builder
export function LoginPageBuilder() {
  LoginPage()
}

@Entry
@HMRouter({ pageUrl: 'LoginPage', singleton: true, lifecycle: 'PageDurationLifecycle' })
@ComponentV2
export struct LoginPage {
  aboutToAppear(): void {
    WinLog.info("LoginPage aboutToAppear")
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((info) => {
      WinLog.info("LoginPage App系统版本号：" + info.name)
    })
  }
  build() {
    Column() {
      LoginTitle()
      LoginBottom()
    }
    .backgroundImage($r('app.media.login_bg'))
    .backgroundImageSize(ImageSize.FILL)
    .width('100%')
    .height('100%')
  }
}

@Preview
@ComponentV2
struct LoginTitle {
  build() {
    Column() {
      Image($r('app.media.login_head'))
        .width($r('app.float.logo_image_head_with'))
        .height($r('app.float.logo_image_head_height'))
        .margin({ bottom: $r('app.float.logo_margin_bottom') })
    }
    .justifyContent(FlexAlign.Center)
    .width(StyleConstants.FULL_PARENT)
    .height(StyleConstants.LOGIN_LOGO_HEIGHT)
  }
}

@Preview
@ComponentV2
struct LoginBottom {
  @Local account: string = PreferencesManager.get(PreferencesConstants.WINC_ACCOUNT) as string;
  @Local password: string = PreferencesManager.get(PreferencesConstants.WINC_PASSWORD) as string;
  @Local progressValue: number = 0;
  @Local isRememberUser: boolean = PreferencesManager.get(PreferencesConstants.WINC_ISREMEBERUSER) as boolean;
  @Local isAutoLogin: boolean = PreferencesManager.get(PreferencesConstants.WINC_IS_AUTO_LOGIN) as boolean;
  @Local funcBeanList:WinBaseFuncBean[] = [];

  aboutToAppear(): void {
    if (this.isRememberUser  && this.isAutoLogin){
      this.loginAction();
    }
  }
  build() {
    Column() {
      Column({space:10}) {
        TextInput({ placeholder: $r('app.string.account') , text: this.account })
          .maxLength(StyleConstants.INPUT_ACCOUNT_LENGTH)
          .inputStyle()
          .backgroundColor(Color.Transparent)
          .borderWidth(1)
          .borderColor(Color.Gray)
          .onChange((value: string) => {
            this.account = value;
          })

        TextInput({ placeholder: $r('app.string.password'), text: this.password })
          .maxLength(StyleConstants.INPUT_PASSWORD_LENGTH)
          .type(InputType.Password)
          .margin({ top: 50 })
          .inputStyle()
          .backgroundColor(Color.Transparent)
          .borderWidth(1)
          .borderColor(Color.Gray)
          .onChange((value: string) => {
            this.password = value;
          })
      }
      .borderRadius($r('app.float.login_input_radius'))

      Row() {
        Toggle({ type: ToggleType.Checkbox, isOn: this.isRememberUser })
          .width(20)
          .height(20)
          .onChange((isOn:boolean)=>{
            this.isRememberUser = isOn;
          })
        Text($r('app.string.message_login'))
          .blueTextStyle()
          .margin({left:5})
          .onClick(() => {
            this.isRememberUser  = !this.isRememberUser;
          })
      }
      .width(StyleConstants.FULL_PARENT)
      .margin({ top: $r('app.float.forgot_margin_top') })
      .padding({
        left: $r('app.float.forgot_padding_left'),
        right: $r('app.float.forgot_padding_right')
      })

      Progress({value:0, total:100, type:ProgressType.Capsule})
        .width(StyleConstants.FULL_PARENT)
        .height($r('app.float.login_button_height'))
        .value(this.progressValue)
        .margin({
          top: $r('app.float.login_button_top'),
          bottom: $r('app.float.login_button_bottom')
        })
        .visibility(this.progressValue > 0 ? Visibility.Visible:Visibility.None)
        .backgroundColor($r('app.color.start_window_background'))
        .color($r('app.color.login_button_color'))

      Button($r('app.string.login'))
        .id(CommonConstants.LOGIN_BUTTON_ID)
        .width(StyleConstants.FULL_PARENT)
        .height($r('app.float.login_button_height'))
        .fontSize($r('app.float.normal_text_size'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.main_nav_bg_color'))
        .margin({
          top: $r('app.float.login_button_top'),
          bottom: $r('app.float.login_button_bottom')
        })
        .visibility(this.progressValue == 0 ? Visibility.Visible:Visibility.None)
        .onClick(async () => {
          this.loginAction();
        })

      Row() {
        Text($r('app.string.forgot_password'))
          .blueTextStyle()
          .fontColor($r('app.color.main_nav_bg_color'))
          .textAlign(TextAlign.End)
          .onClick(() => {
            WinLog.info("12121212121212121")
            HMRouterMgrTool.push('ResetPswPage');
          })
        Blank()
        Text($r('app.string.register_account'))
          .fontColor($r('app.color.main_nav_bg_color'))
          .fontSize($r('app.float.normal_text_size'))
          .onClick(() => {
            let isFromLogin=  true;
            HMRouterMgrTool.push('AboutPage',isFromLogin,false);
          })
      }
      .justifyContent(FlexAlign.Start)
      .width(StyleConstants.FULL_PARENT)
      .margin({ top: $r('app.float.forgot_margin_top') })
      .padding({
        left: $r('app.float.forgot_padding_left'),
        right: $r('app.float.forgot_padding_right')
      })
    }
    .padding({
      left: $r('app.float.login_button_left'),
      right: $r('app.float.login_button_right'),
    })
    .height(StyleConstants.LOGIN_BOTTOM_HEIGHT)
  }
  /**
   * 登录 Action
   */
  async loginAction(){
    let intervalID = setInterval(() => {
      this.progressValue = this.progressValue + 5
      if (this.progressValue >= 95){
        clearInterval(intervalID);
      }
    }, 100);
    let loginResult: boolean =  await loginVM.loginAppWithParams(this.account,this.password);
    clearInterval(intervalID);
    if (loginResult) {
      loginVM.rememberUser(this.isRememberUser,this.account,this.password)
      this.progressValue = 100
      let value = await  this.getMainTabFuncBeanList()
      HMRouterMgr.push({pageUrl: 'MainPage',param:this.funcBeanList})
      this.progressValue = 0
    } else {
      this.progressValue = 0
    }
  }
  /*
   * 查询TabFuncBeanList
   * */
  async getMainTabFuncBeanList(){
    try {
      let context = getContext(this) as common.UIAbilityContext
      // let value = await BaseFuncsQueryManager.queryMainTabFuncsData(context);
      // if (value) {
      //   this.funcBeanList = []
      //   this.funcBeanList = value;
      //   WinLog.info('LoginPage 查询底部tab个数：'+this.funcBeanList.length)
      // }
    } catch (err) {
      this.funcBeanList = []
      WinLog.info('LoginPage 查询底部tab个数：'+this.funcBeanList.length)
    }
  }
}

@Extend(TextInput) function inputStyle() {
  .placeholderColor($r('app.color.placeholder_color'))
  .height($r('app.float.login_input_height'))
  .fontSize($r('app.float.normal_text_size'))
  .backgroundColor(Color.White)
  .margin({ top: $r('app.float.input_margin_top') })
  .padding({ left: StyleConstants.INPUT_PADDING_LEFT })
}

@Extend(Text) function blueTextStyle() {
  .fontColor($r('app.color.main_nav_bg_color'))
  .fontSize($r('app.float.small_text_size'))
  .fontWeight(FontWeight.Medium)
}