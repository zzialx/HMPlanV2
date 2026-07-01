import StyleConstants from '../common/constants/StyleConstants';

@Entry
@ComponentV2
export  struct NoDataPage {
  build() {
    RelativeContainer() {
      Image($r('app.media.ic_empty'))
        .width(StyleConstants.MAIN_EMPTY_W)
        .height(StyleConstants.MAIN_EMPTY_H)
        .id('Icon')
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          top:{anchor: '__container__',align:VerticalAlign.Top}
        })
        .margin({top:'40%'})
      Text($r('app.string.no_data'))
        .fontSize(13)
        .fontColor('#717171')
        .fontWeight(FontWeight.Normal)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          top:{anchor: 'Icon',align:VerticalAlign.Bottom}
        })
    }
    .height('100%')
    .width('100%')
  }
}