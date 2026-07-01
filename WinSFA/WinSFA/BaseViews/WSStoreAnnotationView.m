//
//  WSStoreAnnotationView.m
//  WinSFA
//
//  Created by heju on 16/8/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSStoreAnnotationView.h"

static CGFloat normalStoreStypButtonWidth = 21 ;
static CGFloat normalStoreStypButtonHeight = 28 ;

static CGFloat selectStoreStypButtonWidth = 26 ;
static CGFloat selectStoreStypButtonHeight = 32 ;
static CGFloat numberButtonHeight = 15 ;


@interface WSStoreAnnotationView ()
@property(nonatomic,strong) UIButton * numButton;
@property (nonatomic , strong) UIButton * storeStypButton;
@property (nonatomic , assign) BOOL isClickView;
@property (nonatomic , strong) UIImageView * iconImageView;

@end


@implementation WSStoreAnnotationView


- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {

        self.storeAnnotation = (WSStoreAnnotation *)annotation;
        [self addSubview:_iconImageView];
        [self addSubview:_numButton];
        [self addSubview:_storeStypButton];
    }
    return self;
}
-(UIButton *)numButton{
    if (!_numButton) {
        _numButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _numButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font - 6];
        _numButton.userInteractionEnabled = NO;
    }
    return _numButton;
}

-(UIButton *)storeStypButton{
    if (!_storeStypButton) {
        _storeStypButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _storeStypButton.userInteractionEnabled = NO;
    }
    return _storeStypButton;
}
-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
    }
    return _iconImageView;
}
-(void)layoutSubviews{

    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat selfWidth = 0;
    if (self.storeAnnotation.store.row_number.length > 0) {
        if (self.isClickView) {
            _storeStypButton.frame = CGRectMake(0, 0, selectStoreStypButtonWidth, selectStoreStypButtonHeight);
            originX = selectStoreStypButtonWidth - numberButtonHeight;
            originY = selectStoreStypButtonHeight;
            selfWidth = selectStoreStypButtonWidth;
        }else{
            _storeStypButton.frame = CGRectMake(0, 0, normalStoreStypButtonWidth, normalStoreStypButtonHeight);
            originX = normalStoreStypButtonWidth - numberButtonHeight;
            originY = normalStoreStypButtonHeight;
            selfWidth = normalStoreStypButtonWidth;

        }
        _numButton.frame = CGRectMake(originX * 0.5, originY, numberButtonHeight + 5, numberButtonHeight);
        
        CGRect rect = self.frame;
        [self setFrame:CGRectMake(rect.origin.x, rect.origin.y,selfWidth, originY + numberButtonHeight)];
    }else{
        
        // MN-286  如果有回显的图片及文字，就用回显的值显示。
        if (self.storeAnnotation.store.mapPicDis) {
            _iconImageView.frame  =CGRectMake(0, 0,selectStoreStypButtonWidth - 3, selectStoreStypButtonHeight);
            NSURL * url = [NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:self.storeAnnotation.store.mapPicDis]];
            [_iconImageView sd_setImageWithURL:url];
            
        }else{
            _storeStypButton.frame = CGRectZero;
            _numButton.frame = CGRectZero;

        }
        if (self.storeAnnotation.store.dotDisplay) {
             _storeStypButton.frame = CGRectMake(0, 0,selectStoreStypButtonWidth - 3, selectStoreStypButtonHeight);
        }else{
            _storeStypButton.frame = CGRectZero;
            _numButton.frame = CGRectZero;
        }
    }
    [self setFrame:CGRectMake(self.origin.x, self.origin.y,selectStoreStypButtonWidth, selectStoreStypButtonHeight)];
}

