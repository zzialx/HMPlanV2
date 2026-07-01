import HttpUtil from "../../utils/LXHttpRequestUtil";
import { LoginConfigResp } from "../bean/LoginConfigResp";

// 登录配置请求参数
export interface BaseLoginConfigReq {
  version: number;
  codeType: string;
}
export const getBaseLoginConfig = (version: number, codeType: string) =>
HttpUtil.post<LoginConfigResp>('/login/baseLoginConfig/getBaseLoginConfig', { version, codeType } as BaseLoginConfigReq);

