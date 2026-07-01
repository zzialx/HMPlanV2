import { HttpPromise } from "@nutpi/axios";
import { lxHttpClient } from "../../utils/AxiosClient";
import HttpUtil from "../../utils/LXHttpRequestUtil";
import { ServerTimeResp } from "../bean/ServerTimeResp";


/**
 * 获取服务器时间 - 标准化写法
 */
export const getServerTime = (): Promise<ServerTimeResp> => {
  return HttpUtil.post<ServerTimeResp>('/login/getServerTime');
};

