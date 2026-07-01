import { AppUtil, ObjectUtil, ToastUtil } from "@pura/harmony-utils"
import { changePassword, loginApp, LoginResponseModel, loginWebView, WinProdSpecModel } from "../../common/api/LoginApi"
import CommonGlobalConstants from "../../common/constants/CommonGlobalConstants"
import CommonRequestConstants from "../../common/constants/CommonRequestConstants"
import PreferencesConstants from "../../common/constants/PreferencesConstants"
import { PreferenceMgrTool } from "../../common/tool/PreferenceMgrTool"
import { ParseServerDataManager } from "../../database/parsedata/ParseServerDataManager"
import WinLog from "../../utils/WinLog"

export class WinLoginVM {

  /**
   * 登录 + 解析登录数据 + 存储公共数据
   * @param name
   * @param password
   * @returns
   */
  async loginAppWithParams(name: string, password: string): Promise<boolean> {
    try {
      const apiRes = await loginApp({ username: name, password })
      const res = apiRes as LoginResponseModel
      WinLog.info('login response:' + JSON.stringify(res))

      if (res.flag === 0 && res.msg) {
        ToastUtil.showToast(String(res.msg))
        return false
      }

      this.saveCommonData(res)
      let context = AppUtil.getContext();
      await ParseServerDataManager.parseLoginData(context, JSON.stringify(res))

      WinLog.info('登录成功' + res.empid)
      PreferenceMgrTool.set(CommonRequestConstants.UserInfo_Login_Name, name)
      return true
    } catch (err) {
      const msg = err instanceof Error ? err.message : JSON.stringify(err)
      ToastUtil.showToast(msg)
      return false
    }
  }

  /** WebView 登录 */
  loginWebView(): Promise<string> {
    const userAccount: string = PreferenceMgrTool.get(PreferencesConstants.WINC_ACCOUNT) as string
    const password: string = PreferenceMgrTool.get(PreferencesConstants.WINC_PASSWORD) as string
    return loginWebView({ userAccount, userPassword: password })
  }

  /** 修改密码 */
  async changePassword(newPassword: string, oldPassword: string): Promise<boolean> {
    const userAccount: string = PreferenceMgrTool.get(PreferencesConstants.WINC_ACCOUNT) as string
    try {
      const res = await changePassword({
        userAccount,
        password: oldPassword,
        newPass: newPassword,
        newPass2: newPassword,
      })
      WinLog.info('修改密码' + JSON.stringify(res))
      return true
    } catch (err) {
      WinLog.error('修改密码失败:' + JSON.stringify(err))
      return false
    }
  }

  /** 记住用户名密码 */
  rememberUser(isRememberUser: boolean, account: string, password: string) {
    if (isRememberUser) {
      PreferenceMgrTool.set(PreferencesConstants.WINC_ACCOUNT, account)
      PreferenceMgrTool.set(PreferencesConstants.WINC_PASSWORD, password)
      PreferenceMgrTool.set(PreferencesConstants.WINC_ISREMEBERUSER, isRememberUser)
      PreferenceMgrTool.set(PreferencesConstants.WINC_IS_AUTO_LOGIN, true)
    } else {
      PreferenceMgrTool.delete(PreferencesConstants.WINC_ACCOUNT)
      PreferenceMgrTool.delete(PreferencesConstants.WINC_PASSWORD)
      PreferenceMgrTool.delete(PreferencesConstants.WINC_ISREMEBERUSER)
      PreferenceMgrTool.set(PreferencesConstants.WINC_IS_AUTO_LOGIN, false)
    }
  }

  /** 退出登录 */
  normalLogout() {
    PreferenceMgrTool.delete(PreferencesConstants.WINC_PASSWORD)
    PreferenceMgrTool.set(PreferencesConstants.WINC_IS_AUTO_LOGIN, false)
  }

  /** 存储公共数据 */
  saveCommonData(res: LoginResponseModel) {
    PreferenceMgrTool.set(CommonRequestConstants.UserInfo_EMPID,
      ObjectUtil.isNull(res.empid) ? '' : res.empid as string)
    PreferenceMgrTool.set(CommonRequestConstants.UserInfo_BIZDATE,
      ObjectUtil.isNull(res.bizDate) ? '' : res.bizDate as string)
    PreferenceMgrTool.set(CommonRequestConstants.UserInfo_SECURITY_KEY,
      ObjectUtil.isNull(res.securityKey) ? '' : res.securityKey as string)

    const serverProdSpecValue = ObjectUtil.isNull(res.prodspec) ? [] : res.prodspec
    const prodSpecValueArr: string[] = WinLoginVM.getProdSpecValue(serverProdSpecValue)
    PreferenceMgrTool.set(CommonGlobalConstants.ProdSpec_Key, prodSpecValueArr)
  }
  static getProdSpecValue(serverProdSpecValue?: string[]): string[] {
    if (serverProdSpecValue && serverProdSpecValue instanceof Array) {
      let prodSpecList: string[] | Map<string,string>[]  = serverProdSpecValue as string[] | Map<string,string>[];
      if (prodSpecList.length > 0) {
        const prodSpecValue = prodSpecList[0];
        if (typeof prodSpecValue === "string") {
          return prodSpecValue.split(",")
        }
        if (prodSpecValue instanceof Object) {
          const prodSpecMapValue: WinProdSpecModel = JSON.parse(JSON.stringify(prodSpecValue)) as WinProdSpecModel
          const prodSpecResult = prodSpecMapValue.s
          if (prodSpecResult) {
            return prodSpecResult.split(",")
          }
        }
      }
    }
    return []
  }
}
export default new WinLoginVM()