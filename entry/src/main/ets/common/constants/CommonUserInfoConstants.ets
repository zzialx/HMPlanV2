import { PreferencesManager } from "../utils/PreferencesUtil";
import CommonRequestConstants from "./CommonRequestConstants";


export default class CommonUserInfoConstants {
  static empId = PreferencesManager.get(CommonRequestConstants.UserInfo_EMPID) as string;
}