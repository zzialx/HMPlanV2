import { LXBaseRespBean } from "./BaseRespBean";

export class LoginConfigResp extends LXBaseRespBean{
  data?:WinConfigRespCast;
}
export class  WinConfigRespCast{
  configId?:string;
  clientType?:string;
  clientName?:string;
  confContent?:string;
  iosStartPage?:string;
  androidStartPage?:string;
  fontColor?:string;
  bgColor?:string;
  version?:number;
  remark?:string;
  state?:number;
  createdBy?:string;
  createdTime?:string;
  updatedBy?:string;
  updatedTime?:string;
  fileHost?:string;
  thumbnailHost?:string;
}