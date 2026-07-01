import { HMRouter, HMRouterMgr } from "@hadss/hmrouter";
import { SymbolGlyphModifier } from "@kit.ArkUI";
import {
  AppUtil,
  FileUtil,
  JSONUtil,
  LocationUtil,
  NetworkUtil,
  ToastUtil,
  WantUtil
} from "@pura/harmony-utils";
import CommonStyleConstants from "../common/constants/CommonStyleConstants";
import { HMRouterMgrTool } from "../common/tool/HMRouterMgrTool";
import WinLog from "../utils/WinLog";
import { BusinessError } from "@kit.BasicServicesKit";
import { geoLocationManager } from "@kit.LocationKit";
import { webview } from "@kit.ArkWeb";
import {
  WebViewJavascriptBridge,
  WebViewJavascriptBridgeTools,
  WVJBResponseCallback
} from "@yue/webview_javascript_bridge";
import { PreferenceMgrTool, userId } from "../common/tool/PreferenceMgrTool";
import { JSON } from "@kit.ArkTS";
import CommonGlobalConstants from "../common/constants/CommonGlobalConstants";
import { MainPageViewModel } from "../viewmodel/MainPageViewModel";
import { TimeUtils } from "../utils/TimeUtils";
import { PhotoMgrTool } from "../common/tool/PhotoMgrTool";
import { WinFileUtils } from "../utils/WinFileUtils";
import { WinMapType, WinPullMapTool } from "../common/tool/WinPullMapTool";
import { getBaseLoginConfig } from "../common/api/loginConfigApi";
import { LXLocationManager } from "../common/location/LXLocationManager";

@Entry
@HMRouter({
  pageUrl: 'MainPage',
  lifecycle: 'PageDurationLifecycle',
  animator: 'pageAnimator'
})
@ComponentV2
export struct MainPage {
  @Local toolsList: string[] = [];
  @Local symbolModifier1: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.house'));

  private readonly _controller: webview.WebviewController = new webview.WebviewController();
  private _bridge: WebViewJavascriptBridge | undefined;

  aboutToAppear(): void {
    WinLog.info('[MainPage] aboutToAppear');
    this.getLocation()
    let language = AppUtil.getLanguage();
    ToastUtil.showToast(`应用语言：${language}`);

      // 固定租户ID
    const testTenantId = '8010';
    PreferenceMgrTool.putUserDefaultSync(CommonGlobalConstants.TenantId, testTenantId);

    // 初始化服务器时间
    MainPageViewModel.getServerTime();

    // 日志文件初始化
    WinFileUtils.initLogFile();
    WinFileUtils.backupLogFile();
  }

  /**
   * 通用点击事件
   */
  clickAction(): void {
    WinLog.info('[MainPage] clickAction');
    HMRouterMgrTool.push('WinPhotoSelectorPage');
  }

  /**
   * 获取网络信息
   */
  getNetWorkInfo(): void {
    WinLog.info('[MainPage] 所有网络：' + NetworkUtil.getAppNetSync());
    WinLog.info('[MainPage] 网络类型：' + NetworkUtil.getNetBearType());
  }

  /**
   * 上传用户信息
   */
  uploadUserInfo(): void {
    // 预留扩展
  }

  /**
   * 保存信息
   */
  saveInfo(): void {
    // 预留扩展
  }

  /**
   * 扫码动作
   */
  scanAction(): void {
    // 预留扩展
  }

  /**
   * 跳转到系统浏览器
   */
  jumpSystemBrowser(): void {
    WantUtil.toWebBrowser('https://www.baidu.com', true);
  }

  /**
   * 获取定位信息
   */
  getLocation(): void {
    LXLocationManager.instance.getCurrentLocation().then((result)=>{
      WinLog.info('位置信息：' + JSON.stringify(result));
    })
  }
  /**
   * 设置语言信息
   */
  setLanguage(): void{
    WinLog.info('设置语言');
    AppUtil.setLanguage('en');
    let language = AppUtil.getLanguage();
    ToastUtil.showToast(`应用语言：${language}`);
  }
  /**
   * 底部操作按钮区域
   */
  @Builder
  private actionView(): void {
    Column() {
      Button('h5注册方法，原生从 h5 获取信息')
        .onClick(() => {
          this._getH5Info();
        });

      Button('相册选择照片上传照片')
        .onClick(() => {
          this._selectPhoto();
        });

      Button('跳转系统浏览器')
        .onClick(() => {
          this.jumpSystemBrowser();
        });

      Button('跳转其他 App')
        .onClick(() => {
          this._jumpOtherApp();
        })
      Button('切换语言')
        .onClick(() => {
          this.setLanguage();
        });
      Button('扫码功能')
        .onClick(() => {
          this._startScan();
        });
      Button('图片浏览器')
        .onClick(()=>{
          this._startPhotoBrowser();
        })
    }
    .width('100%')
    .height('50%')
    .backgroundColor(Color.Gray);
  }

