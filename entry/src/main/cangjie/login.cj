/**
 * Created on 2025/8/25
 */
package ohos_app_cangjie_entry

import ohos.router.Router
import ohos.component.*
internal import ohos.base.LengthProp
internal import ohos.component.Column
import ohos.state_macro_manage.Entry
import ohos.state_macro_manage.Component
import ohos.state_macro_manage.State
import ohos.state_macro_manage.r
import ohos.preferences.*
import ohos.preferences.ValueType
import ohos_app_cangjie_entry.utils.AppLogUtil
import ohos_app_cangjie_entry.constants.CommonStyleConstants
import ohos.base.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos_app_cangjie_entry.extends.WinStringAddtions
import ohos_app_cangjie_entry.viewmodel.loginvm.WinLoginViewModel
import ohos_app_cangjie_entry.constants.CommonTagConstants
import ohos.resource_manager.ResourceManager
import std.io.ByteArrayStream
import encoding.json.JsonValue
import ohos_app_cangjie_entry.database.ParseServerDataMgr

@Entry
@Component
class LoginView{
    protected override func  aboutToAppear(){
        AppLogUtil.info('Login Page aboutToAppear');
    }
    func build() {
         Column(){
            LoginHeaderView()
            LoginBodyView()
         }
        .height(CommonStyleConstants.FULL_SIZE)
        .width(CommonStyleConstants.FULL_SIZE)
        .backgroundColor(Color.RED)
        .backgroundImageSize(ImageSize.Contain)
        .backgroundImage(src: @r(app.media.ic_login_bg), repeat: ImageRepeat.Y)
    }
}
@Component
class LoginHeaderView{
    func build(){
        Column()
        .height(CommonStyleConstants.LOGIN_HEAD_SIZE)
        .width(CommonStyleConstants.FULL_SIZE)
        .backgroundColor(Color.WHITE)
        .opacity(0.1)
    }
}
@Component
class LoginBodyView{
    @State var loginName:String = '';
    @State var loginPsw:String =  '';
    @State var remeberUserState = false;
    @State var loginBtnEnable = false;
    protected override func  aboutToAppear(){
        AppLogUtil.info('LoginBodyView aboutToAppear');
        //获取记录用户名的状态值
        let remeberUserStateValue:String =  getPreferencesInfo('remeberUserState');
        var isRemeberUserStateNull: Bool = WinStringAddtions.isNotNull(remeberUserStateValue);
        if (isRemeberUserStateNull && remeberUserStateValue == '1') {
            remeberUserState = true;
        }
        //登录名
        this.loginName = getPreferencesInfo(CommonTagConstants.PRE_LOGIN_NAME);
        //登录密码
        this.loginPsw = getPreferencesInfo(CommonTagConstants.PRE_LOGIN_PSW);
    }
    //存储记住用户名的状态
    func saveLoginUserState(){
        if (remeberUserState) {
        	putPreferencesInfo('remeberUserState', ValueType.string('1'))
        }else {
            putPreferencesInfo('remeberUserState', ValueType.string('0'))
        }
    }
    func changeLoginState(){
        //判断登录名是否为空
        var isLoginNameNull: Bool = WinStringAddtions.isNull(loginName);
        //判断登录密码是否为空
        var isLoginPswNull : Bool = WinStringAddtions.isNull(loginPsw);
        if(!isLoginNameNull && !isLoginPswNull){
            loginBtnEnable = true;
        }else {
            loginBtnEnable = false;
        }
    }
    func loginBtnClick(){
        this.controller.stopEditing();
        let loginVM: WinLoginViewModel = WinLoginViewModel();
        loginVM.loginAction(loginName, loginPsw,{value: Bool =>
                    putPreferencesInfo(CommonTagConstants.PRE_LOGIN_NAME, ValueType.string(this.loginName))
                    putPreferencesInfo(CommonTagConstants.PRE_LOGIN_PSW, ValueType.string(this.loginPsw))
                    this.getTestLoginData();
//        Router.push(url: "MainPage")

                });
    }
    /*模拟登录数据*/
    func getTestLoginData(){
        //读取rawfile下数据
        let resourceMgr = ResourceManager.getResourceManager(get_app_Context());
        let rawfd = resourceMgr.getRawFd("login_data.json");
        AppLogUtil.info('登录串：${rawfd.fd}----${rawfd.offset}----${rawfd.length}');
        //获取buffer数据
        let dataBufferList = resourceMgr.getRawFileContent("login_data.json");
//        AppLogUtil.info('登录串Buffer data：${dataBufferList}');
        //获取字符串数据
        let loginDataStr = String.fromUtf8(dataBufferList);
//        AppLogUtil.info('登录串Buffer string: ${loginDataStr}')
        //字符串转json
        let jv = JsonValue.fromStr(loginDataStr);
        let loginDataJson = jv.toJsonString();
        AppLogUtil.info('登录串Buffer Json: ${loginDataJson}')
        ParseServerDataMgr.parseLoginData(loginDataJson);
        AppLogUtil.info('登录任务完成，push首页');
        Router.push(url: "MainPage")
    }
    var controller: TextInputController = TextInputController();
    func build(){
        Column(2){
            Row(10){
                Image(@r(app.media.ic_login_user))
                    .width(CommonStyleConstants.LOGIN_INPUT_LOGO_WH)
                    .height(CommonStyleConstants.LOGIN_INPUT_LOGO_WH)
                TextInput(text: this.loginName, placeholder: '用户名', controller: this.controller)
                    .placeholderColor(Color.BLACK)
                    .setType(InputType.Normal)
                    .placeholderFont(size: CommonStyleConstants.LOGIN_PLACEHOLD_FONT, weight: FontWeight.W100)
                    .caretColor(Color.BLUE)
                    .width(CommonStyleConstants.LOGIN_INPUT_WIDTH)
                    .height(CommonStyleConstants.LOGIN_INPUT_HEIGHT)
                    .fontSize(CommonStyleConstants.LOGIN_INPUT_FONT)
                    .fontColor(Color.BLACK)
                    .borderRadius(5)
                    .padding(top: 0, right: 5, bottom: 0, left: 5)
                    .backgroundColor(Color.TRANSPARENT)
//                    .inputFilter(value: '[a-z]', error: { info: String =>
//                      AppLog.info("inputFilter error")
//                    })
                    .onChange({ value: String =>
                          AppLogUtil.info('输入的用户名：${value}');
                          loginName = value;
                          changeLoginState();
                    })

            }
            .width(CommonStyleConstants.FULL_SIZE)
            .height(50)
            .padding(top: 5, right: 0, bottom: 5, left: 0)
            Line()
            .backgroundColor(@r(app.color.input_bg_color))
            .height(1.vp)
            .width(CommonStyleConstants.FULL_SIZE)
            Row(10){
                Image(@r(app.media.ic_psw_logo))
                    .width(CommonStyleConstants.LOGIN_INPUT_LOGO_WH)
                    .height(CommonStyleConstants.LOGIN_INPUT_LOGO_WH)
                TextInput(text: this.loginPsw, placeholder: '密码', controller: this.controller)
                    .placeholderColor(Color.BLACK)
                    .setType(InputType.Normal)
                    .placeholderFont(size: CommonStyleConstants.LOGIN_PLACEHOLD_FONT, weight: FontWeight.W100)
                    .caretColor(Color.BLUE)
                    .width(CommonStyleConstants.LOGIN_INPUT_WIDTH)
                    .height(CommonStyleConstants.LOGIN_INPUT_HEIGHT)
                    .fontSize(CommonStyleConstants.LOGIN_INPUT_FONT)
                    .fontColor(Color.BLACK)
                    .borderRadius(5)
                    .padding(top: 0, right: 5, bottom: 0, left: 5)
                    .backgroundColor(Color.TRANSPARENT)
                    .onChange({ value: String =>
                      AppLogUtil.info('输入的密码：${value}');
                      loginPsw = value;
                        changeLoginState();
                    })

            }
            .width(CommonStyleConstants.FULL_SIZE)
            .height(50)
            .padding(top: 5, right: 0, bottom: 5, left: 0)
             Line()
            .backgroundColor(@r(app.color.input_bg_color))
            .height(1.vp)
            .width(CommonStyleConstants.FULL_SIZE)
            Row(10){
                Radio(value: "Radio", group: "radioGroup")
                .checked(remeberUserState)
                .height(20.vp)
                .width(20.vp)
                .onChange({ value: Bool =>
                    AppLogUtil.info('记住用户名选中状态：${value}');
                })
                .onClick({event =>
                       this.remeberUserState = !this.remeberUserState;
                        this.saveLoginUserState();
                    })
                Text('记住用户名')
                .fontColor(@r(app.color.main_nav_bg_color))
                .fontSize(13)
                .height(20.vp)
            }
            .alignSelf(ItemAlign.Start)
            .margin(top:10)

            Button('登录')
            .shape(ShapeType.Normal)
            .stateEffect(true)
            .borderRadius(5)
            .backgroundColor(@r(app.color.main_nav_bg_color))
            .width(CommonStyleConstants.FULL_SIZE)
            .margin(top:30)
            .enabled(this.loginBtnEnable)
            .onClick({event =>
                this.loginBtnClick();
            })
            Row(){
                Text('找回密码')
                .fontColor(@r(app.color.main_nav_bg_color))
                .fontSize(14)
                Blank()
                Text('忘记密码')
                .fontColor(@r(app.color.main_nav_bg_color))
                .fontSize(14)
            }
            .width(CommonStyleConstants.FULL_SIZE)
            .margin(top:10)
            Button('SSO登录')
            .shape(ShapeType.Normal)
            .stateEffect(true)
            .borderRadius(5)
            .backgroundColor(@r(app.color.login_sso_btn_bg_color))
            .width(CommonStyleConstants.FULL_SIZE)
            .margin(top:10)
        }
        .width(CommonStyleConstants.FULL_SIZE)
        .backgroundColor(Color.TRANSPARENT)
        .margin(top:60.vp)
        .padding(CommonStyleConstants.PAGE_PAD)

    }
}
