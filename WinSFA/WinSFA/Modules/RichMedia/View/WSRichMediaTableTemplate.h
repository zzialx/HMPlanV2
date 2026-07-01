//
//  WSRichMediaTableTemplate.h
//  WinSFA
//
//  Created by zhiqing on 16/8/29.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRichModel.h"
#import "WSRichItemModel.h"


@interface WSRichMediaTableTemplate : UIView
@property(nonatomic,strong) WSRichModel *richModel;;
@property(nonatomic,weak) id delegate;
@end

@protocol WSRichMediaTableTemplateDelegate <NSObject>

-(void)popWebViewWith:(WSRichMediaTableTemplate *)view  andRichModel:(WSRichItemModel *)richModel;

@end