import { WinBaseFuncBean } from "./WinBaseFuncBean";
export class GTYFuncBean{
  fv:string;
  fc:string;
  constructor(fv:string,fc:string) {
    this.fv = fv;
    this.fc = fc;
  }
}

@Builder
function MyBuilder() {}
export class WinBottomTabBean{
  title:string;
  selectImage: Resource;
  defaultImage: Resource;
  isSelected: boolean = false;
  titleColor:string;
  selectTitleColor:string;
  fv:string;
  funcBean:GTYFuncBean;
  builderPage:MutableBuilder<[GTYFuncBean]> = mutableBuilder(MyBuilder);
  constructor(title:string,selectImage:Resource,defaultImage:Resource,titleColor:string,
    selectTitleColor:string,fv:string,funcBean:GTYFuncBean,builderPage:MutableBuilder<[GTYFuncBean]>) {
    this.title = title;
    this.selectImage = selectImage;
    this.defaultImage = defaultImage;
    this.titleColor = titleColor;
    this.selectTitleColor = selectTitleColor;
    this.fv = fv;
    this.funcBean = funcBean;
    this.builderPage = builderPage;
  }
}