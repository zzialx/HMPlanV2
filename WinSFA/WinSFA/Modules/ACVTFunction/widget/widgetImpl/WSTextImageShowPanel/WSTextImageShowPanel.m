//
//  WSTextImageShowPanel.m
//  WinSFA
//
//  Created by mac on 17/8/17.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSTextImageShowPanel.h"
#import "WSPhotoBrowseView.h"
#import "UIButton+WebCache.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_BuildInfo.h"
#import "I_W_DisplayValue.h"

#define k_ImageButton_Width  40
#define k_MainTitleLabel_Y  18
#define k_titleLabel_Height  15

#define k_photoBrowseView_Height  78

#define kImageViewGap (INTERFACE_IS_PHONE ? 10.0f : 5.0f)

@interface WSTextImageShowPanel()<WSPhotoBrowseViewDelegate>

@property (nonatomic , strong) UIButton * imageButton; // 左侧图片加文字
@property (nonatomic , strong) UILabel * mainTitleLabel; // 主标题
@property (nonatomic , strong) UILabel * subTitleLabel;  // 副标题
@property (nonatomic , strong) UIImageView * addrImageView; // 副标题前的图片
@property (nonatomic , strong) WSPhotoBrowseView * photoBrowseView; // 图片展示
@property (nonatomic , assign) BOOL isShowAddrImageView; // 是否显示地址图标
@property (nonatomic , assign) BOOL isShowPhotoBrowseView; // 是否显示图片信息
@property (nonatomic , strong) UILabel * topLine;    // 上竖线
@property (nonatomic , strong) UILabel * bottomLine;  // 下竖线

@property (nonatomic , strong) UILabel * lastBottomLine; //底部横线
@property (nonatomic , strong) UILabel * firstTopLine; //顶部横线



@end

