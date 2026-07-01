//
//  WSShowImageTextEdgeView.m
//  WinSFA
//
//  Created by mac on 2018/1/27.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSShowQstViewForStoreListCell.h"
#import "WSBaseAcvtDBService.h"
#define kView_Height (INTERFACE_IS_PHONE ? 15 : 20)
#define KView_space 7
#define KTitle_Edge 5
#define kDisplayModel  @"BNICON"
@interface WSShowQstViewForStoreListCell()
@property (nonatomic,assign) CGPoint lastViewPoint;
@property (nonatomic,strong) UIView *lastView;
@property (nonatomic,strong) NSString *tagBottom;


@end

@implementation WSShowQstViewForStoreListCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [self initWithFrame:frame withModel:nil isHasQstHorizontal:NO tagBottom:nil]) {
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame withModel:(WSShowQstViewForStoreListCellModel *)model isHasQstHorizontal:(BOOL)isHasQstHorizontal tagBottom:(NSString *)tagBottom{
    if (self = [super initWithFrame:frame]) {
        _currentModel = model;
        _isHasQstHorizontal = isHasQstHorizontal;
        self.tagBottom = tagBottom;
        [self setUpsubViews:model];
    }
    return self;
}

-(void)setUpsubViews:(WSShowQstViewForStoreListCellModel *)model{
    if (!model)    return;
    
    self.lastViewPoint = CGPointMake(0, 0);
 
    if (self.tagBottom && [self.tagBottom isEqualToString:@"1"]) {
        [self creatShowQstModelWithQstModes:model.verticalDisplayArray andSubViews:model];
        [self creatShowQstModelWithQstModes:model.horizontalDisplayArray andSubViews:model];
    }
    else
    {
        //先显示横行的
        //再显示纵向的
        [self creatShowQstModelWithQstModes:model.horizontalDisplayArray andSubViews:model];
        [self creatShowQstModelWithQstModes:model.verticalDisplayArray andSubViews:model];
    }

}

- (void)creatShowQstModelWithQstModes:(NSArray *)qstModels andSubViews:(WSShowQstViewForStoreListCellModel *)model
{
    CGFloat btnY = self.lastViewPoint.y;
    CGFloat btnX = self.lastViewPoint.x;
    CGFloat verticalBtnY = 0.0;
    for (WSShowQstViewSingleLineModel * qstModel in qstModels) {
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self addSubview:btn];
        btn.titleLabel.font = _currentModel.titleFont;
        btn.titleLabel.numberOfLines = 0;
        UIColor * textColor;     // titleColor
        NSString * titileString = [WSShowQstViewForStoreListCell getTitleString:qstModel]; // title
        NSString * imageUrl;  // titleImage---- 可能是从本地取，也可网络回显
        UIImage * bgImage; // 背景图
        
        NSArray * array = [qstModel.qstanwser componentsSeparatedByString:@"@"];
        textColor = CELL_DETAIL_TEXTCOLOR;
        if (array.count == 2) {
            textColor = [UIColor colorWithHexString:array[1]];
        } else if (_currentModel.defaultColor) {
            textColor = _currentModel.defaultColor;
        }
        
        CGRect rect ;
        // BN 只有背景    BNICON 有背景有小ICON
        if ([qstModel.groupName hasPrefix:@"horizontal"]) {
            bgImage = [UIImage scaledImageForName:@"biankuang" ofType:@"png"];
            CGFloat titleWidth = [titileString ws_sizeWithFont:model.titleFont constrainedToHeight:kView_Height].width;
            CGFloat buttonWidth = titleWidth + 2 * KTitle_Edge;
            if ([qstModel.qstdisplaymodel isEqualToString:kDisplayModel]) {
                imageUrl = qstModel.qstIconUrl;
            }else{
                imageUrl = @"";
            }
            if ((btnX + buttonWidth + 7) > self.width) {
                btnY += kView_Height + KView_space;
                btnX = 0;
            }
            rect = CGRectMake(btnX, btnY,buttonWidth, kView_Height);
            btnX += buttonWidth + KView_space;
            self.lastView = btn;
        }else{
            // SFA-23626
            // IOS：SFA立白【经销商】手机端门店列表信息门店标注、门店分类和逾期天数标签的显示样式开发
            //当即有横向显示又有纵向显示的时候，横向优先纵向
            if (_isHasQstHorizontal && verticalBtnY <= 0) {
                verticalBtnY = self.lastView.bottom +  KView_space ;
                btnY = verticalBtnY;
            }
            CGFloat titleHeight = [titileString ws_sizeWithFont:model.titleFont constrainedToWidth:self.width].height;
            rect = CGRectMake(0, btnY, self.width , titleHeight);
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btnY += titleHeight + KView_space;
        }
    
        if (imageUrl.length > 0) {
           
        }
        
        self.lastViewPoint = CGPointMake(btnX, btnY);
        btn.frame = rect;
        if(bgImage!=nil){
            bgImage = [UIImage imageWithImage:bgImage andTintColor:textColor];
            [btn setBackgroundImage:bgImage forState:UIControlStateNormal];
        }
        [btn setTitle:titileString forState:UIControlStateNormal];
        [btn setTitleColor:textColor forState:UIControlStateNormal];
        
    }
}

+(CGFloat)getViewWidth:(WSShowQstViewForStoreListCellModel*)model{
    CGFloat viewWidth = 0;
    for (WSShowQstViewSingleLineModel * qstModel in model.displayArray)
    {
        NSString *titileString = [WSShowQstViewForStoreListCell getTitleString:qstModel];
        CGFloat titleWidth = [titileString ws_sizeWithFont:model.titleFont constrainedToHeight:kView_Height].width;
        viewWidth += titleWidth + KTitle_Edge;
    }
    
    viewWidth += (model.displayArray.count - 1) * KView_space;
    
    return viewWidth;
}
- (void)setCurrentModel:(WSShowQstViewForStoreListCellModel *)currentModel
{
    _currentModel = currentModel;
    [self setUpsubViews:currentModel];
}

- (void)setIsHasQstHorizontal:(BOOL)isHasQstHorizontal
{
    _isHasQstHorizontal = isHasQstHorizontal;
}

- (void)setMaxWidth:(CGFloat)maxWidth
{
    _maxWidth = maxWidth;
    self.width = maxWidth;
}

+(NSString *)getTitleString:(WSShowQstViewSingleLineModel*)qstModel{
    
    NSArray * array = [qstModel.qstanwser componentsSeparatedByString:@"@"];
    NSString *titileString ;
    NSString * qstanwser = array[0];
    if (!qstanwser) {
        qstanwser = @"";
    }
    if ([qstModel.hideQstName isEqualToString:@"1"]) {
        titileString = [NSString stringWithFormat:@"%@",qstanwser];
    }else{
        titileString = [NSString stringWithFormat:@"%@:%@",qstModel.qstname,qstanwser];
    }
    return titileString;
}
@end


@implementation WSShowQstViewForStoreListCellModel

@end

@implementation WSShowQstViewSingleLineModel

@end

