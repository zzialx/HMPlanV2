// import { BlockController } from 'components';
import { CartPage } from '../../features/cart/CartPage';
import { MinePage } from '../../features/mine/MinePage';
import { ProductPage } from '../../features/product/ProductPage';
import { NoDataPage } from '../../pages/NoDataPage';
import { GTYFuncBean } from '../bean/WinBottomTabBean';
import { HomePage } from '../../features/home/HomePage';
import StyleConstants from '../constants/StyleConstants';

@Builder
export function  refreshFooter(isLoading:boolean) {
  Row() {
    LoadingProgress()
      .height(StyleConstants.REFRESH_LOADING_WH)
      .width(StyleConstants.REFRESH_LOADING_WH)
    Text(StyleConstants.REFRESH_LOADING_TEXT)
  }.width(StyleConstants.FULL_PARENT)
  .height(StyleConstants.REFRESH_FOOTER_HEIGHT)
  .justifyContent(FlexAlign.Center)
  .visibility(isLoading ? Visibility.Visible : Visibility.Hidden)
}



@Builder
function  minePageBuilder(funcBean:GTYFuncBean){
  MinePage({currentFuncBean:funcBean});
}
@Builder
function  cartPageBuilder(funcBean:GTYFuncBean){
  CartPage({currentFuncBean:funcBean});
}
@Builder
function  homePageBuilder(funcBean:GTYFuncBean){
  HomePage({currentFuncBean:funcBean})
}
@Builder
function  productPageBuilder(funcBean:GTYFuncBean){
  ProductPage({currentFuncBean:funcBean});
}
@Builder
function componentNoPageBuilder(funcBean:GTYFuncBean) {
  NoDataPage()
}

@Builder
function  wrapTabBarBuilder(funcBean:GTYFuncBean){
    if(funcBean.fv == 'TB_V20'){
      HomePage({currentFuncBean:funcBean});
    } else if(funcBean.fv == 'TB_V30'){
      ProductPage({currentFuncBean:funcBean});
    } else if(funcBean.fv == 'TB_V180'){
      CartPage({currentFuncBean:funcBean});
    } else if(funcBean.fv == 'TB_V200'){
      MinePage({currentFuncBean:funcBean});
    }  else {
      NoDataPage()
    }
}
/**
 * 组件工厂
 */
export  class FactoryMapHelper{
  private  factoryMap: Map<string, object> = new Map();
  private static mInstance: FactoryMapHelper;
  public static getInstance(): FactoryMapHelper {
    if (!FactoryMapHelper.mInstance) {
      FactoryMapHelper.mInstance = new FactoryMapHelper();
    }
    return FactoryMapHelper.mInstance
  }
  /*
   * 工厂组件存储builder
   */
  setComponentMapFactoryWithFV(fv:string){
    switch (fv) {
      case 'TB_V20':
        this.factoryMap.set(fv, mutableBuilder(homePageBuilder));
        break;

    }
  }
  /*
   * 工厂模式，单例模式获取builder
   */
  getComponentMapFactoryWithFV(fv:string){
    if (this.factoryMap.has(fv)) {
      return this.factoryMap.get(fv);
    }else {
      return mutableBuilder(componentNoPageBuilder);
    }
  }
  /*
   *单个fv绑定builder模式
   */
  getMainComponentFactoryBuilder() {
    return mutableBuilder(wrapTabBarBuilder) as MutableBuilder<[GTYFuncBean]>;
  }
}
