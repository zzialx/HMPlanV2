import { navApi } from "../../common/api/NavApi";
import { GTYFuncBean } from "../../common/bean/WinBottomTabBean";
import CommonDialogId from "../../common/constants/CommonDialogId";
import { CustomAlertBtnType, WinAlertUtils } from "../../common/utils/WinAlertUtils";
import { WinCustomNavBar } from "../../components/nav/WinCustomNavBar";
import WinLog from "../../utils/WinLog";

@ComponentV2
export struct HomePage {
  @Param currentFuncBean:GTYFuncBean | undefined = undefined;
  aboutToAppear(): void {
    WinLog.info('HomePage aboutToAppear');
  }
  aboutToDisappear(): void {
    WinLog.info('HomePage aboutToDisappear');
  }
  homeClick(){
    navApi();
  }
  build(): void {
    Column() {
      WinCustomNavBar({
        showBackButton:false,
        title: '首页',
      })
      Text('首页')
        .onClick(()=>{
          this.homeClick();
        })
    }
    .backgroundColor(Color.Red)
    .width('100%')
    .height('100%')
    .padding({ bottom: 12 });
  }
}