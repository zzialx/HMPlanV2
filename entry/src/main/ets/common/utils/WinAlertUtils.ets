import { CustomAlertDialogType, WinDrawerAlertOptions } from "../../components/alert/WinCustomAlertDialog";
import { AsyncCallback } from "@kit.BasicServicesKit";
import StyleConstants from "../constants/StyleConstants";
import { DialogHelperMgr } from "../tool/DialogHelperMgr";
import { alertPageBuilder } from "../builder/DialogBuilder";

export enum CustomAlertBtnType{
  CONFIRM,
  CANCEL
}
export class  WinAlertUtils {
  /*
   * 通用的alert
   * @param dialogId
   * @param msg 提示语
   * @param callBack回调
   */
  static showAlert(dialogId: string, msg: Resource | string, callBack?: AsyncCallback<CustomAlertBtnType>) {

    let drawer: WinDrawerAlertOptions = {
      width: StyleConstants.FULL_PARENT,
      msg: msg,
      type: CustomAlertDialogType.normal,
      dialogId: dialogId,
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: 0 },
      onKeyBlock: (confirm: boolean) => {
        DialogHelperMgr.closeDialog(dialogId);
        if (confirm) {
          if (callBack) {
            callBack(undefined, CustomAlertBtnType.CONFIRM)
          }
        } else {
          if (callBack) {
            callBack(undefined, CustomAlertBtnType.CANCEL)
          }
        }
      }
    };
    DialogHelperMgr.showCustomDialog(wrapBuilder(alertPageBuilder), drawer)
  }
}