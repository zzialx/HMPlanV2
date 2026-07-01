import httpService, { ApiResponse } from "../../utils/HttpRequest"
import { WinBaseResponseModel } from "../bean/WinBaseResponseModel"

export interface NavAppReq {
  params?:string
}
export class NavResponseModel extends WinBaseResponseModel {
  securityKey?: string

}
export const navApi = (req?: NavAppReq): Promise<ApiResponse<NavResponseModel>> => {
  const params = new Map<string, string | object>([])
  params.set('User-Agent','(null);wincrm;winchannel;crmi_winretailsaler')
  return httpService.get<NavResponseModel>({ url:"https://staging-navi.winc.goodyear.com.cn/2014/crmi_goodyearsaler.jpg", params })
}