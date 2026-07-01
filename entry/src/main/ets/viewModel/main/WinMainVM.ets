import { GTYFuncBean, WinBottomTabBean } from "../../common/bean/WinBottomTabBean";
import { FactoryMapHelper } from "../../common/tool/FactoryMapHelper";
import { WinJsonUtils } from "../../common/utils/WinJsonUtils";

export class WinMainVM{

  initMainTabTuData():WinBottomTabBean[]{
    //获取 json 数据解析为WinBottomTabBean[];
    let rawDataFuncBeanArray:WinBottomTabBean[] = WinJsonUtils.readJsonFromRawFileSync('tabbar.json');
    let tabTuDataArray: WinBottomTabBean[] = [];
    let tabBarBuilder: MutableBuilder<[GTYFuncBean]> = FactoryMapHelper.getInstance().getMainComponentFactoryBuilder();
    rawDataFuncBeanArray.forEach((item: WinBottomTabBean,index:number) => {
      //暂时写死测试
      let defaultIconName =  'app.media.'+ `ic_${item.fv}_tabBar_Unselected`;
      let selectIconName = 'app.media.'+`ic_${item.fv}_tabBar_Selected`;
      let funcBean:GTYFuncBean = new GTYFuncBean(item.fv,'001');
      let tabBean: WinBottomTabBean = new WinBottomTabBean(
        item.title,
        $r(selectIconName),
        $r(defaultIconName),
        item.titleColor,
        item.selectTitleColor,
        item.fv,
        funcBean,
        tabBarBuilder
      )
      tabTuDataArray.push(tabBean);
    })
    return tabTuDataArray;
  }
}
export default new WinMainVM()