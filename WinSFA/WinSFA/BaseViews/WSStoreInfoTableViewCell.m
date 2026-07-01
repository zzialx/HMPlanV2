//
//  WSStoreInfoTableViewCell.m
//  WinSFA
//
//  Created by xiajl on 14-10-31.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSStoreInfoTableViewCell.h"
#import "WSAcvtListDataItem.h"
#import "WSImagePathTable.h"
#import "NSString+Additions.h"
#import "WSRequestHelper.h"

#define RightLabelMaxWidth 80


#define LabelLeftSpace (INTERFACE_IS_PHONE ? 15 : 20)
#define LabelLeftSpaceShowAction (INTERFACE_IS_PHONE ? 50 : 60)
#define LabelTopSpace 14
#define LabelBottomSpace 14
#define LabelRightSpace (INTERFACE_IS_PHONE ? 15 : 15)
#define LabelGap 10
#define kEventLabelWidth 8.0f

#define TopLabelFont FONT_SIZE_PINGFANG_MEDIUM(15)
#define RightLabelFont FONT_SIZE_PINGFANG_MEDIUM(INTERFACE_IS_PHONE ? 13 : 15)
#define BottomLabelFont FONT_SIZE_PINGFANG_MEDIUM(12)

#define RightLabelColor [UIColor colorWithHexString:@"#333333"]

#define K_LEFT_ICON_HEIGHT 30

#define K_LEFT_ICON_WIDTH 30


static UIEdgeInsets normalEdgeInsets;
static UIEdgeInsets actionTipEdgeInsets;

@interface WSStoreInfoTableViewCell ()
{
    CGFloat cellHeight;
    
    UIImageView *isVisitedImageView;
}
@property (nonatomic, assign)WSStoreInfoTableViewCellStyle tableViewCellStyle;

@property (nonatomic, assign)UIEdgeInsets textEdgeInset;

@end

@implementation WSStoreInfoTableViewCell

+ (void)load {
    
    normalEdgeInsets = UIEdgeInsetsMake(LabelTopSpace ,LabelLeftSpace, LabelBottomSpace ,LabelRightSpace);
    
    actionTipEdgeInsets = UIEdgeInsetsMake(LabelTopSpace, LabelLeftSpaceShowAction, LabelBottomSpace, LabelRightSpace);
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.indicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        CGRect newFrame = self.indicatorImageView.frame;
        newFrame.origin.x = self.contentView.width - 10 - self.indicatorImageView.width;
        newFrame.origin.y = LabelTopSpace;
        self.indicatorImageView.frame = newFrame;
        
        isVisitedImageView = [[UIImageView alloc]initWithImage:[UIImage imageForName:@"visit_done"]];
        isVisitedImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:isVisitedImageView];
        
        self.leftIcon = [[UIImageView alloc] init];
        [self.leftIcon setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.leftIcon];
        
        self.topLabel = [[UILabel alloc] init];
        self.topLabel.font = FONT_SIZE_PINGFANG_MEDIUM(15);;
        self.topLabel.backgroundColor = [UIColor clearColor];
        self.topLabel.textColor = MAIN_TEXT_COLOR;
        self.topLabel.numberOfLines = 0;
        self.topLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.topLabel];
        
        self.bottomLable = [[UILabel alloc] init];
        self.bottomLable.font = FONT_SIZE_PINGFANG_MEDIUM(12);
        self.bottomLable.textColor = [UIColor grayColor];
        self.bottomLable.backgroundColor = [UIColor clearColor];
        self.bottomLable.numberOfLines = 0;
        self.bottomLable.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.bottomLable];
        
        self.leftLable = [[UILabel alloc] init];
        self.leftLable.font = BottomLabelFont;
        self.leftLable.textColor = [UIColor grayColor];
        self.leftLable.numberOfLines = 0;
        self.leftLable.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:self.leftLable];
        
        self.rightLable = [[UILabel alloc] init];
        self.rightLable.font = FONT_SIZE_PINGFANG_MEDIUM(12);
        self.rightLable.textColor = RightLabelColor;
        self.rightLable.textAlignment = NSTextAlignmentRight;
        self.rightLable.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.rightLable];
        
        self.tableViewCellStyle = WSStoreInfoTableViewCellStyleDefault;
        
        self.textEdgeInset = normalEdgeInsets;
    }
    return self;
}


