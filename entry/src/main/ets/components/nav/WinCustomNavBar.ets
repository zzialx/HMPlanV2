import { SafeAreaUtils } from "../../utils/SafeAreaUtils";

/**
 * 优化后的自定义导航栏组件
 * 支持右侧按钮传递参数
 */
@ComponentV2
export struct WinCustomNavBar {
  /** 状态栏高度（包含刘海屏/挖孔屏区域） */
  statusBarHeight: number = SafeAreaUtils.getInstance().getStatusBarHeight()

  /** 底部导航栏高度 */
  navigationBarHeight: number = SafeAreaUtils.getInstance().getNavigationBarHeight()

  // ==================== 基础参数 ====================
  @Param title: string = '';
  @Param showBackButton: boolean = true;
  @Param backIcon: Resource | null = null;
  @Param backText: string = '';
  @Param backIconSize: number = 24;
  @Param navBackgroundColor: ResourceColor = Color.Black;
  /** 状态栏背景颜色（沉浸式模式下使用） */
  @Param statusBarBgColor: ResourceColor = Color.Black;
  @Param titleColor: ResourceColor = Color.White;
  @Param titleFontSize: number = 18;
  @Param navHeight: number = 56;
  @Param showDivider: boolean = true;
  @Param dividerColor: ResourceColor = '#E5E5E5';
  /** 是否启用沉浸式模式（默认启用） */
  @Param immersive: boolean = true;
  // ==================== 事件回调 ====================
  @Event onBackClick: () => void = () => {};

  // ✅ 右侧按钮点击回调 - 支持传递参数
  @Event onRightButtonClick: (params: WinRightButtonParams) => void = (params: WinRightButtonParams) => {};

  // ==================== 插槽 ====================
  @BuilderParam rightContent?:CustomBuilder
  @BuilderParam customBackButton: () => void = this.defaultBackButton;

  // ==================== 内部状态 ====================
  @Local isBackPressed: boolean = false;

  // ==================== 默认内容 ====================
  @Builder
  defaultRightContent() {}

  @Builder
  defaultBackButton() {
    Row({ space: 4 }) {
      if (this.backIcon) {
        Image(this.backIcon)
          .width(this.backIconSize)
          .height(this.backIconSize)
          .objectFit(ImageFit.Contain)
      } else {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(this.backIconSize)
          .fontColor([this.titleColor])
      }
      if (this.backText) {
        Text(this.backText)
          .fontSize(16)
          .fontColor(this.titleColor)
          .maxLines(1)
      }
    }
  }

  private handleBackClick(): void {
    this.isBackPressed = true;
    setTimeout(() => {
      this.isBackPressed = false;
      this.onBackClick();
    }, 100);
  }

  build() {
    Column() {
      // ==================== 状态栏占位区域 ====================
      if (this.immersive) {
        Row()
          .width('100%')
          .height(this.statusBarHeight)
          .backgroundColor(this.statusBarBgColor)
      }
      Row() {
        if (this.showBackButton) {
          Row() {
            this.customBackButton()
          }
          .width(60)
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
          .padding({ left: 16 })
          .onClick(() => this.handleBackClick())
          .opacity(this.isBackPressed ? 0.6 : 1)
          .animation({ duration: 100, curve: Curve.EaseOut })
        } else {
          Row().width(60)
        }

        Row() {
          Text(this.title)
            .fontSize(this.titleFontSize)
            .fontColor(this.titleColor)
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 8, right: 8 })

        Row() {
          if (this.rightContent) {
            this.rightContent()
          }
        }
        .width(60)
        .height('100%')
        .justifyContent(FlexAlign.End)
        .alignItems(VerticalAlign.Center)
        .padding({ right: 5 })
      }
      .width('100%')
      .height(this.navHeight)
      .backgroundColor(this.navBackgroundColor)

      if (this.showDivider) {
        Divider()
          .width('100%')
          .height(0.5)
          .color(this.dividerColor)
      }
    }
    .width('100%')
  }
}

/**
 * 右侧按钮参数类型定义
 */
@ObservedV2
export class WinRightButtonParams {
  @Trace actionType: string = '';      // 操作类型：'save' | 'edit' | 'delete' | 'share' 等
  @Trace data: Record<string, Object> = {};  // 携带的数据
  @Trace extra: string = '';           // 额外信息
}