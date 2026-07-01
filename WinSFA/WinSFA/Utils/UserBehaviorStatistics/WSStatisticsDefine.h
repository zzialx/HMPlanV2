//
//  WSStatisticsDefine.h
//  WinSFA
//
//  Created by yang on 17/6/1.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#ifndef WSStatisticsDefine_h
#define WSStatisticsDefine_h


//scene 场景
#define SCENE_LOGIN     @"scene_login"    //登录
#define SCENE_WEB_PAGE  @"scene_web_page"    //报表
#define SCENE_NORMAL_PAGE   @"scene_normal_page"
#define SCENE_MENU          @"scene_menu"   // 点击菜单场景
#define SCENE_ADDPRODUCT    @"scene_table"  // 主品场景 -- 用于订单模块
#define SCENE_VISIT_STORE    @"scene_visit_store"  // 进店 --- 现用于立白项目进店查看二维码
#define SCENE_ACVT      @"scene_acvt"   //点击问卷上的控件 ----- 现用于点击保存草稿问题
#define SCENE_ADD_ACVT      @"scene_add_acvt"   // 点击添加订单按钮


//event 事件
/*
事件名称	事件ID	备注
点击登录	event_click_login   	开始时间
登陆时网络类型	event_net_type
获取登陆数据	event_get_login_data  	开始时间   结束时间
登陆串大小	event_login_data_size
解压后的登陆串大小	event_login_data_size_unzip
解压缩	event_unzip  	开始时间    结束时间
转化成JSON时间	event_new_json         	开始时间    结束时间
各个节点解析时间	event_parse_node_func2          	开始时间    结束时间
解析数据 	event_login_and_parsedata_end
首页进入	event_enter_homepage
首页渲染完毕	event_homepage_load_end
 */

//scene_login 登录场景：
#define EVENT_CLICK_LOGIN @"event_click_login"
#define EVENT_NET_TYPE @"event_net_type"
#define EVENT_GET_LOGIN_DATA @"event_get_login_data"
#define EVENT_LOGIN_DATA_SIZE @"event_login_data_size"
#define EVENT_LOGIN_DATA_SIZE_UNZIP @"event_login_data_size_unzip"
#define EVENT_UNZIP @"event_unzip"
#define EVENT_NEW_JSON @"event_new_json"
#define EVENT_PARSE_NODE_PREFIX @"event_parse_node_"
#define EVENT_LOGIN_AND_PARSEDATA_END @"event_login_and_parsedata_end"
#define EVENT_ENTER_HOMEPAGE @"event_enter_homepage"
#define EVENT_HOMEPAGE_LOAD_END @"event_homepage_load_end"


//eventid  scene_acvt、scene_table
#define EVENT_BUTTON_CLICK                        @"event_button_click"    // 点击按钮 --- 现用于 请扫码、删除、保存草稿
#define EVENT_TABLE_ADD_LEVEL2_CLICK              @"event_table_add_level2_click" // 点击订单左边类目
#define EVENT_TABLE_ADD_LEVEL1_CLICK              @"event_table_add_level1_click"   // 点击订单左边一级类目

#define EVENT_TABLE_ADD_CLICK                     @"event_table_add_click"  // 选择产品事件id
#define EVENT_TABLE_ADD_PRODUCT_CAT               @"event_table_add_product_cat"  // 选择产品事件id -- 只用于"特价 和 买赠" 类目添加产品
#define EVENT_STORE_INFO    @"event_store_info"     // 进入门店 --- 现用于 查看门店二维码
#define EVENT_MENU_CLICK    @"event_menu_click"     //点击菜单事件

//scene_web_page 报表场景：
#define EVENT_WEB_PAGE_START @"event_web_page_start"   //报表加载开始
#define EVENT_WEB_PAGE_END @"event_web_page_end"       //报表加载结束


//scene_normal_page 普通页面：
#define EVENT_PAGE_START @"event_page_start"    //页面加载开始
#define EVENT_PAGE_END @"event_page_end"        //页面加载结束



#endif /* WSStatisticsDefine_h */
