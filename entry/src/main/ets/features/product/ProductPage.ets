import { GTYFuncBean } from "../../common/bean/WinBottomTabBean";
import { WinCustomNavBar, WinRightButtonParams } from "../../components/nav/WinCustomNavBar";
import WinLog from "../../utils/WinLog";

@ComponentV2
export struct ProductPage {
  @Param currentFuncBean?:GTYFuncBean = undefined
  @Local articleId: string = 'article_001';
  @Local resultMessage: string = '';
  // 右侧内容构建器
  @Builder
  rightContentBuilder() {
    Row({ space: 5 }) {
      Image($r('app.media.ic_add'))
        .onClick(() => {
          WinLog.info('1111111111')
        })
    }
    .padding(5)
    .width(30)
    .height(30)
  }

  // 处理右侧按钮点击
  private handleRightButtonClick(params: WinRightButtonParams): void {
    switch (params.actionType) {
      case 'save':
        this.resultMessage = `保存成功！文章ID: ${params.data['id']}`;
        WinLog.info('保存文章:' + params.data);
        break;
      case 'share':
        this.resultMessage = `分享成功！文章ID: ${params.data['id']}`;
        WinLog.info('分享文章:' + params.data);
        break;
    }
  }
  build(): void {
    Column() {
      WinCustomNavBar({
        showBackButton:false,
        title: '文章详情',
        rightContent: this.rightContentBuilder,
        onBackClick: () => {
          WinLog.info('返回');
        },
        onRightButtonClick: (params: WinRightButtonParams) => {
          // 这里也可以处理，或者交给内部方法处理
          this.handleRightButtonClick(params);
        }
      })

      Column() {
        Text(`当前文章ID: ${this.articleId}`)
          .fontSize(16)
          .margin({ top: 20 })

        Text(this.resultMessage)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ top: 10 })
      }
      .layoutWeight(1)
      .width('100%')
      .padding(16)
    }
    .backgroundColor(Color.Red)
    .width('100%')
    .height('100%')
    .padding({ bottom: 12 });
  }
}