- (void)setData:(WSAcvtListDataItem *)acvtItem
{

    self.isNotRead = NO;
    self.leftIconUrl = acvtItem.leftIconUrl;
    NSArray * imagePathArray = [[WSImagePathTable sharedTable]queryWithImageIDX:acvtItem.leftIconUrl];
    // 如果leftIconUrl 是 IMG_IDX  则取本地图片的最后一张  SFA 项目 SFA-5467

    if (imagePathArray.count) {
        WSImagePathObject * object = [imagePathArray lastObject];
        UIImage * image = [[SDImageCache sharedImageCache] imageFromKey:object.img_path fromDisk:YES];
        if (image) {
            self.leftIcon.image = image;
        }
    }else{
        if ([acvtItem.leftIconUrl length] > 0) {
        
            [[WSRequestHelper shareInstance]  downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:acvtItem.leftIconUrl] imageView:self.leftIcon placeholderImage:[UIImage imageForName:@"place_holder"]];
        }else {
            self.leftIcon.image  = nil;
        }
    }


    self.topLabel.text = acvtItem.mainTitle;
    self.bottomLable.attributedText = acvtItem.subTitle;
    self.leftLable.text = acvtItem.leftTitle;
    self.rightLable.text = acvtItem.rightTitle;
    self.isNotRead = acvtItem.unRead;
    
    if (acvtItem.rightTitle.length > 0) {
        if (acvtItem.rightTitleColor.length > 0) {
            self.rightLable.textColor = [UIColor colorWithHexString:acvtItem.rightTitleColor];
        } else {
            self.rightLable.textColor = RightLabelColor;
        }
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    isVisitedImageView.hidden = YES;
    [self.eventCountLabe removeFromSuperview];
    if (self.isShowActionTip ) {
        self.textEdgeInset = actionTipEdgeInsets;
    }
    
    CGFloat spaceBetweenLeftIconAndTitle = LabelLeftSpace;
    
    if (self.leftIcon.image) {
        self.textEdgeInset = actionTipEdgeInsets;
        
        // MN-248 为保持页面协调此处加入优先使用图片大小设置frame的逻辑
        CGFloat imageWidth = self.leftIcon.image.size.width;
        CGFloat imageHeight = self.leftIcon.image.size.height;
        
        if (imageWidth < K_LEFT_ICON_WIDTH - 10.0 && imageHeight < K_LEFT_ICON_HEIGHT - 10.0) {

            self.leftIcon.frame = CGRectMake(LabelLeftSpace, (self.contentView.height - imageHeight)/2, imageWidth, imageHeight);
            
            spaceBetweenLeftIconAndTitle = 5.0;
            
        }else
            self.leftIcon.frame = CGRectMake(LabelLeftSpace, (self.contentView.height - K_LEFT_ICON_HEIGHT)/2, K_LEFT_ICON_WIDTH, K_LEFT_ICON_HEIGHT);
    }else{
        self.leftIcon.frame = CGRectMake(0, 0, 0, 0);
    }
    
    cellHeight = 0.;

    CGSize rightTitleSize;
    rightTitleSize = [WSStoreInfoTableViewCell getStringSizeWithFont:RightLabelFont width:-1 andText:self.rightLable.text];
    
    if (self.isNotRead) {
        
        self.eventCountLabe = [[UILabel alloc] init];
        
        self.eventCountLabe.frame = CGRectMake( 7, self.textEdgeInset.top + 5, kEventLabelWidth, kEventLabelWidth);
        [self.eventCountLabe setBackgroundColor:[UIColor redColor]];
        
        [self.eventCountLabe setTextColor:[UIColor whiteColor]];
        
        [self.eventCountLabe setFont:[UIFont systemFontOfSize:12]];
        
        [self.eventCountLabe setTextAlignment:NSTextAlignmentCenter];
        
        [self.contentView addSubview:self.eventCountLabe];
        
        self.eventCountLabe.layer.cornerRadius = kEventLabelWidth / 2.0;
        
        self.eventCountLabe.clipsToBounds = YES;

    }
    
//    if (self.leftIconUrl) {
//        self.leftIcon.size = CGSizeMake(K_LEFT_ICON_WIDTH, K_LEFT_ICON_HEIGHT);
//        self.leftIcon.center = CGPointMake(self.textEdgeInset.left/2, self.contentView.height/2);
//    }
    
//    self.leftIcon.frame = CGRectMake(self.textEdgeInset.left/4, (self.contentView.height - K_LEFT_ICON_HEIGHT)/2, K_LEFT_ICON_WIDTH, K_LEFT_ICON_HEIGHT);

    self.leftIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    CGFloat leftIconWidth = self.leftIcon.frame.origin.x + self.leftIcon.frame.size.width;
    
    if (self.topLabel.text
        && [self.topLabel.text length] > 0) {
        CGRect topLableFrame;
        
        CGFloat indicatorWidth = 0;
        if (!self.indicatorImageView.hidden) {
            indicatorWidth = self.contentView.width - self.indicatorImageView.origin.x;
        }
        CGFloat topLabelWidth = self.contentView.width - self.textEdgeInset.left - self.textEdgeInset.right - (rightTitleSize.width > 0 ? rightTitleSize.width + LabelGap : 0) - indicatorWidth;
        
        CGSize stringSize = [WSStoreInfoTableViewCell getStringSizeWithFont:TopLabelFont width:topLabelWidth andText:self.topLabel.text];
        
        if (self.isNotRead) {
            topLableFrame = CGRectMake(leftIconWidth + spaceBetweenLeftIconAndTitle + 5, self.textEdgeInset.top , stringSize.width, stringSize.height);
        }
        else{
            topLableFrame = CGRectMake(leftIconWidth + spaceBetweenLeftIconAndTitle, self.textEdgeInset.top , stringSize.width, stringSize.height);
        }
        
        
        if (self.isVisited)
        {//已经拜访了
            CGFloat imageWidth  = 24;
            CGFloat imageHeight = 24;
            isVisitedImageView.hidden = NO;
            isVisitedImageView.frame = CGRectMake(topLableFrame.origin.x, topLableFrame.origin.y-2, imageWidth,imageHeight);
            self.topLabel.frame = CGRectMake(CGRectGetMaxX(isVisitedImageView.frame), topLableFrame.origin.y, topLableFrame.size.width, topLableFrame.size.height);
        }else
        {//还没有拜访
            isVisitedImageView.hidden = YES;
            self.topLabel.frame       = topLableFrame;
        }

        
    } else {
        self.topLabel.frame = CGRectZero;
    }
    
    NSInteger numOfLeftSpace = 4;
    
    if (rightTitleSize.width && rightTitleSize.width > 0) {
        numOfLeftSpace = 5;
    }
    /*SFA-15658 SFA立白【经销商】iOS，促销核销，活动页面第二页，当前状态和活动类型顺序不对*/
    CGFloat bottomLabelWith = self.contentView.width - leftIconWidth - LabelLeftSpace*numOfLeftSpace - rightTitleSize.width;
    CGSize bottomStringSize = [WSStoreInfoTableViewCell getStringSizeWithFont:BottomLabelFont width:bottomLabelWith andText:self.leftLable.text];
    if (self.leftLable.text
        && [self.leftLable.text length] > 0) {
        if (self.isNotRead) {
            self.leftLable.frame = CGRectMake(leftIconWidth + LabelLeftSpace + 5, self.topLabel.bottom + LabelGap , bottomLabelWith, bottomStringSize.height);
        }
        else{
            self.leftLable.frame = CGRectMake(leftIconWidth + LabelLeftSpace, self.topLabel.bottom + LabelGap , bottomLabelWith, bottomStringSize.height);
        }
        
    }
    
    if (self.rightLable.text) {

        CGFloat labelWidth = rightTitleSize.width;
        CGFloat originX = self.contentView.width - labelWidth - self.textEdgeInset.right;
        CGFloat originy = (self.height - rightTitleSize.height) / 2.0;
        if ([self.leftLable.text length] > 0 && !INTERFACE_IS_PAD) {
          //  originy = self.leftLable.origin.y + (self.leftLable.height - rightTitleSize.height)/2;

       }
         //判断indicator是否隐藏，如果显示则调整rightLable的左边距
        if (!self.indicatorImageView.hidden) {
            originX -= self.contentView.size.width - self.indicatorImageView.frame.origin.x;
        }
        
        if (IOS7_OR_LATER) {
            self.rightLable.frame = CGRectMake(originX, originy, labelWidth, rightTitleSize.height);
        } else {
            if (INTERFACE_IS_PAD) {
                self.rightLable.frame = CGRectMake(originX - 100, originy, labelWidth, rightTitleSize.height);
            }
        }
    }
    
    if (self.bottomLable.text) {
        CGFloat indicatorWidth = 0;
        if (!self.indicatorImageView.hidden) {
            indicatorWidth = self.contentView.width - self.indicatorImageView.origin.x;
        }
        if (self.rightLable.text) {
            indicatorWidth = self.contentView.width - self.rightLable.origin.x;
        }
        
        CGFloat leftLabelWidth = self.contentView.width - self.textEdgeInset.left - self.textEdgeInset.right - indicatorWidth;
        
        CGSize leftTitleSize = [self.bottomLable.text ws_sizeWithFont:self.bottomLable.font constrainedToWidth:leftLabelWidth];
        
        
        CGFloat labelWidth = leftTitleSize.width;
        
        //2017-0925-yuanji-modify CGFloat originX = self.textEdgeInset.left;
        CGFloat originX = leftIconWidth + LabelLeftSpace;
        if (self.isNotRead)
            originX = leftIconWidth + LabelLeftSpace + 5;
        
        //       SFA-19047 donghong
        CGFloat originy = CGRectGetMaxY(self.topLabel.frame) > CGRectGetMaxY(self.leftLable.frame) ? CGRectGetMaxY(self.topLabel.frame) : CGRectGetMaxY(self.leftLable.frame) ;
        //  YIHAIKERRY-2426  zhiqing  这个布局应为  左边 top  left bottom 结构  左边布局不应参照右边。 已经测试SFA-19047这个jira没问题
//        originy = CGRectGetMaxY(self.rightLable.frame) > originy ? CGRectGetMaxY(self.rightLable.frame) : originy ;
        originy +=LabelGap;//self.height - leftTitleSize.height - LabelGap;
        self.bottomLable.frame = CGRectMake(originX, originy, labelWidth, leftTitleSize.height);
    }
    
    CGPoint center = self.indicatorImageView.center;
    center.y = self.contentView.center.y;
    self.indicatorImageView.center = center;
}

