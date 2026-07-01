import { HMRouterMgr, HMRouterPathCallback, HMRouterPathInfo } from '@hadss/hmrouter';
import { common } from '@kit.AbilityKit';
import WinLog from '../../utils/WinLog';

export  class HMRouterMgrTool{
  /*
   * 路由初始化
   * **/
  static initHMRouterContext(context:common.Context){
    HMRouterMgr.openLog("DEBUG");
    HMRouterMgr.init({
      context: context
    })
  }
  /*
   * 路由跳转
   * **/
   static async push(pageUrl:string,param?:ESObject,isBindPage?:boolean,callback?: HMRouterPathCallback){
     if (isBindPage) {
       WinLog.info('push old page route：' + pageUrl);
       HMRouterMgr.push({pageUrl:pageUrl,param:param},callback)
       // let pageUrlName:string = ''
       // if (pageUrl) {
       //   pageUrlName = await getPageUrlWithFv(pageUrl) as string;
       // }
       // if (pageUrlName.length==0) {
       //   showToast('未配置对应的页面，请检查fv配置是否正确');
       //   return
       // }
       // WinLog.info('push new page route：' + pageUrlName);
       // HMRouterMgr.push({pageUrl: pageUrlName,param:param},callback)
     }else {
       HMRouterMgr.push({pageUrl: pageUrl,param:param},callback)
     }
  }
  static pop(pathInfo?: HMRouterPathInfo, skipedLayerNumber?: number){
    HMRouterMgr.pop(pathInfo,skipedLayerNumber)
  }
  /*
   *获取传递参数
   */
  static  getCurrentParam(): Object | null{
     return HMRouterMgr.getCurrentParam();
  }
}