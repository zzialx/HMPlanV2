//
//  WSMediaContentView.h
//  WinSFA
//
//  Created by winchannel on 15/4/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSCellContentView.h"
#import "IAttachment.h"


@interface WSMediaContentView : WSCellContentView<NSCopying>{
    
    UIProgressView  *downloadIndView;
    
    NSString  *mediaType;
    
    NSObject<IAttachment>  *dowloadedAttachment;
    
    NSMutableDictionary  *interactiondict;
    
}


@end
