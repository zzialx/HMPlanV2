//
//  WSCustonView.m
//  WinSFA
//
//  Created by admin on 15/12/3.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSCustomView.h"
#import "WSMsgsBean.h"
#import "WSMsgsBean_msg.h"
#import "PopView.h"

@interface WSCustomView ()

@property(nonatomic,strong)PopView * popView;

@end

@implementation WSCustomView
-(id)initWithFrame:(CGRect)frame msgArray:(NSMutableArray *)msgArray titleName:(NSString *)titleName {
    self = [super initWithFrame:frame];
    
    if (self) {
        NSMutableArray  * isReadArray = [[NSMutableArray alloc]init];
        NSInteger itemNum = msgArray.count ;
        CGFloat btnHeight = 44 - 0.5 ;
        CGFloat btnWidth = self.width;
        UIButton * allButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
        allButton.tag = 0;
        [allButton setTitle:[NSString stringWithFormat:@"%@",titleName] forState:UIControlStateNormal];
        //        [allButton setBackgroundImage:[UIImage imageNamed:@"xiala_down_bj"] forState:UIControlStateHighlighted];
        [allButton addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
        allButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        // allButton.contentEdgeInsets = UIEdgeInsetsMake(0,20, 0, 0);
        [self addSubview:allButton];
        float btnRowNum = 0;
        //   循环添加count个选项按钮
        for (int i = 0; i < itemNum; i++)
        {
            
            WSMsgsBean * bean = msgArray[i];
            [isReadArray removeAllObjects];
            for (WSMsgsBean_msg * bean_msg in bean.msg)
            {
                NSString *key = [NSString stringWithFormat:@"%@#%@#%@", bean_msg.s, bean_msg.Id,[WSAppData getObjectbyKey:APPDATA_EMPID]];
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                NSDictionary *dic = [user dictionaryForKey:kWSMessageDomainName];
                NSNumber *number = [dic objectForKey:key];
                if ([bean_msg.isread isEqualToString:@"1"] || (number && [number boolValue]))
                {
                    
                    [isReadArray addObject:bean_msg];
                    
                }
                
            }
            if (bean.msg.count > 0) {
                ++ btnRowNum ;
            }
            
            //            [btn setBackgroundImage:[UIImage imageNamed:@"xiala_down_bj"] forState:UIControlStateHighlighted];
            NSInteger isReadNum = isReadArray.count;
            NSInteger allNum = bean.msg.count;
            if (allNum != 0) {
                UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, (btnRowNum ) * btnHeight, btnWidth, 0.5)];
                label.backgroundColor = [UIColor whiteColor];
                UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, (btnRowNum ) * btnHeight, btnWidth, btnHeight)];
                
                [btn setTitle:[NSString stringWithFormat:@"%@(%ld/%ld)",bean.name,(long)isReadNum,(long)allNum] forState:UIControlStateNormal];
                
                btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                //  btn.contentEdgeInsets = UIEdgeInsetsMake(0,20, 0, 0);
                btn.tag = i + 1 ;
                
                // btn.tag = [bean.Id intValue];
                [btn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:label];
                [self addSubview:btn];
            }
            
            
        }
        
    }
    
    
    
    return self;
}

-(void)selectBtn:(UIButton*)btn{
    
    if ([self.delegate respondsToSelector:@selector(selectBtn:)]) {
        [self.delegate selectBtn:btn];
    }
    
    
}

@end
