import { HMDefaultGlobalAnimator, HMNavigation, HMRouterMgr } from '@hadss/hmrouter'
import { AttributeUpdater } from '@kit.ArkUI';
import { uiObserver } from '@kit.ArkUI';
import { PageDurationLifecycle } from '../lifecycle/PageDurationLifecycle';
import { JumpInfoInterceptor } from '../interceptor/JumpInfoInterceptor';
import { getUserAgent } from '../utils/DeviceUtils';

@Entry
@ComponentV2
struct Index {
  modifier: NavModifier = new NavModifier();
  aboutToAppear(): void {
    console.info('Index.aboutToAppear');
    getUserAgent();
    HMRouterMgr.registerGlobalLifecycle({
      lifecycle: new PageDurationLifecycle,
      lifecycleName: 'PageDuration',
      priority: 5,
    })
    HMRouterMgr.registerGlobalInterceptor({
      interceptor: new JumpInfoInterceptor(),
      interceptorName: 'JumpInfo',
      priority: 5,
    })

    uiObserver.on('navDestinationSwitch', this.getUIContext(), {
      navigationId: 'mainNavigationId'
    }, (info) => {

    })
  }

  aboutToDisappear(): void {
    uiObserver.off('navDestinationSwitch', this.getUIContext(), {
      navigationId: 'mainNavigationId'
    })
  }

  build() {
    Column() {
      HMNavigation({
        navigationId: 'mainNavigationId',
        homePageUrl: 'MainPage',
        options: {
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          modifier: this.modifier
        }
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f5')
  }
}
class NavModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.mode(NavigationMode.Stack);
    instance.navBarWidth('100%');
    instance.hideTitleBar(true);
    instance.hideToolBar(true);
  }
}