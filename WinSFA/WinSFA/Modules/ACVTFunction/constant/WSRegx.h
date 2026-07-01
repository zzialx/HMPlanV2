//
//  WSRegx.h
//  WinSFA
//
//  Created by winchannel on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_WSRegx_h
#define WinSFA_WSRegx_h


/**
 移动：134、135、136、137、138、139、150、151、152、157、158、159、182、183、184、187、188、178(4G)、147(上网卡)；
 联通：130、131、132、155、156、185、186、176(4G)、145(上网卡)；
 电信：133、153、180、181、189 、177(4G)；
 卫星通信：1349；
 虚拟运营商：170。
 */

#define MOBILE_PHONE_REG @"^((13[0-9])|(14[5,7])|(15[^4,\\D])|(18[0-9])|(17[0,6,7,8]))\\d{8}$"

//MN-2617 2018-05-23 正则表达式修改为 正数/负数/小数
#define NUMERIC_REG @"^(\\-|\\+)?\\d+(\\.\\d+)?$"
//#define NUMERIC_REG @"^([0-9])+|([0-9]+(\\.[0-9]+)?)$"

/*SFA-14537 create by sunhongfu 2017-11-28*/
#define MULITY_MOBILE_PHONE_REG @"^(((13[0-9])|(14[5,7])|(15[^4,\\D])|(18[0-9])|(17[0-9]))\\d{8},?)+$"

#endif
