//
//  WCHLog.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-5-9.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef WinChannelFrameWork_WCHLog_h
#define WinChannelFrameWork_WCHLog_h

#include <Foundation/Foundation.h>

#define WCHDEBUG
    void WCHLog(NSString *format, ...)
    {
#ifdef WCHDEBUG
            va_list arglist;

            if (!format) {
                return;
            }

            va_start(arglist, format);
            // NSLogv(format,arglist);
            va_end(arglist);
#endif
    }

#endif // ifndef WinChannelFrameWork_WCHLog_h
