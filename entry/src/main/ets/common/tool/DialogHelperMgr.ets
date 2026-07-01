import { common } from "@kit.AbilityKit";
import { BaseDialogOptions, DialogConfig, DialogHelper, SpinType } from "@pura/harmony-dialog";

export  class DialogHelperMgr{
  private static mInstance: DialogHelperMgr;
  private  loadingDiaLogId: string = '';

  public static getInstance(): DialogHelperMgr {
    if (!DialogHelperMgr.mInstance) {
      DialogHelperMgr.mInstance = new DialogHelperMgr();
    }
    return DialogHelperMgr.mInstance
  }
  /**
   * 弹框初始化
   * */
  static setDialogConfig(context:common.UIAbilityContext){
    DialogHelper.setDefaultConfig((config:DialogConfig) => {
      config.uiAbilityContext = context  //必须初始化上下文
      config.loading_loadSize = 60; //加载动画或进度条的大小
      config.loading_loadColor = Color.White; //加载动画或进度条的颜色
      config.loading_content = ''; //加载动画的提示文字
      config.loading_fontSize = 16; //文字大小
      config.loading_fontColor = Color.White; //文字颜色
      config.loading_backgroundColor = '#CC000000'; //背景颜色，八位色值前两位为透明度
      config.loading_borderRadius = 10; //背景圆角
      config.maskColor = '#22000000'
      config.autoCancel = false
    })
  }
  /**
   * 加载自定义弹框
   * */
  static showCustomDialog<T extends BaseDialogOptions>(builder: WrappedBuilder<[T]>, options: T){
    DialogHelper.showCustomDialog(builder, options)
  }
  /**
   * 关闭自定义弹框
   * dialogId自定义弹框id
   * */
  static closeDialog(dialogId: string){
    DialogHelper.closeDialog(dialogId);
  }

  /**
   * 加载loading框
   */
  static showLoading(){
    let oldLoadingDiaLogId = DialogHelperMgr.getInstance().loadingDiaLogId;
    if(oldLoadingDiaLogId){
      DialogHelper.closeDialog(oldLoadingDiaLogId)
    }
    DialogHelperMgr.getInstance().loadingDiaLogId = '';
    let dialogId = DialogHelper.showLoadingDialog({
      loadType: SpinType.spinN,
      loadSize: 40,
      autoCancel: false,
      backCancel: false
    })
    DialogHelperMgr.getInstance().loadingDiaLogId = dialogId;
  }
  /**
   *关闭loading框
   */
  static closeLoading(){
    let loadingDiaLogId = DialogHelperMgr.getInstance().loadingDiaLogId;
    DialogHelper.closeDialog(loadingDiaLogId)
  }
}