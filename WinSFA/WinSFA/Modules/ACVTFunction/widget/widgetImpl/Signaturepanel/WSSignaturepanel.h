//
//  WSSignaturepanel.h
//  WinSFA
//
//  Created by zhiqing on 16/8/27.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSSingleTitlePanel.h"

@interface WSSignaturepanel : WSSingleTitlePanel
@property(nonatomic,strong) NSMutableArray *imageIDArray; // 最后需要上传图片
@property(nonatomic,strong) NSString *delectImageID;   // 需要删除的图片

- (void)showSignatureView;
- (NSString *) getAcvtQstId;
@end
