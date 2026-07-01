//
//  WSiConImageWithProgressAndStatusIcon.h
//  WinSFA
//
//  Created by winchannel on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSiConImageWithProgress.h"

@interface WSiConImageWithProgressAndStatusIcon : WSiConImageWithProgress{
    
    UIImageView  *statusIcon;
}


-(void)setStatsIconHidden:(BOOL)isHidden;
@end
