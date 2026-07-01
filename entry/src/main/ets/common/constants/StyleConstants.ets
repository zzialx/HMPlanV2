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
 * Style constants for all features.
 */
export default class StyleConstants {
  /**
   *  Login logo component height of the parent 40.
   */
  static readonly LOGIN_LOGO_HEIGHT: string = '40%';

  /**
   *  Login bottom component height of the parent 60.
   */
  static readonly LOGIN_BOTTOM_HEIGHT: string = '60%';

  /**
   * The width or height of the component is spread across the parent component.
   */
  static readonly FULL_PARENT: string = '100%';


  static readonly HALF_PARENT: string = '50%';

  static readonly AUTO_PARENT: string = 'auto';
  /**
   * The width of button.
   */
  static readonly BUTTON_WIDTH: string = '90%';

  /**
   * Grid columns of the 4.
   */
  static readonly GRID_COLUMNS: string = '1fr 1fr 1fr 1fr';

  /**
   * Grid rows of two the 2.
   */
  static readonly GRID_ROWS: string = '1fr 1fr';

  /**
   * Home grid height of the parent 15.9.
   */
  static readonly HOME_GRID_HEIGHT: string = '15.9%';

  /**
   * Bar width lg of the parent 7.5.
   */
  static readonly BAR_WIDTH_LG: string = '7.5%' ;

  /**
   * Bar default height of the parent 7.2.
   */
  static readonly BAR_DEFAULT_HEIGHT: string = '7.2%';

  /**
   * Bar height lg of the parent 50.
   */
  static readonly BAR_HEIGHT_LG: string = '50%';

  /**
   * Component common width of the parent 95.
   */
  static readonly COMMON_WIDTH: string = '95%';

  /**
   * Input length of the account.
   */
  static readonly INPUT_ACCOUNT_LENGTH: number = 11;

  /**
   *  Input length of the password.
   */
  static readonly INPUT_PASSWORD_LENGTH: number = 40;

  /**
   *  Left padding of the input box.
   */
  static readonly INPUT_PADDING_LEFT: number = 12;

  /**
   *  Layout weight of number 1.
   */
  static readonly WEIGHT_ONE: number = 1;

  /**
   * Common Spacing of Components.
   */
  static readonly COMMON_SPACE: number = 12;

  /**
   * Logo margin bottom of the parent 50.
   */
  static readonly LOGO_MARGIN_BOTTOM: number = 50;

  /**
   * Item space of the 12.
   */
  static readonly ITEM_SPACE: number = 12;

  /**
   * Grid aspect ratio of the 1.32.
   */
  static readonly GRID_ASPECT_RATIO: number = 1.32;

  /**
   * Swiper count of the 1.
   */
  static readonly SWIPER_COUNT_ONE: number = 1;

  /**
   * Swiper count of the 2.
   */
  static readonly SWIPER_COUNT_TWO: number = 2;

  /**
   * Swiper count of the 3.
   */
  static readonly SWIPER_COUNT_THREE: number = 3;

  /**
   * List column of the 2.
   */
  static readonly LIST_COLUMN_TWO: number = 2;

  /**
   * List column of the 3.
   */
  static readonly LIST_COLUMN_THREE: number = 3;

  /**
   * List column of the 4.
   */
  static readonly LIST_COLUMN_FOUR: number = 4;

  /**
   * Image list of the 12.
   */
  static readonly IMAGE_LIST_SPACE: number = 12;
  /**
   * Grid row columns sm of the 4.
   */
  static readonly COLUMNS_SM: number = 4;

  /**
   * Grid row columns md of the 8.
   */
  static readonly COLUMNS_MD: number = 8;

  /**
   * Grid row columns lg of the 12.
   */
  static readonly COLUMNS_LG: number = 12;

  /**
   * Grid gutter of the 12.
   */
  static readonly GRID_GUTTER: number = 12;

  /**
   * Grid col span sm of the 4.
   */
  static readonly SPAN_SM: number = 4;

  /**
   * Grid col span md of the 6.
   */
  static readonly SPAN_MD: number = 6;

