import { DateUtil, ToastUtil, ObjectUtil, AppUtil } from '@pura/harmony-utils'
import CommonRequestConstants from '../constants/CommonRequestConstants'
import { JSON } from '@kit.ArkTS'
import { WinBaseResponseModel } from '../bean/WinBaseResponseModel'
import httpService, { ApiResponse } from '../../utils/HttpRequest'
import WinLog from '../../utils/WinLog'
import { PreferenceMgrTool } from '../tool/PreferenceMgrTool'
import PreferencesConstants from '../constants/PreferencesConstants'
import CommonGlobalConstants from '../constants/CommonGlobalConstants'
import { ParseServerDataManager } from '../../database/parsedata/ParseServerDataManager'

// ============================================================
// 请求体
// ============================================================

export interface LoginAppReq {
  username: string
  password: string
}

export interface LoginWebViewReq {
  userAccount: string
  userPassword: string
}

export interface ChangePasswordReq {
  userAccount: string
  password: string
  newPass: string
  newPass2: string
}

// ============================================================
// 响应模型
// ============================================================

export class WinProdSpecModel {
  s?: string
}

export class LoginResponseModel extends WinBaseResponseModel {
  securityKey?: string
  prodspec?: string[]
}

// ============================================================
// API 函数 — 只做 HTTP
// ============================================================

/** 登录 */
export const loginApp = (req: LoginAppReq): Promise<ApiResponse<LoginResponseModel>> => {
  const params = new Map<string, string | object>([
    ["empId", ""],
    ["loginConfigParams", CommonRequestConstants.Login_Config_Params],
    ["version", CommonRequestConstants.App_Version],
    ["password_encrypt", CommonRequestConstants.Password_Encrypt],
    ["product", CommonRequestConstants.Product],
    ["osVersion", CommonRequestConstants.System_Version],
    ["imei", CommonRequestConstants.App_ImeiId],
    ["AKU", 'HM'],
    ["systemVersion", CommonRequestConstants.System_Version],
    ["unUploadDataNum", '0'],
    ["username", req.username],
    ["password", req.password],
  ])
  return httpService.post<LoginResponseModel>({ url: CommonRequestConstants.Login_Method, params })
}

/** WebView 登录（获取 cookie） */
export const loginWebView = (req: LoginWebViewReq): Promise<string> => {
  const params = new Map<string, string>([
    ["userAccount", req.userAccount],
    ["userPassword", req.userPassword],
    ["password_encrypt", CommonRequestConstants.Password_Encrypt],
  ])
  return httpService.postForm({ url: CommonRequestConstants.Base_Url_Cookie, params })
}

/** 修改密码 */
export const changePassword = (req: ChangePasswordReq): Promise<ApiResponse<WinBaseResponseModel>> => {
  const params = new Map<string, string | object>([
    ["userAccount", req.userAccount],
    ["password", req.password],
    ["newPass", req.newPass],
    ["newPass2", req.newPass2],
  ])
  const url = `${CommonRequestConstants.CHANGE_PSW_METHOD}&mobileUploadTime=${DateUtil.getTodayTime()}`
  return httpService.post<WinBaseResponseModel>({ url, params })
}