  /**
   * WebView 主体区域
   */
  @Builder
  private webView(): void {
    Column() {
      Web({
        src: $rawfile('index.html'),
        controller: this._controller
      })
        .width('100%')
        .height('50%')
        .domStorageAccess(true)
        .onControllerAttached(() => {
          this.setupWebViewJavascriptBridge();
        })
        .onAlert((event) => {
          AlertDialog.show({ message: event?.message });
          return false;
        })
        .onLoadIntercept((event) => {
          const url = event.data.getRequestUrl();
          return this._bridge?.bridgeInterceptWithURL(url) ?? false;
        });
    }.padding({top:90})
  }

  /**
   * 初始化 WebView JSBridge
   */
  private setupWebViewJavascriptBridge(): void {
    WebViewJavascriptBridge.enableLogging();
    this._bridge = new WebViewJavascriptBridge(this._controller);

    // 注册获取原生信息
    this._bridge.registerHandler('getNativeInfo', (data: Object, responseCallback: WVJBResponseCallback) => {
      if (data) {
        WinLog.info('[JSBridge] 获取原生信息：' + JSON.stringify(data));
      }
      const result = 'zzialx';
      responseCallback(WebViewJavascriptBridgeTools.jsonStringify(result));
    });

    // 注册通用信息获取
    this._bridge.registerHandler('getInfo', (data: Object, responseCallback: WVJBResponseCallback) => {
      if (data) {
        WinLog.info('[JSBridge] 获取信息：' + JSON.stringify(data));
      }
      const result = 'zzialx';
      responseCallback(WebViewJavascriptBridgeTools.jsonStringify(result));
    });

    // 注册拍照
    this._bridge.registerHandler('takePhoto', (data: object, responseCallback: WVJBResponseCallback) => {
      if (data) {
        WinLog.info('[JSBridge] 拍照信息：' + JSON.stringify(data));
      }
      const result = '图片信息----，我是一张图片';
      responseCallback(WebViewJavascriptBridgeTools.jsonStringify(result));
    });

    // 初始化桥接
    this._bridge.registerHandler('init', (data: object, responseCallback: WVJBResponseCallback) => {
      if (data) {
        WinLog.info('[JSBridge] 初始化信息：' + JSON.stringify(data));
      }

      const initInfo =
        '{"appProjectName":"Mars eFEX",' +
          '"baseUrl":"https://smartefex-uat.mars.com",' +
          '"env":"uat",' +
          '"cookie":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjIwODY1ODc2NDAsInVzZXJuYW1lIjoiXCIxNzc1NTQ3NjQwNDE5YTkzMjM0ZTMtODIwNC00NmRmLWIyNGUtMmZhZWJmNjRhZTFiXCIifQ.BsM3OlkKy6H4bGLw_IfdKA8wVykF2vFAeR4JaFt36ZE",' +
          '"userName":"WincTest_VanSales1",' +
          '"userId":"1769904494381367297",' +
          '"isOffLine":"1",' +
          '"appVersion":"V1.5.7",' +
          '"cameraCompress":"90"}';

      PreferenceMgrTool.saveAppInitData(initInfo);

      MainPageViewModel.getServerTime();

      MainPageViewModel.getLaunchVersionInfo();

      responseCallback(WebViewJavascriptBridgeTools.jsonStringify(''));
    });
  }

  /**
   * 从 H5 获取信息
   */
  private _getH5Info(): void {
    WinLog.info('[MainPage] 登录的 userId: ' + userId());
    TimeUtils.getCurrentTime();
    WinFileUtils.uploadLogFile();
    AppUtil.setLanguage('en');
    WinLog.info('[MainPage] 设置语言：' + AppUtil.getLanguage());
  }

  /**
   * 选择图片
   */
  private _selectPhoto(): void {
    PhotoMgrTool.selectSingleImage().then((uris: string[] | undefined) => {
      if (uris && uris.length > 0) {
        const uri = uris[0];
        WinLog.info('[MainPage] 选择照片 uri：' + JSON.stringify(uris));
        MainPageViewModel.uploadImage(uri);
      }
    });
  }

  /**
   * 跳转到其他App（地图）
   */
  private _jumpOtherApp(): void {
    WinPullMapTool.pullMap('北京市东升科技园二期6号院4栋', WinMapType.GD);
  }
  /**
   * 扫码功能
   */
  private _startScan(): void {
    MainPageViewModel.startScanForResult();
  }
  /**
   * 图片浏览器功能
   */
  private _startPhotoBrowser(): void {
    let imageList:Resource[] = [$r('app.media.1'),$r('app.media.2'),$r('app.media.foreground')];
    HMRouterMgrTool.push('PhotoBrowserPage',imageList);
  }
  /**
   * 提示框
   */
  private _toast(msg: string): void {
    // 预留扩展
  }

  build(): void {
    Column() {
      this.webView();
      this.actionView();
    }
    .width(CommonStyleConstants.Full_Size)
    .height(CommonStyleConstants.Full_Size)
    .padding({ bottom: CommonStyleConstants.Bottom_SafeArea });
  }
}