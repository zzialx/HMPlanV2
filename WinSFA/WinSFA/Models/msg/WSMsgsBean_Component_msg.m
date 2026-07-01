//
//  WSMsgsBean_Component_msg.m
//  WinSFA
//
//  Created by heju on 15/11/30.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSMsgsBean_Component_msg.h"

@implementation WSMsgsBean_Component_msg
@synthesize attachment;



#pragma mark -
#pragma mark I_W_BuildInfo method
- (NSString *)getAcvtQstId {
    return self.Id;
}

- (NSString *)getQuestPos {
    return self.title;
}

-(NSObject<IAttachment> *)getMediaInfo{
    
    
    return  attachment;
}

-(void)setI_Media_Info:(NSObject<IAttachment> *)attachmentin{
    
    attachment = attachmentin;
    
}

- (NSString *)getDefaultValue {
    return self.fileUrl;
}
- (NSString *)getQuestName {
    return self.fileName;
}
@end