- (void)setStoreAnnotation:(WSStoreAnnotation *)storeAnnotation {
    
    _storeAnnotation = storeAnnotation;
    self.isClickView = NO;

    if (storeAnnotation.isNewSet) {
        
        [self.storeStypButton setTitle:@"" forState:UIControlStateNormal];
        [self.storeStypButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.numButton setTitle:@"" forState:UIControlStateNormal];
        [self.numButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self setImage:nil];
        
        NSString *imgStr = (storeAnnotation.annotationImgStr.length > 0 ? storeAnnotation.annotationImgStr : @"map_gray");
        UIImage *annotationImage = [UIImage scaledImageForName:imgStr ofType:@"png"];
        if (storeAnnotation.isShowRowNumber && storeAnnotation.store.row_number.length > 0) {
            UIImage *image = [UIImage scaledImageForName:@"bg_map_number" ofType:@"png"];
            [self.numButton setBackgroundImage:image forState:UIControlStateNormal];
            [self.numButton setTitle:self.storeAnnotation.store.row_number forState:UIControlStateNormal];
            [self.storeStypButton setBackgroundImage:annotationImage forState:UIControlStateNormal];
        } else {
            [self setImage:annotationImage];
        }

        [self layoutSubviews];
        return;
    }
    
    UIImage *annotationImage;
    [self.storeStypButton setTitle:@"" forState:UIControlStateNormal];
    [self.storeStypButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self setImage:nil];
    
    if (storeAnnotation.store.row_number.length > 0) {
        annotationImage = [UIImage scaledImageForName:@"bg_map_number" ofType:@"png"];
        [self.numButton setBackgroundImage:annotationImage forState:UIControlStateNormal];
        [self.numButton setTitle:self.storeAnnotation.store.row_number forState:UIControlStateNormal];
        if (storeAnnotation.store.isAcctuallyAndInPlanStore) {
            annotationImage = [UIImage scaledImageForName:@"map_purple" ofType:@"png"];
            
        }
        else if ([storeAnnotation.store.actionState isEqualToString:@"1"] || storeAnnotation.store.isAcctuallyRouteStore) {
            annotationImage = [UIImage scaledImageForName:@"map_red" ofType:@"png"];
            
        }else if ([storeAnnotation.store.actionState isEqualToString:@"2"]){
            annotationImage = [UIImage scaledImageForName:@"icon_visiting" ofType:@"png"];
            
        }else if (storeAnnotation.store.plan){
            annotationImage = [UIImage scaledImageForName:@"map_green" ofType:@"png"];
            
        }else{
            [self.storeStypButton setTitle:self.storeAnnotation.store.styp forState:UIControlStateNormal];
            annotationImage = [UIImage scaledImageForName:@"map_blue" ofType:@"png"];
            
        }
        
    }else{
        if ([storeAnnotation.store.actionState isEqualToString:@"1"]) {
            annotationImage = [UIImage scaledImageForName:@"map_red" ofType:@"png"];
            
        }else if ([storeAnnotation.store.actionState isEqualToString:@"2"]){
            annotationImage = [UIImage scaledImageForName:@"icon_visiting" ofType:@"png"];
            
        }
        else {
            if (storeAnnotation.store.plan || storeAnnotation.store.bPlanned) {
                annotationImage = [UIImage scaledImageForName:@"map_green" ofType:@"png"];
            }else {
                annotationImage = [UIImage scaledImageForName:@"map_gray" ofType:@"png"];
                
            }
        }
        
        if (storeAnnotation.store.isSubEmpInfo) {
            if ([storeAnnotation.store.colorStr isEqualToString:@"red"]) {
                annotationImage = [UIImage scaledImageForName:@"map_red" ofType:@"png"];
            }else if ([storeAnnotation.store.colorStr isEqualToString:@"green"]) {
                annotationImage = [UIImage scaledImageForName:@"map_green" ofType:@"png"];
            }
        }
        
        if (storeAnnotation.store.isShowMapCallout) {
            if (storeAnnotation.store.isAcctuallyAndInPlanStore) {
                annotationImage = [UIImage scaledImageForName:@"map_purple" ofType:@"png"];
            }else if (storeAnnotation.store.plan){
                annotationImage = [UIImage scaledImageForName:@"map_green" ofType:@"png"];
            }else if (storeAnnotation.store.isAcctuallyRouteStore){
                annotationImage = [UIImage scaledImageForName:@"map_red" ofType:@"png"];
            }else{
                annotationImage = [UIImage scaledImageForName:@"map_blue" ofType:@"png"];
            }
        }
        
        //施耐德新增，根据是否上传信息，更新位置颜色
        if ([storeAnnotation.store.detail_info isEqualToString:@"1"]){
            //1为红色，
            annotationImage = [UIImage scaledImageForName:@"map_red" ofType:@"png"];
            
        }else if ([storeAnnotation.store.detail_info isEqualToString:@"storeLocation"]){
            annotationImage = [UIImage imageForName:@"map_start"];
        }else if(storeAnnotation.store.detail_info.length > 0){
            //存在，切不等于1，则为蓝色
            annotationImage = [UIImage scaledImageForName:@"map_blue" ofType:@"png"];
            
        }
    }
    if (storeAnnotation.store.row_number.length > 0) {
        [self.storeStypButton setBackgroundImage:annotationImage forState:UIControlStateNormal];
    }else{
        [self setImage:annotationImage];
    }
    
    if (self.storeAnnotation.store.plan || self.storeAnnotation.store.bPlanned) {
        self.storeStypButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
        self.storeStypButton.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 5, 0);
        [self.storeStypButton setTitle:self.storeAnnotation.store.visitPlanMapOrder forState:UIControlStateNormal];
    }
    // MN-286 如果有回显的图片及文字，就用回显的值显示。
    [self dealWithMapPicDisOrDotDisplay];
    
    [self layoutSubviews];


}

-(void)dealWithMapPicDisOrDotDisplay{
    if (self.storeAnnotation.store.mapPicDis) {
        NSURL * url = [NSURL URLWithString:[WSHttpURLHelper getImageCompleteURL:self.storeAnnotation.store.mapPicDis]];
        [self.iconImageView sd_setImageWithURL:url];
        
    }
    
    if (self.storeAnnotation.store.dotDisplay) {
        [self.storeStypButton setTitle:self.storeAnnotation.store.dotDisplay forState:UIControlStateNormal];
        self.storeStypButton.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
        self.storeStypButton.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 5, 0);
    }
}

-(void)setAnnotatinViewImage:(UIImage *)image{
    if (self.storeAnnotation.store.row_number.length > 0 ) {
        [_storeStypButton setBackgroundImage:image forState:UIControlStateNormal];
        self.isClickView = YES;
    }else{
        [self setImage:image];
    }
//    [self layoutSubviews];

}

@end
