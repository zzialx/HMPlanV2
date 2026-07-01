//
//  HttpResponseServer.h
//  WinChannelFrameWork
//
//  Created by Zheng Jiepeng on 12-12-31.
//
//

#import <Foundation/Foundation.h>

@interface WSHttpResponseServer : NSObject

- (BOOL)dealWithResponse:(NSDictionary*)resposeDataDictionary localInfo:(WCBaseRequestLocalInfo *)localInfo;

@end
