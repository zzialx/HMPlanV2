//
//  WSImageViewPanel.m
//  WinSFA
//
//  Created by huzepei on 17/1/4.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSImageViewPanel.h"
#import "I_W_BuildInfo.h"

#import "I_W_DataSource.h"

#import "I_Lua_Target_Operator.h"

#import "WidgetConstant.h"

#import "WSInterAction.h"

#import "I_W_DisplayValue.h"

#import "WSStringValueChangeChecker.h"

#import "WSValidateTextView.h"

#import "NSString+Additions.h"

#import "WSServerIPList.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "WSJSONBuilder.h"
#import "WSPhotoLogicService.h"
#import "WSPersonnalImageViewController.h"
#import "WSApplicationWindowsRelationManager.h"
#import "WSRequestHelper.h"

@implementation WSImageViewPanel

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        return self;
    }
    return nil;
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alterHeadPortrait:)];
    //给ImageView添加手势
    [self addGestureRecognizer:singleTap];

    BOOL orientition = NO;
    
    if ([xbuildInfo getOrientation] && [[xbuildInfo getOrientation] isEqualToString:@"1"])
    {
        orientition = YES;
    }
    
    int twidth = orientition ? (self.width - CGRectGetMaxX(titleLabel.frame) - MAIN_CELL_PADDING) :(self.width - titleLabel.frame.origin.x * 2);
    
    int i_xPosition = orientition ? (CGRectGetMaxX(titleLabel.frame)) : titleLabel.frame.origin.x;
    
    NSString * displayValue=[self getMyDisplayValue];
    
    float width=UI_Font+20;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage scaledImageForName:@"arrow_right" ofType:@"png"]];
    
    imageView.frame = CGRectMake(self.width - imageView.size.width - MAIN_CELL_PADDING, (self.height - imageView.size.height)/2, imageView.size.width, imageView.size.height);
    
    [self addSubview:imageView];
    
    self.headImageView=[[UIImageView alloc]initWithFrame:CGRectMake(i_xPosition+twidth-width-10 - imageView.width, (self.bounds.size.height-width)/2, width, width)];
    self.headImageView.layer.cornerRadius=self.headImageView.frame.size.width/2;//裁成圆角
    self.headImageView.layer.masksToBounds=YES;
    
    if(displayValue && displayValue.length>0){
        UIImage *  image = [[SDImageCache sharedImageCache] imageFromKey:displayValue fromDisk:YES];

        if(image)
        {
           [self.headImageView setImage:image];
            self.imageID = displayValue;
        }
        else
        {
            //            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:displayValue]] placeholderImage:[UIImage imageNamed:@"headportrait_normal"]];
            
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:displayValue] imageView:self.headImageView placeholderImage:[UIImage imageNamed:@"headportrait_normal"] progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
             
                NSString * genID = [[[WSJSONBuilder gen_uuid] md5] lowercaseString];
                LogInfo(@"imageID:%@",genID);
                if (genID == nil) {
                    return;
                }
                if (image) {
                    NSNumber *imgCompress = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImgCompress"];
                    [[SDImageCache sharedImageCache] storeImage:image imageImgCompress:imgCompress forKey:genID toDisk:YES toDocument:YES isSynchronized:YES];
                    
                    self.imageID = genID;
                } else {
                    LogError(@"download image error: %@ , url:%@", error.localizedDescription, [WSHttpURLHelper getImageCompleteURL:displayValue]);
                }
            }];
        }
    }
    else
    {
        [self.headImageView setImage:[UIImage imageNamed:@"headportrait_normal"]];
    }

    [self addSubview:self.headImageView];
    
}

#pragma mark
#pragma mark 事件处理
-(void)alterHeadPortrait:(UITapGestureRecognizer *)gesture{
    NSString * displayValue= [self getMyDisplayValue];
    WSPersonnalImageViewController *personnalImageVC = [[WSPersonnalImageViewController alloc] initWithImageID:self.imageID ? self.imageID: displayValue];
    __weak WSImageViewPanel *imaeViewPanel = self;
    
    [personnalImageVC showPersonnalImageControllerToViewController:self.superview.viewController withBlock:^(NSString *imageID)
    {
        if (imageID.length > 0)
        {
            UIImage *  image = [[SDImageCache sharedImageCache] imageFromKey:imageID fromDisk:YES];
            if(image)
            {
                [self.headImageView setImage:image];
            }
            else
            {
                [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:imageID] imageView:self.headImageView placeholderImage:[UIImage imageNamed:@"headportrait_normal"]];
            }
            if (![imageID isEqualToString:displayValue])
            {
                imaeViewPanel.imageID = imageID;
            }
        }
        else
        {
            [self.headImageView setImage:[UIImage imageNamed:@"headportrait_normal"]];
        }
        
    }];
}
#pragma mark 功能函数
-(NSObject *)getResultDirectly{
    
    WSAcvtModel *acvtModel = nil;
    
    if ([[WSDataSourceManager sharedInstance].currentActiveModel isKindOfClass:[WSAcvtModel class]])
    {
        acvtModel = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    }
    
    if (self.headImageView.image && self.imageID && acvtModel)
    {
        return [WSPhotoLogicService getAcvtImageIndexWithFC:acvtModel.currentFuncs.fc acvtMD5:acvtModel.md5 acvtQstId:[xbuildInfo getAcvtQstId]];
    }
    else
    {
        return nil;
    }
}
- (NSString*)getMyDisplayValue
{
    //回显值
    NSString *displayValue=@"";
    NSArray *array = (NSArray *)[xdisplayValue getDisplayValueFor:xbuildInfo];
    if(array && array.count>0)
    {
        //   YIHAIKERRY-2382 //   益海嘉里-上海：我的--我的信息：回显图片显示错误
        displayValue =[WSPhotoLogicService getPhotoURLFromServerRedisValue:[array objectAtIndex:0]];
        if(!(displayValue && displayValue.length > 0))
        {
            displayValue = [array objectAtIndex:0];
        }
    }
    
    return displayValue;
}
@end
