import { HMRouter, HMRouterMgr } from "@hadss/hmrouter";
import { DeviceUtil, NumberUtil } from "@pura/harmony-utils";
import { WinBottomTabBean } from "../common/bean/WinBottomTabBean";
import CommonConstants from "../common/constants/CommonConstants";
import StyleConstants from "../common/constants/StyleConstants";
import { HMRouterMgrTool } from "../common/tool/HMRouterMgrTool";
import WinLog from "../utils/WinLog";
import vm from '../viewModel/main/WinMainVM'

@Entry

@HMRouter({
  pageUrl: 'MainPage',
  lifecycle: 'PageDurationLifecycle',
  animator: 'pageAnimator'
})
@ComponentV2
export struct MainPage {
  @Local tabDataArray: WinBottomTabBean[]  = [];
  @Local badgeCountParam: Map<string, string> = new Map();
  @Local currentIndex: number = 0;
  @Local currentDeviceSize: string = CommonConstants.SM;
  // @StorageProp('MainPageShow') @Watch('onChangeVisibility') tabVisibility: number = 1;
  @Local tabVisibility: number = 1;
  aboutToAppear(): void {
    WinLog.info('[MainPage] aboutToAppear');
    this.tabDataArray = vm.initMainTabTuData();
  }
  aboutToDisappear(): void {
    WinLog.info('MainPage aboutToDisappear')
  }
  @Builder
  tabBuilder(index: number,item:WinBottomTabBean) {
    Column() {
      Badge({
        count: this.badgeCountParam.has(item.fv) ? NumberUtil.toInt(this.badgeCountParam.get(item.fv)) : 0,
        style: {},
        position: { x: 15, y: -5 },
      }) {
        Image(this.currentIndex === index ? item.selectImage : item.defaultImage)
          .width($r('app.float.base_tab_size'))
          .height($r('app.float.base_tab_size'))
      }

      Text(item.title)
        .margin({ top: $r('app.float.base_tab_top') })
        .fontSize($r("app.float.tab_font_size"))
        .fontColor(this.currentIndex === index ? $r('app.color.main_page_selected') : $r('app.color.main_page_normal'))
    }
    .justifyContent(FlexAlign.Center)
    .height(StyleConstants.FULL_PARENT)
    .width(StyleConstants.FULL_PARENT)
  }
  build(){
    Stack() {
      Column() {
        Tabs({
          barPosition: BarPosition.End,
          index: this.currentIndex
        }) {
          ForEach(this.tabDataArray, (item: WinBottomTabBean, index: number) => {
            TabContent() {item.builderPage.builder(item.funcBean)}
            .tabBar(
              this.tabBuilder(index, item)
            )
            .onWillShow(() => {
              WinLog.info('Page onWillShow ')
            })
            .onWillHide(() => {
              WinLog.info('Page onWillHide ')
            })
          }, (item: WinBottomTabBean, index: number) => JSON.stringify(item) + index)
        }
        .barWidth(this.currentDeviceSize === CommonConstants.LG ?
          StyleConstants.BAR_WIDTH_LG : StyleConstants.FULL_PARENT)
        .barHeight(!this.tabVisibility ? 0 : (this.currentDeviceSize === CommonConstants.LG ?
          StyleConstants.BAR_HEIGHT_LG : StyleConstants.BAR_DEFAULT_HEIGHT))
        .vertical(this.currentDeviceSize === CommonConstants.LG)
        .backgroundColor(Color.White)
        .barMode(BarMode.Fixed)
        .scrollable(false)
        .onChange((index: number) => {
          this.currentIndex = index;
          WinLog.info(CommonConstants.TAG_MAIN_PAGE + 'onChange index ' + JSON.stringify(index));
        })
      }
    }
    .height(StyleConstants.FULL_PARENT)
  }
}