@implementation WSTextImageShowPanel


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        return self;
    }
    
    return nil;
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
    
}
-(void)buildDisplayContent{
    [super buildDisplayContent];
    
    self.imageButton = [[UIButton alloc]initWithFrame:CGRectMake(MAIN_CELL_PADDING, MAIN_PADDING, k_ImageButton_Width, k_ImageButton_Width)];
    [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.imageButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
    [self.imageButton setTitle:[xbuildInfo getQuestName] forState:UIControlStateNormal];
    [self addSubview:self.imageButton];
    
    
    CGFloat mainTitleLabelX = self.imageButton.right  + MAIN_CELL_PADDING;
    self.mainTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(mainTitleLabelX, MAIN_PADDING, self.width - mainTitleLabelX - MAIN_CELL_PADDING, k_titleLabel_Height)];
    self.mainTitleLabel.font = [UIFont systemFontOfSize:UI_Font];
    self.mainTitleLabel.textColor = [UIColor colorWithHexString:@"#000000"];
    self.mainTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.mainTitleLabel];
    
    self.mainTitleLabel.text = [NSString stringWithFormat:@"%@ %@",[WSCurrentTime currentDay],[WSCurrentTime weedDay]];
    self.subTitleLabel = [[UILabel alloc]init];
    self.subTitleLabel.font = [UIFont systemFontOfSize:UI_Font -2];
    self.subTitleLabel.textColor = [UIColor colorFromHexCode:@"#9a9a9a"];
    self.subTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.subTitleLabel.numberOfLines = 0;
    [self addSubview:self.subTitleLabel];

    self.addrImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"info_dizhi_icon"]];
    [self addSubview:self.addrImageView];
    
    self.photoBrowseView = [[WSPhotoBrowseView alloc]initWithFrame:CGRectMake(self.mainTitleLabel.left - MAIN_CELL_PADDING - kImageViewGap, 0, self.width - self.mainTitleLabel.left - MAIN_PADDING, k_photoBrowseView_Height) funs:nil withImageIDArray:nil withSupperLocalPic:NO withSupperHttpPic:YES withMaxPhotoNum:100 delegate:self align:nil withDisPlayMode:nil];
    [self addSubview:self.photoBrowseView];
    
    self.topLine = [[UILabel alloc]initWithFrame:CGRectMake(self.imageButton.centerX - 0.25, 0, 0.5, self.imageButton.frame.origin.y)];
    self.topLine.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    self.topLine.hidden = YES;
    [self addSubview:self.topLine];
    
    self.bottomLine = [[UILabel alloc]init];
    self.bottomLine.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    self.bottomLine.hidden = YES;

    [self addSubview:self.bottomLine];

    self.lastBottomLine = [[UILabel alloc]init];
    self.lastBottomLine.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    [self addSubview:self.lastBottomLine];
    
    self.firstTopLine = [[UILabel alloc]init];
    self.firstTopLine.backgroundColor = DETAIL_SEPERATE_LINE_COLOR;
    [self addSubview:self.firstTopLine];
}
-(NSObject *)getResultDirectly{
    return (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
}
-(NSObject *)getResultPresentation{
    return (NSString *)[xdisplayValue getDisplayValueFor:xbuildInfo];
}
// YIHAIKERRY-269
-(void)setCurrentValueWithPresentation:(NSString *)valuePresentation{
    
    NSArray * valueArray = [valuePresentation componentsSeparatedByString:@","];
    self.isShowAddrImageView = NO;
    self.isShowPhotoBrowseView = NO;
    for (NSString  *valueString in valueArray) {
        NSString  *value = [[valueString componentsSeparatedByString:@"$"] lastObject];
         /*2017.10.27日 MENGNIU-896 by孙洪福 蒙牛项目 年月日没居中 根据value是否有值区分是哪个项目 配置不同frame*/
        if (value.length == 0)
        {
            _mainTitleLabel.frame = CGRectMake(self.imageButton.right  + MAIN_CELL_PADDING,_imageButton.top + (k_ImageButton_Width - k_titleLabel_Height)/2, self.width - (self.imageButton.right  + MAIN_CELL_PADDING)- MAIN_CELL_PADDING, k_titleLabel_Height);
        }
        if ([valueString containsString:@"title"]) {
            self.mainTitleLabel.text = value;
        }else if ([valueString containsString:@"address"]){
          
            self.subTitleLabel.text = value;
            self.isShowAddrImageView = YES;
        }else if ([valueString containsString:@"imgs"]){

            NSArray * imageIDArray = [value componentsSeparatedByString:@"|"];
            
            if (imageIDArray.count > 0) {
                NSString * firstImageId = [imageIDArray firstObject];
                if (firstImageId.length > 0) {
                    self.photoBrowseView.imageIDArray = imageIDArray.mutableCopy;
                    self.isShowPhotoBrowseView = YES;
                }

            }
        }else if ([valueString containsString:@"content"]){
            self.subTitleLabel.text = value;
        }else if ([valueString containsString:@"imageUrl"]){
            [self setImgUrl:value];
        }
    }
}


-(void)setProgressStateHidden:(NSString *)value{

    if ([value containsString:@"top"]) {
        if ([[[value componentsSeparatedByString:@"|"] lastObject] isEqualToString:@"true"]) {
            self.topLine.hidden = NO;
        }else{
            self.topLine.hidden = YES;
        }
    }else{
        if ([[[value componentsSeparatedByString:@"|"] lastObject] isEqualToString:@"true"]) {
            
            self.bottomLine.hidden = NO;
            self.lastBottomLine.frame = CGRectMake(SEPERATE_PADDING_Left, self.height - MAIN_CELL_SEPERATOR_HEIGHT,self.width , MAIN_CELL_SEPERATOR_HEIGHT);
        }else{
            self.bottomLine.hidden = YES;
            self.lastBottomLine.frame = CGRectMake(0, self.height - MAIN_CELL_SEPERATOR_HEIGHT,self.width, MAIN_CELL_SEPERATOR_HEIGHT);
        }
    }
    
}


-(void)setImgUrl:(NSString *)imageUrl
{
    if (imageUrl.length > 0)
    {
        //MN-2625 2018-05-31
        NSURL *url = [NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:imageUrl]];
        __weak WSTextImageShowPanel *weakSelf = self;
        [self.imageButton sd_setBackgroundImageWithURL:url forState:UIControlStateNormal
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             //去掉下载完成后的设置标题操作(下载的图片只是背景图片 文字还要用设置标题的形式显示 但需要注意 按键宽度只有40 所以配置按键标题时注意字数限制 按键标题取自[xbuildInfo getQuestName])
//             if (error == nil && image != nil)
//                 [weakSelf.imageButton setTitle:@"" forState:UIControlStateNormal];
         }];
    }
}

