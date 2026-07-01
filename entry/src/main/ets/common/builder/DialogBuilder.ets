import { WinCustomAlertDialog, WinDrawerAlertOptions } from "../../components/alert/WinCustomAlertDialog";

/*
 * 自定义alert弹框
 * **/
@Builder
export  function alertPageBuilder(options: WinDrawerAlertOptions){
  WinCustomAlertDialog({
    contentText:options.msg,
    type:options.type,
    confirmTitle:options.confirmTitle,
    cancel:()=>{
      if (options.onKeyBlock) {
        options.onKeyBlock(false);
      }
    },
    confirm:()=>{
      if (options.onKeyBlock) {
        options.onKeyBlock(true);
      }
    }
  })
}
/*
 * 自定义alert多按钮弹框
 * **/
// @Builder
// export  function alertMoreButtonDialog(options: DrawerMoreButtonAlertOptions){
//   CustomAlertMoreButtonDialog({
//     contentText:options.msg,
//     buttonArray:options.buttonArray,
//     alertButtonClick:(type:WinAlertButtonType)=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock(type)
//       }
//     }
//   })
// }
/*
 * 自定义日期选择器弹框
 * **/
// @Builder
// export  function datePickerPageBuilder(options: DrawerDatePickerOptions){
//   CustomDatePickerDialog({
//     contentText:options.msg,
//     cancel:()=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock(OnButtonType.Cancel);
//       }
//     },
//     confirm:(value:string)=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock(OnButtonType.Confirm,value);
//       }
//     },
//     delete:()=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock(OnButtonType.Delete);
//       }
//     }
//   })
// }
/*
 * 自定义dropList弹框
 * **/
// @Builder
// export  function dropListDialog(options: DrawerDropListOptions){
//   CustomDropListDialog({
//     contentText:options.msg,
//     dataSourceList:options.dataSourceList,
//     selectIDList:options.selectIDList,
//     cancel:()=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock();
//       }
//     },
//     confirm:(selectItem?:RadioItemCommonType)=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock(selectItem);
//       }
//     }
//   })
// }
/*
 * 自定义图片浏览器弹框
 * **/
// @Builder
// export  function alertPhotoBrowserBuilder(options: WinPhotoBrowserDrawerOptions){
//   WinPhotoBrowserDiaLog({
//     contentText:options.msg,
//     photoList:options.photoList,
//     cancel:()=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock(false);
//       }
//     },
//     confirmDeleteBlock:(deleteIndex?:number)=>{
//       if (options.onKeyBlock) {
//         options.onKeyBlock(true,deleteIndex);
//       }
//     }
//   })
// }