//
//  WSMsgsBean_Component_msg.h
//  WinSFA
//
//  Created by heju on 15/11/30.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSMsgsBean_msg.h"

@interface WSMsgsBean_Component_msg : WSMsgsBean_msg<I_W_BuildInfo>

// 对于msg含附件类型的
@property (nonatomic,strong) NSObject<IAttachment> * attachment;
@end
