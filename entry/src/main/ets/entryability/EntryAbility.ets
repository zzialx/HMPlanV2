import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { InitializeAllLoggers } from 'winloglib';
import { DialogHelperMgr } from '../common/tool/DialogHelperMgr';
import { AppUtil } from '@pura/harmony-utils';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    InitializeAllLoggers(this.context.filesDir);

    DialogHelperMgr.setDialogConfig(this.context)

    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // 1. 获取主窗口
    this.mainWindow = windowStage.getMainWindowSync();
    // 2. 设置全屏（隐藏状态栏和导航栏）
    let sysBarProps: window.SystemBarProperties = {
      statusBarColor: '#00FFFFFF',
      statusBarContentColor: '#000000',
      navigationBarColor: '#00FFFFFF',
      navigationBarContentColor: '#000000',
    };
    this.mainWindow.setWindowLayoutFullScreen(true)
    this.mainWindow.setWindowSystemBarProperties(sysBarProps)
    // 3. 初始获取避让区数据（状态栏、导航栏高度）
    this.updateAvoidAreaData();
    // 4. 监听避让区变化（如屏幕旋转、折叠屏展开）
    this.mainWindow.on('avoidAreaChange', (data: window.AvoidAreaOptions) => {
      console.info(`避让区变化: ${JSON.stringify(data)}`);
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        // 更新状态栏高度
        AppStorage.setOrCreate('statusBarHeight', data.area.topRect.height);
      } else if (data.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        // 更新导航栏高度
        AppStorage.setOrCreate('navBarHeight', data.area.bottomRect.height);
      }
    });
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
    AppUtil.init(this.context)

    AppStorage.setOrCreate("windowStage", windowStage);

  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
  // 更新避让区数据到全局存储
  private updateAvoidAreaData() {
    if (!this.mainWindow) return;
    try {
      // 获取系统默认避让区（通常包含状态栏）
      const systemArea = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      AppStorage.setOrCreate('statusBarHeight', systemArea.topRect.height);
      // 获取导航指示器避让区
      const navArea = this.mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      AppStorage.setOrCreate('navBarHeight', navArea.bottomRect.height);
    } catch (err) {
      console.error(`获取避让区数据失败: ${JSON.stringify(err)}`);
    }
  }
}