import { GTYFuncBean } from "../../common/bean/WinBottomTabBean";
import { WinCustomNavBar } from "../../components/nav/WinCustomNavBar";
import WinLog from "../../utils/WinLog";

@ComponentV2
export struct MinePage {
  @Param currentFuncBean?:GTYFuncBean = undefined

  build(): void {
    Column() {
      WinCustomNavBar({
        showBackButton:false,
        title: '我的',
      })
      Text('我的')
    }
    .backgroundColor(Color.Red)
    .width('100%')
    .height('100%')
    .padding({ bottom: 12 });
  }
}