-(void)refreshFrame{
    
    CGFloat subTitleLabelX = 0;
    CGFloat originY = 0;
    if (self.isShowAddrImageView) {
        self.addrImageView.hidden = NO;
        self.addrImageView.frame = CGRectMake(self.mainTitleLabel.left, self.mainTitleLabel.bottom + 5, k_titleLabel_Height, k_titleLabel_Height);
        subTitleLabelX = self.addrImageView.right + 5;
        originY = self.addrImageView.top;
    }else{
        self.addrImageView.hidden = YES;
        subTitleLabelX = self.mainTitleLabel.left;
        originY = self.mainTitleLabel.bottom + 5;
    }
    
    CGFloat subTitleWidth = self.width - subTitleLabelX - MAIN_CELL_PADDING;
    CGSize size = [self.subTitleLabel.text ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font -2] constrainedToWidth:subTitleWidth];
    self.subTitleLabel.frame = CGRectMake(subTitleLabelX, originY, subTitleWidth, MAX(size.height, k_titleLabel_Height));
    originY = self.subTitleLabel.bottom;
    
    if (self.isShowPhotoBrowseView) {
        originY += 10;
        self.photoBrowseView.hidden = NO;
        self.photoBrowseView.frame = CGRectMake(self.mainTitleLabel.left - MAIN_CELL_PADDING - kImageViewGap, originY, self.width - self.mainTitleLabel.left - MAIN_PADDING, k_photoBrowseView_Height);
        originY = self.photoBrowseView.bottom;
        [self.photoBrowseView reloadData];
        [self.photoBrowseView setTakePhotoButtonHidden:YES];

    }else{
        self.photoBrowseView.hidden = YES;
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, originY + 15)];
    
    self.bottomLine.frame =  CGRectMake(self.imageButton.centerX - 0.25, self.imageButton.bottom, MAIN_CELL_SEPERATOR_HEIGHT, self.height - self.imageButton.bottom);
    if (self.bottomLine.isHidden) {
        self.lastBottomLine.frame = CGRectMake(0, self.height - MAIN_CELL_SEPERATOR_HEIGHT,self.width, MAIN_CELL_SEPERATOR_HEIGHT);
    }else{
        self.lastBottomLine.frame = CGRectMake(self.mainTitleLabel.left, self.height - MAIN_CELL_SEPERATOR_HEIGHT,self.width - self.mainTitleLabel.left , MAIN_CELL_SEPERATOR_HEIGHT);

    }
    
    if (self.topLine.isHidden) {
        self.firstTopLine.frame = CGRectMake(0, 0, self.width, MAIN_CELL_SEPERATOR_HEIGHT);
    }else{
        self.firstTopLine.frame = CGRectZero;
    }
    [self.superview setNeedsLayout];
}


-(void)layoutSubviews{
    [self refreshFrame];
}


#pragma mark  WSPhotoBrowserViewDelegate Methods
- (void)photoBrowseView:(WSPhotoBrowseView *)photoBrowseView didSelectImageId:(NSString *)imageId {
    if (!photoBrowseView.imageIDArray || !imageId) {
        return;
    }
    WSPhotoBrowserViewController *photoBrowser = nil;
 
    photoBrowser = [[WSPhotoBrowserViewController alloc] initWithImageIDs:photoBrowseView.imageIDArray];
    //}
    
    photoBrowser.delegate = photoBrowseView;

    [photoBrowser gotoPage:[photoBrowseView.imageIDArray indexOfObject:imageId]];
    
    photoBrowser.isAllowDeletePhoto = NO;
    [self.viewController presentViewController:photoBrowser animated:YES completion:nil];
}

@end
