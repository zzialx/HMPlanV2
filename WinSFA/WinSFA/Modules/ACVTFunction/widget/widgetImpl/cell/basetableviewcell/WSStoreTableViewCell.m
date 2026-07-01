//
//  WSStoreTableViewCell.m
//  WinSFA
//
//  Created by winchannel on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSStoreTableViewCell.h"

#import "WSConstant.h"

#import "WSOpenCloseBtn.h"

#import "I_W_Cell.h"

#import "WSConstant.h"


@implementation WSStoreTableViewCell
@synthesize delegate;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellWidth:(CGFloat)width{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
   

        
        self.frame= WSRect(self.frame.origin.x, self.frame.origin.y, width, 80);

        
       status_btn = [[UIImageView alloc] initWithFrame:WSRect(5.0, self.frame.size.height/2.0-(20.0/2.0),20, 20)];
       [status_btn setImage:[UIImage imageForName:@"visit_not_start.png"]];
        
        [self.contentView addSubview:status_btn];

       store_name_label =[[UILabel alloc] initWithFrame:WSRect(status_btn.frame.origin.x+status_btn.frame.size.width+10.0,self.frame.size.height/2-(30.0/2.0),self.frame.size.width-50, 30.0)];
        store_name_label =[[UILabel alloc]init];
        [self.contentView addSubview:store_name_label];
        
        detailButton =[UIButton buttonWithType:UIButtonTypeCustom];
        
     
        
        [detailButton setFrame:WSRect(self.frame.size.width- 50.0 ,self.frame.size.height/2-(50.0/2.0),50.0, 50.0)];
        
        [detailButton setImage:[UIImage imageForName:@"i_icon.png"] forState:UIControlStateNormal];
        
        [detailButton addTarget:self action:@selector(viewTheDetail) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:detailButton];
        

        shortCutPanel = [[WSFunsShortCutPanel alloc]init];
        shortCutPanel.backgroundColor = [UIColor clearColor];
        shortCutPanel.delegate = self ;
        [self addSubview:shortCutPanel];
       
        return self;
    }
    
    return self;
    
}


-(void)awakeFromNib{
    
    [super awakeFromNib];
    
}


-(void)viewTheDetail{
    
    if ([delegate respondsToSelector:@selector(sendDetailInfo:)]) {
        
        [delegate sendDetailInfo:cell_info];
    }
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated{
    
    [super setSelected:selected animated:animated];
    
}

-(void)loadDisplayContent:(NSObject<I_W_Cell> *)dataContent{
    
   
    
    cell_info = dataContent;
    
    store_name_label.text= [NSString stringWithFormat:@"%@-%@",[dataContent getCode],[dataContent getTtitle]];
    
    if ([dataContent getAccessStatus]==1) {
        
       
       status_btn.image = [UIImage imageNamed:@"visit_doing.png"];
    }
    if ([dataContent getAccessStatus]==2) {
        
        
      status_btn.image=  [UIImage imageNamed:@"visit_done.png"];
    }

}

- (void)setTagFrame:(CGRect)cellRect
   withContentWidth:(CGFloat)contentWidth
        withContent:(NSString *)content
  withShortCutArray:(NSArray *)cutArray
             andRow:(int)row{

    status_btn.frame = CGRectMake(5.0, self.frame.size.height /2.0 - (20.0/2.0), 20, 20);
    store_name_label.frame = WSRect(status_btn.frame.origin.x+status_btn.frame.size.width+10.0,self.frame.size.height/2-(30.0/2.0),self.frame.size.width-50, 30.0);
    //加入了shortCut 详情快捷键
    CGFloat panelWidth = 74 *self.shortCutArray.count;
    shortCutPanel.frame = WSRect(self.frame.size.width - panelWidth - 40 ,self.frame.size.height/2-(30.0/2.0), panelWidth , 30);

}

-(void)clearDataContent{
    
    [status_btn setImage:[UIImage imageForName:@"visit_not_start.png"]];
    
    store_name_label.text =@"";
    
    [shortCutPanel removeAllSubviews] ;
    
}

-(void)showAccessButton:(NSString *)showCode{
    
    
    if ([showCode isEqualToString:@"0"]) {
        
        [detailButton setHidden:YES];
        
        [detailButton setUserInteractionEnabled:NO];
    
    }
    
}

- (void)showShortCutPanel:(NSArray *)shortCutArray withStorBean:(WSStoreBean *)storeBean{
    
    
    [shortCutPanel refreshImagesFromFunsBeanArray:shortCutArray withStoreBean:storeBean];
}

#pragma 详情快捷键
- (void)funsShortCutPanel:(WSFunsShortCutPanel *)funsShortCutPanel didSelectBtnFuncsBean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean{
    
    [self.delegate selectListTableViewCell:self withSlectFunsbean:bean withStoreBean:storeBean];
    
}

@end
