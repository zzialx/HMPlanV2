import { BaseDialogOptions } from "@pura/harmony-dialog";
/**
 * 自定义 Alert 类型
 */
export enum CustomAlertDialogType{
  normal,
  singleButton
}
/**
 * 参数接口
 */
export interface WinDrawerAlertOptions extends BaseDialogOptions {
  width: string;
  msg?: string |Resource;
  type?:CustomAlertDialogType;
  confirmTitle?:string;
  onKeyBlock?: (confirm:boolean) => void
}
@CustomDialog
export struct WinCustomAlertDialog {
  controller?: CustomDialogController;
  dialogTitle?:string | Resource = $r('app.string.alert_title')
  contentText?: string | Resource
  confirmTitle?: string| Resource = $r('app.string.alert_confirm_title')
  cancelTitle?:string| Resource = $r('app.string.alert_cancel_title')
  type?:CustomAlertDialogType = CustomAlertDialogType.normal;
  cancel: () => void = () => {}
  confirm: () => void = () => {}
  build() {
    Column() {
      Text(this.dialogTitle)
        .fontSize(ItemStyleConstants.TITLE_FONT)
        .fontColor(ItemStyleConstants.TITLE_COLOR)
        .margin({top:ItemStyleConstants.Title_Space})
      Text(this.contentText)
        .fontSize(ItemStyleConstants.Content_FONT)
        .fontColor(ItemStyleConstants.CONTENT_COLOR)
        .margin({top:ItemStyleConstants.Content_Space})
        .padding({left:ItemStyleConstants.PAD_LF,right:ItemStyleConstants.PAD_LF})
      Line()
        .backgroundColor(ItemStyleConstants.LINE_COLOR)
        .height(ItemStyleConstants.LINE_WH)
        .width('100%')
        .margin({top:ItemStyleConstants.Line_Space})
      if (this.type===CustomAlertDialogType.singleButton){
        Row(){
          Text(this.confirmTitle)
            .alertTextStyle()
            .onClick(() => {
              if (this.cancel) {
                this.cancel();
              }
            })
        }
        .width('100%')
        .height(ItemStyleConstants.BOTTOM_H)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }else{
        Row(){
          Text(this.cancelTitle)
            .alertTextStyle()
            .onClick(() => {
              if (this.cancel) {
                this.cancel();
              }
            })
            .width('50%')
          Line()
            .backgroundColor(ItemStyleConstants.LINE_COLOR)
            .height('100%')
            .width(ItemStyleConstants.LINE_WH)
          Text(this.confirmTitle)
            .alertTextStyle()
            .onClick(() => {
              if (this.confirm) {
                this.confirm();
              }
            })
            .width('50%')
        }
        .width('100%')
        .height(ItemStyleConstants.BOTTOM_H)
        .alignItems(VerticalAlign.Center)
      }

    }
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Center)
    .width(ItemStyleConstants.Self_Width)
    .borderRadius(ItemStyleConstants.Self_Radius)
  }

}
@Extend(Text) function alertTextStyle() {
  .fontSize(ItemStyleConstants.BTN_FONT)
  .fontColor($r('app.color.main_nav_bg_color'))
  .textAlign(TextAlign.Center)
}

class ItemStyleConstants {

  static readonly TITLE_FONT = 20.0;

  static readonly TITLE_COLOR = '#515151'

  static readonly Title_Space = 15.0

  static readonly Content_Space = 20.0

  static readonly Line_Space = 20.0

  static readonly Content_FONT = 15.0

  static readonly BTN_FONT = 15.0

  static readonly CONTENT_COLOR = '#6f6f6f'

  static readonly PAD_LF = 12

  static readonly LINE_COLOR = '#6f6f6f'

  static readonly LINE_WH = 0.5

  static readonly BOTTOM_H = 44.0

  static readonly Self_Width = '70%'

  static readonly Self_Radius = 5.0
}