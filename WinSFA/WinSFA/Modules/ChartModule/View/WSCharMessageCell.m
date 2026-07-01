//
//  WSCharMessageCell.m
//  WinSFA
//
//  Created by libb on 16/12/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSCharMessageCell.h"
#import "PureLayout.h"
#import "WSServerIPList.h"
#import "WSRequestHelper.h"
#import "WSChartConst.h"

#define kView_Space_Left (INTERFACE_IS_PHONE ? 15 : 20)
#define kView_Space_Top (INTERFACE_IS_PHONE ? 10 : 15)
#define kView_Height (INTERFACE_IS_PHONE ? 15 : 20)
#define UI_SubView_Font (INTERFACE_IS_PHONE ? 13.0f : 15.0f)
#define UI_SubView_Detail_Font (INTERFACE_IS_PHONE ? 11.0f : 13.0f)

#define K_VISIT_STATUS_LEFT_SPACE (INTERFACE_IS_PHONE ? 20 : 20)

#define K_NAV_BUTTON_WIDHT 70
#define K_NAV_BUTTON_HEGIHT 20

#define K_STORE_ICON_WIDHT   (INTERFACE_IS_PHONE ? 70: 90)
#define K_STORE_ICON_HEIGHT  (INTERFACE_IS_PHONE ? 70: 90)


@implementation WSCharMessageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showIndicatorImage = NO;
        [self setUpSubViews];
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


-(void)setUpSubViews {
//    NSString *isUsePhotos = [[NSUserDefaults standardUserDefaults]objectForKey:USE_STORE_PHOTOS];
    
    self.storeIcon = [UIImageView newAutoLayoutView];
    self.storeNameLabel = [UILabel newAutoLayoutView];
    
    CGFloat font = INTERFACE_IS_PAD ? (UI_SubView_Font + 5):UI_SubView_Font+2;
    self.storeNameLabel.font =[UIFont systemFontOfSize:font];
    self.storeNameLabel.numberOfLines = 1;
    self.storeNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.storeNameLabel.textColor = MAIN_TEXT_COLOR;
    
    
    self.messageLabel = [UILabel newAutoLayoutView];
    self.messageLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.messageLabel.font=[UIFont systemFontOfSize:font-2];
    
    self.messageTimeLabel = [UILabel newAutoLayoutView];
    
    
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.storeNameLabel];
    [self.contentView addSubview:self.messageTimeLabel];
    
    self.storeNameLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageTimeLabel.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.storeIcon];
    [self.storeIcon autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kView_Space_Left];
    [self.storeIcon autoSetDimension:ALDimensionHeight toSize:K_STORE_ICON_HEIGHT];
    [self.storeIcon autoSetDimension:ALDimensionWidth toSize:K_STORE_ICON_WIDHT];
    [self.storeIcon autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
   
    
//    [self.storeNameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kView_Space_Left+2];
    [self.storeNameLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.storeIcon withOffset:kView_Space_Top];
    [self.storeNameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.storeIcon withOffset:kView_Space_Left];
    
    
    
//    NSLayoutConstraint *nameWidth = [self.storeNameLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:INTERFACE_IS_PHONE ? 0.42 : 0.75 relation:NSLayoutRelationLessThanOrEqual];
    
    
    [self.messageLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.storeNameLabel withOffset:kView_Space_Top];
    [self.messageLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.storeIcon withOffset:kView_Space_Left];
    [self.messageLabel autoSetDimension:ALDimensionHeight toSize:kView_Height * 2 relation:NSLayoutRelationLessThanOrEqual];
    [self.messageLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:INTERFACE_IS_PHONE ? 0.42 : 0.65];
    
    // 右侧的部分
    
    self.messageTimeLabel = [UILabel newAutoLayoutView];
    self.messageTimeLabel.numberOfLines = 1;
    [self.contentView addSubview:self.messageTimeLabel];
//    [self.messageTimeLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.contentView];
    [self.messageTimeLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.storeNameLabel];
    [self.messageTimeLabel autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:self.contentView withOffset:-kView_Space_Left];
//    [self.messageTimeLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.contentView withMultiplier:0.22];
    self.messageTimeLabel.font = [UIFont systemFontOfSize:UI_SubView_Detail_Font+1];
    self.messageTimeLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    self.messageTimeLabel.textAlignment=NSTextAlignmentRight;
    
    //未读消息条数
    float width=K_STORE_ICON_WIDHT/4;
//    SFA-17361
//    SFA葵花药业--IOS端沟通→消息窗口中无角标提示
    self.MesNumLable=[[UILabel alloc]initWithFrame:CGRectMake(K_STORE_ICON_WIDHT,width/7.f, width, width)];
    self.MesNumLable.backgroundColor=[UIColor redColor];
    self.MesNumLable.textColor=[UIColor whiteColor];
    self.MesNumLable.text=@"";
    self.MesNumLable.font=[UIFont systemFontOfSize:UI_SubView_Detail_Font+1];
    self.MesNumLable.textAlignment = NSTextAlignmentCenter;
    self.MesNumLable.layer.masksToBounds = YES;
    self.MesNumLable.layer.cornerRadius = width * 0.5;
    self.MesNumLable.hidden=YES;
    [self.contentView addSubview:self.MesNumLable];

    
}

- (void)setIsCornerRadius:(BOOL)isCornerRadius {
    if (isCornerRadius) {
        CGRect maskFrame = CGRectMake(0, 0, K_STORE_ICON_WIDHT, K_STORE_ICON_HEIGHT);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:maskFrame cornerRadius:K_STORE_ICON_WIDHT / 2];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = maskFrame;
        maskLayer.path = maskPath.CGPath;
        self.storeIcon.layer.mask = maskLayer;
    } else {
        self.storeIcon.layer.mask = nil;
    }
}

