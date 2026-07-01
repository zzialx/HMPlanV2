//
//  WSiConImageWithProgress.h
//  WinSFA
//
//  Created by winchannel on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSiConImage.h"

@interface WSiConImageWithProgress : WSiConImage{
    
    UIProgressView  *progress;
    
}

-(void)setCurrentProgress:(float)myprogress;
@end