  /**
   * Grid col span lg of the 8.
   */
  static readonly SPAN_LG: number = 8;

  /**
   * Grid col offset md of the 1.
   */
  static readonly OFFSET_MD: number = 1;

  /**
   * Grid col offset lg of the 2.
   */
  static readonly OFFSET_LG: number = 2;

  /*
   * storeinfo detail Title
   **/
  static readonly TITLE_FONT: number   = 15;

  static readonly CONTENT_FONT: number   = 12;

  static readonly ITEM_HEIGHT: number   = 44;

  static readonly DEFAULT_STORE_ICONWH: number  = 60

  static readonly DEFAULT_SMALL_ICONWH: number  = 15

  static readonly DEFAULT_BUTTON_ICONWH: number = 20

  static readonly DEFAULT_SPACE: number        = 5

  static readonly NAV_RIGHT_PAD: number   = 12

  static readonly CONTAINER_PAD: number   = 12

  static readonly MAIN_TITLE_FONT_WEIGHT: number = 300

  static readonly NAV_HEIGHT: number      = 45

  static readonly MAIN_TITLE_COLOR: ResourceColor = '#010101'

  static readonly MAIN_STATE_FONT_WEIGHT: number = 200

  static readonly MAIN_SUBHEADING_COLOR: ResourceColor = '#C0C0C0'

  static readonly MAIN_SUBHEADING_FONT: number = 12

  static readonly MAIN_TIP_COLOR: ResourceColor = '#FF0000'

  static readonly MAIN_EMPTY_W: number = 80

  static readonly MAIN_EMPTY_H: number = 80

  //在店时长
  static readonly FLOAT_TIME_WINDOW_W: number = 40;

  static readonly FLOAT_TIME_WINDOW_H: number = 40;

  static readonly LOGIN_OUT_BUTTON_WIDTH: string = '80%';

  static readonly LOGIN_OUT_BUTTON_HEIGHT: number = 30;

  static readonly LINE_HEIGHT: number = 30;
  // todo 我的路线模块
  static readonly ROUTE_HEADER_HEIGHT = 44

  static readonly DEFAULT_ICON_WH  = 20

  static readonly SUB_HEADING_FONT= 15

  static readonly SUB_HEADING_COLOR= '#28A707'

  static readonly ROUTE_HEADER_BG_COLOR = '#f6fdf2'

  static readonly FILE_MARGIN_TOP  = 20

  static readonly FILE_ICON_WH  = 50

  static readonly FILE_NAME_W  = '80%'

  static readonly FILE_DOWN_BTN_WH  = 30

  static readonly FILE_PROGRESS_W  = 120

  /*
   * 门店管理模块，popView宽度
   * */
  static readonly POP_VIEW_WIDTH =  100

  /*
   *  门店管理模块，popView pad
   * */
  static readonly POP_VIEW_PAD =  5

  /*
 *  门店管理模块，popView item高度
 * */
  static readonly POP_VIEW_ITEM_HEIGHT =  30

  /*
  *  下拉偏移高度
  * */
  static readonly REFRESH_OFFSET_HEIGHT = 64

  /*
   *  上拉底部高度
   * */
  static readonly  REFRESH_FOOTER_HEIGHT = 44

  /*
  *  Loading 宽高
  * */
  static readonly  REFRESH_LOADING_WH  = 20

  /*
  *  Loading 提示语
  * */
  static readonly  REFRESH_LOADING_TEXT  = '正在加载中...'

  static readonly  REFRESH_LOADING_TEXT_FONT  = 12

  static readonly  REFRESH_NODATA_TEXT  = '暂无更多数据'

  /*
   * icon 大小
   * */
  static readonly  ARROW_ICON_WH =  15

  /**
   * Animation duration.
   */
  static readonly ANIMATION_DURATION: number = 300;
  /**
   *  筛选页面left
   */
  static readonly LEFT_COLUMN_W = '15%'
  /**
   *  筛选页面right
   */
  static readonly RIGHT_COLUMN_W = '85%'

  static readonly NAV_BAR_BGQ_COLOR = '#00EB01'
}