-(void)setMsgData:(WSMsgData *)msgData {
     _msgData = msgData;

    BOOL isStore = [msgData.storeID isEqualToString:WS_MSG_NO_STORE_VALUE] ? NO : YES;
    
    if (_msgData.local_ImageID && ![_msgData.local_ImageID isEqualToString:@"null"] && [_msgData.local_ImageID length] > 0) {
        UIImage *local_Image =[[SDImageCache sharedImageCache]imageFromKey:_msgData.local_ImageID fromDisk:YES];
        [_storeIcon setImage:local_Image];
    }else{
        NSString *placeHoder = nil;
        if (isStore) {
            placeHoder = @"place_holder";
        } else {
            placeHoder = @"headportrait_normal";
        }
        [[WSRequestHelper shareInstance] downloadImageWithUrl:msgData.storeImg imageView:_storeIcon placeholderImage:[UIImage imageNamed:placeHoder]];
    }
    
    NSString *storeName = msgData.storeName;

    
    if (isStore) {
        if ([msgData.row_number length] > 0) {
            storeName = [NSString stringWithFormat:@"%@.%@",msgData.row_number,storeName];
        }
    } else if ([msgData.toChatName length] > 0) {
        storeName = msgData.toChatName;
    }
//    CGSize  storeNameSize = [storeName sizeWithFont:[UIFont systemFontOfSize: UI_SubView_Font + 1] constrainedToSize:CGSizeMake(self.contentView.bounds.size.width-_storeIcon.bounds.size.width-20, kView_Height * 3) lineBreakMode:NSLineBreakByCharWrapping];
    _storeNameLabel.text = storeName;
    NSString * msgContent = msgData.msgContent;
    
    if(msgData.msgType==EMMessageBodyTypeText){
        self.messageLabel.textColor = CELL_DETAIL_TEXTCOLOR;
        if ([msgContent hasPrefix:PHOTO_WALL_IMAGE_URL_PREFIX]) {
            msgContent = @"[图片]";
            self.messageLabel.textColor = [UIColor redColor];
        }
    }else if(msgData.msgType==EMMessageBodyTypeImage){
        self.messageLabel.textColor =[UIColor redColor];
    }else if(msgData.msgType==EMMessageBodyTypeVoice){
        self.messageLabel.textColor =[UIColor redColor];
    }else{
        self.messageLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    }
    _messageLabel.text =  msgContent;

    _messageTimeLabel.text = msgData.msgTime;
    
    CGSize msgTimeLabelSize = [_messageTimeLabel.text ws_sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Detail_Font+1] constrainedToHeight:kView_Height lineBreakMode:NSLineBreakByCharWrapping];
    [self.messageTimeLabel autoSetDimension:ALDimensionWidth toSize:msgTimeLabelSize.width + 2.0];

    CGFloat storeNameLabelWidth = self.contentView.frame.size.width - msgTimeLabelSize.width - K_STORE_ICON_WIDHT - 3 * kView_Space_Left - 5.0;
    [self.storeNameLabel autoSetDimension:ALDimensionWidth toSize:storeNameLabelWidth];
    
    NSLog(@"MesNumLable=============%@",NSStringFromCGRect(self.MesNumLable.frame));
     NSLog(@"storeIcon========%@",NSStringFromCGRect(self.storeIcon.frame));
    if(msgData.msgUnreadNum>0){
        self.MesNumLable.hidden=NO;
        NSString * unReadNum = [NSString stringWithFormat:@"%ld",(long)msgData.msgUnreadNum];
        if (msgData.msgUnreadNum > 99) {
            unReadNum = @"...";
        }
        self.MesNumLable.text = unReadNum;
    }else{
        self.MesNumLable.hidden=YES;
        self.MesNumLable.text=@"";
        self.messageLabel.textColor = CELL_DETAIL_TEXTCOLOR;
    }
    
}

+(CGFloat)heightForRowWithStore:(WSMsgData *)store cellWidth:(CGFloat)cellWidth{
    
//    /*
//     动态计算高度
//     1.门店名称  门店地址动态计算
//     2.门店编码   拜访人员及日期高度固定
//     */
//    
//    CGFloat height = kView_Space_Top;
//    
//    CGFloat width = 0.42 * cellWidth;
//   
//    CGSize size;
//    if (IOS7_OR_LATER) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        size = [store.storeName  sizeWithFont:[UIFont systemFontOfSize:UI_SubView_Font] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//#pragma clang diagnostic pop
//    }
//    else {
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//        size = [store.storeName boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : [UIFont systemFontOfSize:UI_SubView_Font]} context:nil].size;
//        size = CGSizeMake(ceilf(size.width), ceilf(size.height));
//    }
//
//    /*门店名称*/
//    height += size.height;
//    height += kView_Space_Top/2;
//    
//    CGFloat addrFontSize = INTERFACE_IS_PAD ? UI_SubView_Font:UI_SubView_Detail_Font;
//    
//    /*门店地址*/
//    CGSize addrSize ;
//    if (IOS7_OR_LATER) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        addrSize = [store.storeName  sizeWithFont:[UIFont systemFontOfSize:addrFontSize] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
//#pragma clang diagnostic pop
//    }
//    else {
//        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//        addrSize = [store.storeName boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName :[UIFont systemFontOfSize:addrFontSize]} context:nil].size;
//        addrSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
//    }
//
//    height += MAX(addrSize.height, kView_Height);
//    height += kView_Space_Top/2;
//    
//    if(height<K_STORE_ICON_HEIGHT)
//        height=K_STORE_ICON_HEIGHT+10;

//    return height;
    
    return K_STORE_ICON_HEIGHT + 20;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
