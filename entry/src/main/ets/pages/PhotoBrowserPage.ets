import { Banner } from "@abner/banner";
import { HMRouter, HMRouterMgr } from "@hadss/hmrouter";
import CommonStyleConstants from "../common/constants/CommonStyleConstants";
import WinLog from "../utils/WinLog";
import { LXNavigationBar } from "../view/LXNavigationBar";

@HMRouter({
  pageUrl: 'PhotoBrowserPage',
  lifecycle: 'PageDurationLifecycle',
  animator: 'pageAnimator'
})
@ComponentV2
export struct PhotoBrowserPage{
  @Local imageArray:Resource[] = [];
  @Local  isHiddenNav:boolean = true;
  @Local name:string = 'zzia'
  @Monitor('name')
  nameChange(monitor:IMonitor){
    monitor.dirty.forEach((path:string)=>{
      WinLog.info('changed from ' + `${monitor.value(path)?.before}` + ' to '+ `${monitor.value(path)?.now}`)
    })
  }
  @Event onNameChange: (newName: string) => void;

  aboutToAppear(): void {
    WinLog.info('[PhotoBrowserPage] aboutToAppear');
    this.onNameChange = (newName: string) => {
      this.name = newName; // 实际处理逻辑
    };
    this.imageArray = HMRouterMgr.getCurrentParam() as Resource[];
  }
  /*
   * 返回上一页面
   * */
  onBackAction(){
    HMRouterMgr.pop();
  }
  private handleNameChange = (newName: string) => {
    this.onNameChange?.(newName);
  }
  @Builder
  itemPage(index: number, item: Object) {
    Column() {
      Image(item as Resource)
        .onClick(()=>{
          this.isHiddenNav = false;
          this.handleNameChange('lx');
        })
    }
    .backgroundColor(Color.Pink)
    .justifyContent(FlexAlign.Center)
    .width("100%")
    .height("100%")
  }
  build() {
    Column(){
      LXNavigationBar({
        title:'浏览图',
        showBack:true,
        onBack:()=>{
          this.onBackAction();
        }
      })
        .visibility(this.isHiddenNav?Visibility.None:Visibility.Visible)
      Banner({
        data:this.imageArray,
        // itemPage:this.customChangeItemPage,
        //解决 this 指向问题
        itemPage:(index:number,item:Object)=>{
          this.itemPage(index,item)
        },
        bannerHeight:'100%',
        bannerWidth:'100%',
        onChange:(postion) =>{
          WinLog.info('滚动索引：' + postion);
          this.isHiddenNav = true;
          this.name = 'lx';
        },
        onAnimationStart:(index: number, targetIndex: number) =>{

        },
        indicator: new DotIndicator()
          .itemWidth(8)
          .itemHeight(8)
          .selectedItemWidth(8)
          .selectedItemHeight(8)
          .color(Color.Gray)
          .selectedColor(Color.Red)
      })
        .layoutWeight(1)
    }.height(CommonStyleConstants.Full_Size)
    .width(CommonStyleConstants.Full_Size)
  }
}