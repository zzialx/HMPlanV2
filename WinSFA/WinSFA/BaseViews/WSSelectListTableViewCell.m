//
//  WSSelectListTableViewCell.m
//  WinSFA
//
//  Created by xiajl on 14-9-16.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSSelectListTableViewCell.h"
#import "WSEnvrionment.h"
#import "GlobalConstant.h"
#import "WSGlobalFunction.h"
#import "WSInoutStoreTable.h"

@interface WSSelectListTableViewCell ()

@property (nonatomic, strong)UIButton *imageButton;

@end

@implementation WSSelectListTableViewCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.funsBeanArray = [[NSArray alloc]init];
        
        
        //详情快捷键
        self.imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.imageButton setBackgroundImage:[UIImage imageForName:@"tag_0"] forState:UIControlStateNormal]; //内
        [self.imageButton setTitle:@"内" forState:UIControlStateNormal];
        [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.imageButton setBackgroundImage:[UIImage imageForName:@"tag_1"] forState:UIControlStateSelected]; //外
        [self.imageButton setTitle:@"外" forState:UIControlStateSelected];
        [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.imageButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        
        [self addSubview:self.imageButton];
        
        if ([WSEnvrionment getShortCut]==1) {
            
            self.imageButton = nil;
          
            self.shortCutPanel = [[WSFunsShortCutPanel alloc]init];
            self.shortCutPanel.backgroundColor = [UIColor clearColor];
            self.shortCutPanel.delegate =self ;
            
            [self addSubview:self.shortCutPanel];
            
        }
        
    }
    return self ;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    
}

-(void)clearDataContent{
    
    [self.shortCutPanel removeAllSubviews] ;
    
}

- (void) setTagFrame:(CGRect)cellRect andStyle:(ECELLTAGStyle)tagStyle {
    
    
    switch (tagStyle) {
        case ECELLTAGStyleNone:
        {
            self.imageButton.hidden = YES;
        }
            break;
        case ECELLTAGStyleInPlan:
        {
            
            self.imageButton.hidden = NO;
            [self.imageButton setSelected:NO];
        }
            break;
        case ECELLTAGStyleOutPlan:
        {
           
            self.imageButton.hidden = NO;
            [self.imageButton setSelected:YES];
        }
            break;
            
        default:
            break;
    }

    if (self.accessoryType == UITableViewCellAccessoryNone) {
        
        [self.imageButton setFrame:CGRectMake(cellRect.size.width - 30, (cellRect.size.height - 14 ) / 2., 14, 14)];

        
    }else{
        
        [self.imageButton setFrame:CGRectMake(cellRect.size.width - 54, (cellRect.size.height - 14 ) / 2., 14, 14)];
        
    }
    
    CGFloat panelWidth = self.funsBeanArray.count * 74 ;
    
    if ([WSEnvrionment getShortCut] == 1 ) {
        
        [self.shortCutPanel setFrame:CGRectMake(cellRect.size.width - 40 - panelWidth, (cellRect.size.height - 30 ) / 2., panelWidth, 30)];
        
        
    }

    
}

-(void)hiddenImageButton:(BOOL)hidden{
    
    [_imageButton setHidden:YES];
    
}

-(void)showAccessButton:(NSString *)showCode{
    
    if ([showCode isEqualToString:@"0"]) {
        
        [self setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    
}

- (void)funsShortCutPanel:(WSFunsShortCutPanel *)funsShortCutPanel didSelectBtnFuncsBean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean{
    
    [self.delegate selectListTableViewCell:self withSlectFunsbean:bean withStoreBean:storeBean];
}

- (void)showShortCutPanelData:(WSStoreBean *)storeBean withShortCutFuncsArray:(NSArray *)cutfuncsArray{

    [self.shortCutPanel refreshImagesFromFunsBeanArray:cutfuncsArray withStoreBean:storeBean];
}

@end
