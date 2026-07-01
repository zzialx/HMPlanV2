//
//  WSNextStepBottomView.m
//  WinSFA
//
//  Created by winchannel on 16/8/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSNextStepBottomView.h"

#define kLeftSpace 20

#define k_BottomBarItemYOffSet ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  : (self.frame.size.height - k_BottomBarItemHeight)/2.0 )
#define k_BottomBarItemHeight ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ?  :28)

@interface WSNextStepItemBaseView : UIView

@property (nonatomic ,strong)UIImageView *imageView;
@property (nonatomic, strong)UILabel *contentLabel;

@end

@implementation WSNextStepItemBaseView

- (id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
         self.imageView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
        
        
        self.contentLabel = [[UILabel alloc]initWithFrame:self.bounds];
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textColor = [UIColor whiteColor];
        self.contentLabel.font = [UIFont systemFontOfSize:INTERFACE_IS_PHONE ? 15 : 17];
        self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:self.imageView];
        [self addSubview:self.contentLabel];
        
    }
    return self;
}

@end

@interface WSNextStepBottomView ()

@property (nonatomic, assign, readonly)NSInteger currentIndex;
@property (nonatomic, strong)NSArray *funcsArray;
//@property (nonatomic, strong)NSArray *reMainItems;
@property (nonatomic, strong)NSMutableDictionary *menuItemDict;

@end

@implementation WSNextStepBottomView

- (id)initWithFrame:(CGRect)frame funcsArray:(NSArray *)funcsArray currentIndex:(NSInteger)currentIndex{
    
    if (self = [super initWithFrame:frame]) {
       
//        _menuItems = [NSArray arrayWithArray:items];
//        _reMainItems = [NSArray arrayWithArray:remainItems];
        _funcsArray = funcsArray;
        _currentIndex = currentIndex;
        [self setSubViews];
        
    }
    return self;
}

- (void)setSubViews{
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    line.backgroundColor = [UIColor colorWithHexString:@"#bebebe"];
    [self addSubview:line];
    
    
    if (_funcsArray && _funcsArray.count > 0) {
        
        CGFloat itemWith = (self.bounds.size.width - kLeftSpace * 2) /(_funcsArray.count);
        
//        NSString *remainFirstItem = ((WSFuncsBean *)[_funcsArray firstObject]).name;
        
//        int indexPath ;
//        
//        if (remainFirstItem && remainFirstItem.length >0) {
//            indexPath = [_funcsArray indexOfObject:remainFirstItem];
//            
//        }
        
        [_funcsArray enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
            
            CGFloat itemX = itemWith * idx + kLeftSpace;
            BOOL isSlected = YES;
            if (idx > _currentIndex) {
                isSlected = NO;
            }
            
            UIImage *image ;
            if (idx  == 0 ) {
              
                image = [UIImage imageNamed:@"start_selected"];
                
            }else if (idx == _funcsArray.count -1 ){
                
                if (isSlected) {
                    image = [UIImage imageNamed:@"last_selected"];
                }else {
                    
                    image = [UIImage imageForName:@"last_unselected"];
                }
            }else{
                if (isSlected) {
                    image = [UIImage imageNamed:@"working_selected"];
                }else{
                    image = [UIImage imageNamed:@"working_unselected"];
                    
                }
            }
            
            image = [image stretchableImageWithLeftCapWidth:100 topCapHeight:10];
            
           WSNextStepItemBaseView *baseView = [[WSNextStepItemBaseView alloc]initWithFrame:CGRectMake(itemX, k_BottomBarItemYOffSet, itemWith, k_BottomBarItemHeight)];

            baseView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth;
            baseView.autoresizesSubviews = YES;
            baseView.imageView.image = image;
            baseView.contentLabel.text = ((WSFuncsBean *)[_funcsArray objectAtIndex:idx]).name;
            
            [self addSubview:baseView];
        }];
        
      }
}
@end
