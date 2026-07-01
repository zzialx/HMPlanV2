/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

/**
 * Common constants for all features.
 */
export default class CommonConstants {
  /**
   * The main ability tag.
   */
  static readonly TAG_ABILITY: string = 'EntryAbility';

  /**
   * The login page tag.
   */
  static readonly TAG_LOGIN_PAGE: string = 'LoginPage';

  /**
   * The main page tag.
   */
  static readonly TAG_MAIN_PAGE: string = 'MainPage';

  /**
   * The common utils tag.
   */
  static readonly TAG_COMMON_UTILS: string = 'CommonUtils';

  /**
   * The mine page list item cell tag.
   */
  static readonly TAG_LIST_ITEM: string = 'ListItem';

  /**
   * The mine page tag.
   */
  static readonly TAG_MINE_PAGE: string = 'MinePage';

  /**
   * Login text.
   */
  static readonly LOGIN_TEXT: string = 'login';

  /**
   * Toast duration.
   */
  static readonly TOAST_DURATION: number = 3000;

  /**
   * Title text of the home page.
   */
  static readonly HOME_TITLE: string = '首页';

  /**
   * Title text of the setting page.
   */
  static readonly MINE_TITLE: string = '更多';

  /**
   * Home tab index.
   */
  static readonly HOME_TAB_INDEX: number = 0;
  /**
   * Mine tab index.
   */
  static readonly ATTENDANCE_TAB_INDEX: number = 1;
  /**
   * Mine tab index.
   */
  static readonly WORK_TAB_INDEX: number = 2;
  /**
   * Mine tab index.
   */
  static readonly MINE_TAB_INDEX: number = 3;
  /**
   * More tab index.
   */
  static readonly More_TAB_INDEX: number = 4;

  /**
   * Swiper cache count of the number 3.
   */
  static readonly SWIPER_CACHE_COUNT: number = 3;

  /**
   * Main page url.
   */
  static readonly MAIN_PAGE_URL: string = 'pages/MainPage';

  /**
   * Login page url.
   */
  static readonly LOGIN_PAGE_URL: string = 'pages/LoginPage';

  /**
   * Break point sm of the tag.
   */
  static readonly SM: string = 'sm';

  /**
   * Break point md of the tag.
   */
  static readonly MD: string = 'md';

  /**
   * Break point lg of the tag.
   */
  static readonly LG: string = 'lg';

  /**
   * Width condition sm filter.
   */
  static readonly WIDTH_CONDITION_SM: string = '(320vp<=width<520vp)';

  /**
   * Width condition md filter.
   */
  static readonly WIDTH_CONDITION_MD: string = '(520vp<=width<840vp)';

  /**
   * Width condition lg filter.
   */
  static readonly WIDTH_CONDITION_LG: string = '(840vp<=width)';

  /**
   * Login page button id.
   */
  static readonly LOGIN_BUTTON_ID: string = 'loginButtonId';

  static readonly SUB_LENGTH: number = 300;

  /**
   * Tablet device type.
   */
  static readonly TABLET_DEVICE_TYPE: string = 'tablet';

  static readonly VISIT_TITLE: string = '门店拜访';

  static readonly Manger_TITLE: string = '门店管理';

  static readonly SELECT_ROUTE_ID_KEY     = 'RouteIDKey';

  static readonly TAB_PAD_BOTTOM   = 90.0

  static readonly CONTAINER_ID:string   = '__container__'

  static readonly CHAT_URL: string = 'https://webchat.7moor.com/wapchat.html?accessId=d98dc810-66de-11e7-8641-530759df689b&otherParams={"nickName":"winsfa+ios"}&clientId=124_1799601';

  static readonly LIST_COUNT: number = 5;

  static readonly CHAT_SWITCH_VALUE = 'CHAT_SWITCH_VALUE'

  static readonly STORES_OBJID = 'stores'

  static readonly LOADING = '正在加载...'

  static readonly WEBVIEW_PAGE_NAME = 'WinReportWebViewPage'

  static readonly SHOW_REQUEST_LOADING = true;

  static readonly ACVT_ALERT_DIALOGID =  '1000010'

  static readonly IS_SIMULATOR   = true

  /*
   * 菜单Requrid配置为directaccess，直接进入下一页
   */
  static readonly  DIRECT_ACCESS = 'directaccess'
  /*
   *离开门店菜单 fv
   */
  static readonly  LEAVE_STORE_FV = 'V20S99'
  /*
    *进入门店菜单 fv
    */
  static readonly  ENTER_STORE_FV = 'V20S01'

  /*
   * 门店管理模块
   * */
  static readonly ACVT_PUBLISHER_VALUE = '1'

  /*
  * 门店管理OBJID
  * */
  static readonly STORE_LIST_OBJID = 'stores'

  static readonly STORE_LIST_ROUTEID = 'RouteID'
  /*
   * 门店列表路线type
   * */
  static readonly STORE_LIST_PLAN_TYPE = 'visit_plan_route'
}

