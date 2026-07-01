//
//  WSGlobalFunction.h
//  WinSFA
//
//  Created by winchannel on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#ifndef WinSFA_WSGlobalFunction_h
#define WinSFA_WSGlobalFunction_h

#define WSImg(name) [UIImage imageNamed:name]

#define WSRect(x,y,w,h) CGRectMake(x,y,w,h)

#define ZERORECT WSRect(0,0,0,0)

#define k_TableViewContentWidth ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 205 : (205 * UI_XFactor))
#endif
