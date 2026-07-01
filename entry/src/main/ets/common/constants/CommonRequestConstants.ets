/*
 * Copyright (c) 2024.7.18 WinSFA Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import {DeviceUtil} from '@pura/harmony-utils'
import deviceInfo from '@ohos.deviceInfo';

export default class CommonRequestConstants {
  //切换环境
  static readonly Base_Url_ImageIcon: string = 'https://sit.winsfa.com/gsk_otc3/';
  //test url
  static readonly Base_Url_Test: string = 'https://sfa-uat.corpnet5.com:7001/';

  // static readonly Base_Url_Uat: string = 'https://sfa-uat.corpnet5.com:7001/';
  //
  // static readonly Base_Url_Rel: string = 'https://sfa-otc3.haleon.cn/otc-mobile/';

  static readonly Base_Url_Cookie: string = 'login.do?noresponsebody=1'

  static readonly Request_Method = 'POST';
  //超时时间
  static readonly TimeOut: number = 5000;

  //method
  static readonly QUERY_METHOD: string = 'mobile/get.do?method=dataInfo';

  static readonly UPLOAD_METHOD:string = 'mobile/post.do?method=save'

  static readonly CHANGE_PSW_METHOD:string = 'mobile/post.do?method=onChangePass'

  static readonly Login_Method: string = 'mobile/get.do?method=login'

  static readonly SAVE_IMAGE_Method: string = 'mobile/post.do?method=saveImg'


  static readonly URL_UPLOAD:string =   `${CommonRequestConstants.Base_Url_Test}${CommonRequestConstants.UPLOAD_METHOD}`

  static readonly URL_UPLOAD_IMAGE  =   `${CommonRequestConstants.Base_Url_Test}${CommonRequestConstants.SAVE_IMAGE_Method}`


  //返回结果压缩,默认为0
  static readonly RES_COMPRESS:string = '0'
  //请求是否加密
  static readonly Password_Encrypt:string = '0'
  //配置信息
  static readonly Login_Config_Params = '1'
  //产品标识
  static readonly Product = 'skotcnew'
  //设备信息
  static readonly App_Device_Type = deviceInfo.deviceType;

  static readonly App_Brand = deviceInfo.brand;

  static readonly System_Version = deviceInfo.displayVersion

  static readonly App_ImeiId = deviceInfo.ODID

  static readonly App_Version = '2.6'

  //用户信息
  static readonly UserInfo_EMPID = 'UserInfoEMPID'
  //登录日期
  static readonly UserInfo_BIZDATE = 'BizeDate'

  static readonly SERVER_REQUIRE = 'serverRequire'

  //报表sign ey
  static readonly UserInfo_SECURITY_KEY =  'securityKey'

  static readonly UserInfo_Login_Name =  'UserInfoLoginName'

  static readonly UserInfo_Login_Psw =  'UserInfoLoginPsw'

  static readonly Content_Type_Value = 'application/json'

  static readonly Response_No_Data   = '暂无数据'

  //存储module_fc
  static readonly TOP_MODULE_FC = 'TOP_MODULE_FC'

  static readonly SHOW_LOADING = true

  /*
   * 问卷或者照片上传成功标志
   */
  static readonly UPLOAD_FLAG_SUCCESS = '1';
  /*
    * 问卷或者照片上传失败标志
    */
  static readonly UPLOAD_FLAG_FAILURE = '0';

  /*
   * 上传数据是否是照片
   */
  static readonly IS_PHOTO  = '1'

  /*
   * 上传非照片数据
   */
  static readonly NOT_PHOTO  = '0'
}