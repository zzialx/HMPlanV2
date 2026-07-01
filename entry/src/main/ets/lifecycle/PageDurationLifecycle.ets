import { HMLifecycleContext } from '@hadss/hmrouter';
import {AbstractLifecycle} from './AbstractLifecycle'
import {HMLifecycleAction} from './HMLifecycleAction'

export class PageDurationLifecycle extends AbstractLifecycle {
  private timeMap: Map<string, number> = new Map();
  onShown(ctx: HMLifecycleContext): HMLifecycleAction {
    const pageName = ctx.navContext?.pathInfo.name;
    let param =  ctx.navContext?.pathInfo.param as object;
    console.info('PageDurationLifecycle onShown pageName：' + pageName)
    if (pageName) {
      this.timeMap.set(pageName, new Date().getTime())
      if (pageName=="LoginPage"){
        AppStorage.set<boolean>('loginOnPageShow', true);
      }
    }
    return HMLifecycleAction.DO_NEXT();
  }

  onHidden(ctx: HMLifecycleContext): HMLifecycleAction {
    const pageName = ctx.navContext?.pathInfo.name
    console.info('PageDurationLifecycle onHidden pageName：' + pageName)
    if (pageName && this.timeMap.has(pageName)) {
      const duration = new Date().getTime() - (this.timeMap.get(pageName) as number);
      this.timeMap.delete(pageName);
      console.info(`Page ${pageName} stay ${duration} ms`);
      if (pageName=="LoginPage"){
        AppStorage.set<boolean>('loginOnPageShow', false);
      }
      if (pageName === 'MainPage') {
        AppStorage.setOrCreate('MainPageShow', 0);
      }
      if (pageName === 'StoreDetailPage') {
        AppStorage.setOrCreate('StoreDetailPageShow', 0);
      }
      if (pageName === 'MVListAcvtPage') {
        AppStorage.setOrCreate('MVListAcvtPageShow', 0);
      }
    }
    return HMLifecycleAction.DO_NEXT();
  }

  // onWillShow(ctx: HMLifecycleContext): HMLifecycleAction {
  //   const pageName = ctx.navContext?.pathInfo.name
  //   if (pageName === 'MainPage') {
  //     AppStorage.setOrCreate('MainPageShow', 1);
  //   }
  //   return HMLifecycleAction.DO_NEXT();
  // }
}