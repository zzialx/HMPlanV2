import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { AppUtil } from '@pura/harmony-utils';

@ComponentV2
export struct LXNavigationBar {
  // 状态栏高度（动态获取）
  @Local statusBarHeight: number = 0;
  // 导航栏高度（默认56vp）
  @Param navHeight: number = 56;
  // 导航栏背景色
  @Param navBGColor: ResourceColor = '#00EB01';
  // 标题文本颜色
  @Param titleColor: ResourceColor = Color.White;
  // 标题文本
  @Param title: string = "标题";
  // 是否显示返回按钮
  @Param showBack: boolean = true;
  // 返回按钮回调
  @Param @Require onBack?: () => void;
  // 右侧自定义插槽
  @BuilderParam rightBuilder: () => void;

  // 获取状态栏高度
  aboutToAppear() {
    const context = this.getUIContext();
    if (context) {
      window.getLastWindow(context.getHostContext())
        .then((win) => {
          const avoidArea = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          this.statusBarHeight =  context.px2vp(avoidArea.topRect.height)
        })
        .catch((error: BusinessError) => {
          console.error(`获取状态栏高度失败: ${error}`);
        });
    }
  }

  // 设置返回回调
  setBackAction(callback: () => void) {
    // if (this.onBack) {
    //   this.onBack = callback;
    // }
  }

  build() {
    Column() {
      // 状态栏占位
      Row().height(this.statusBarHeight).width('100%')
      // 导航栏主体
      Row() {
        // 左侧返回按钮
        if (this.showBack) {
          Row(){
            Image($r('app.media.ic_white_back'))
              .width(24)
              .height(24)
          }
            .width(56)
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
            if (this.onBack) this.onBack();
          })
        }

        // 中间标题区域（固定宽度+滚动）
        Text(this.title)
          .fontSize(18)
          .fontColor(this.titleColor)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .width('70%')
          .height('100%')
        // 右侧自定义插槽
        if (this.rightBuilder){
            Row(){
              this.rightBuilder()
            }.justifyContent(FlexAlign.End)
            .padding({ right: 16 })
            .height('100%')
            .layoutWeight(1)
        }

      }
      .height(this.navHeight)
      .width('100%')
      .backgroundColor(this.navBGColor)
    }
    .width('100%')
    .height(this.statusBarHeight + this.navHeight)
    .backgroundColor(this.navBGColor)
  }
}