- (void)setReadonly:(BOOL)readonly
{
    _readonly = readonly;
    if (readonly) {
        self.contentView.backgroundColor = MAIN_CELL_DISABLE_COLOR;
    }else {
        self.contentView.backgroundColor = WHITE_COLOR;
    }
}

+ (CGFloat)cellHeightWithMainTitle:(NSString *)mainTitle rightTitle:(NSString *)rightTitle subTitle:(NSString *)subTitle leftTitle:(NSString *)leftTitle tableWidth:(CGFloat)tableWidth isShowActionTip:(BOOL)isShowActionTip isNotRead:(BOOL)isNotRead isShowLeftIcon:(BOOL)show
{
    
    CGFloat width = tableWidth;
    if (!IOS7_OR_LATER) {
        width -= (INTERFACE_IS_PAD ? 110 : 30);
    }else {
        width -= (INTERFACE_IS_PAD ? 50 : 33);
    }
    
    UIEdgeInsets textEdgeInsets = normalEdgeInsets;
    if (isShowActionTip || show) {
        textEdgeInsets = actionTipEdgeInsets;
    }
    
    CGFloat resultHeight = textEdgeInsets.top;
    
    CGFloat rightLabelWidth = 0;
    if ([rightTitle length] > 0) {
        rightLabelWidth = [WSStoreInfoTableViewCell getStringSizeWithFont:RightLabelFont width:-1 andText:rightTitle].width;
    }
    
    CGFloat topLabelWidth = width - textEdgeInsets.left - textEdgeInsets.right - (rightLabelWidth > 0 ? rightLabelWidth + LabelGap : 0);

    resultHeight += [WSStoreInfoTableViewCell getStringSizeWithFont:TopLabelFont width:topLabelWidth andText:mainTitle].height;
    
    if ([subTitle length] > 0) {
        
        CGFloat bottomLabelWidth = width - textEdgeInsets.left - textEdgeInsets.right;
        
        if (isNotRead) {
            bottomLabelWidth -= 5;
        }
        
        resultHeight += [WSStoreInfoTableViewCell getStringSizeWithFont:BottomLabelFont width:bottomLabelWidth andText:subTitle].height + LabelGap;
        
    }
    
    if ([leftTitle length] > 0) {
        
        CGFloat  indicatorWidth = 20 +10 ;
        CGFloat leftTitleLabelWidth =  width - indicatorWidth;
        if (rightTitle.length > 0) {
            leftTitleLabelWidth = leftTitleLabelWidth - rightLabelWidth;
        }
        if (isNotRead) {
            leftTitleLabelWidth -= 5;
        }
        
        resultHeight += [WSStoreInfoTableViewCell getStringSizeWithFont:BottomLabelFont width:leftTitleLabelWidth andText:leftTitle].height + LabelGap / 2;
    }
    
    resultHeight += textEdgeInsets.bottom;
    
    if(resultHeight < MAIN_CELL_HEIGHT){
        resultHeight = MAIN_CELL_HEIGHT;
    }
    
    return resultHeight;
}

+ (CGSize)getStringSizeWithFont:(UIFont *)font width:(CGFloat)width andText:(NSString *)textString
{
    CGSize stringSize = CGSizeMake(0, 0);
    
    if (width > 0) {
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringSize = [textString boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: font} context:nil].size;
#else
        stringSize = [textString  sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
#endif
    }else{
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        stringSize = [textString sizeWithAttributes:@{NSFontAttributeName: font}];
#else
        stringSize = [textString sizeWithFont:font];
#endif
    }
    
    return stringSize;
}


@end
