//
//  WSStoreAnnotationWithNameView.m
//  WinSFA
//
//  Created by HZH on 2017/9/28.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSStoreAnnotationWithNameView.h"

static CGFloat normalStoreStypButtonWidth = 110.0;
static CGFloat normalStoreStypButtonHeight = 110.0;

static CGFloat nameLabelHeight = 38.0;


@interface WSStoreAnnotationWithNameView ()
{
    CGPoint _oldCenterPoint;
}
@property (nonatomic,strong) UIImageView *foldlineImageView;
@property (nonatomic,strong) UILabel *storeNameLabel;

@end


@implementation WSStoreAnnotationWithNameView


- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {

        self.storeAnnotation = (WSStoreAnnotation *)annotation;

        _foldlineImageView = [[UIImageView alloc] init];
        _storeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 0.0, 60.0, nameLabelHeight)];
        _storeNameLabel.textAlignment = NSTextAlignmentCenter;
        _storeNameLabel.numberOfLines = 2;
        _storeNameLabel.font = FONT_SIZE_PINGFANG_MEDIUM(13.0);
        _storeNameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        
        [self addSubview:_foldlineImageView];
        [self addSubview:_storeNameLabel];
        
        
    }
    return self;
}

-(void)layoutSubviews{
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat selfWidth = 0;
    if (self.storeAnnotation.store.name.length > 0) {

        _foldlineImageView.frame = CGRectMake(0, 0, normalStoreStypButtonWidth, normalStoreStypButtonHeight);
        originX = normalStoreStypButtonWidth - nameLabelHeight;
        originY = normalStoreStypButtonHeight;
        selfWidth = normalStoreStypButtonWidth;
            
        _storeNameLabel.frame = CGRectMake(55.0, 0.0, 55.0, nameLabelHeight);
        
        CGRect rect = self.frame;
        [self setFrame:CGRectMake(rect.origin.x, rect.origin.y,selfWidth, originY)];
    }else{
        _foldlineImageView.frame = CGRectZero;
        _storeNameLabel.frame = CGRectZero;
    }
    
    // 获取相对坐标中心点
    _oldCenterPoint = CGPointMake(self.width/2.0, self.height/2.0);
    
    // 重设坐标，左下角设为之前的中心点
//    [self resetFrame];
}

- (void)resetFrame
{
    CGRect foldlineImageViewFrame = _foldlineImageView.frame;
    foldlineImageViewFrame.origin.x = foldlineImageViewFrame.origin.x + _oldCenterPoint.x;
    foldlineImageViewFrame.origin.y = foldlineImageViewFrame.origin.y - _oldCenterPoint.y;
    
    CGRect storeNameLabelFrame = _storeNameLabel.frame;
    storeNameLabelFrame.origin.x = storeNameLabelFrame.origin.x + _oldCenterPoint.x;
    storeNameLabelFrame.origin.y = storeNameLabelFrame.origin.y - _oldCenterPoint.y;
    
    _foldlineImageView.frame = foldlineImageViewFrame;
    _storeNameLabel.frame = storeNameLabelFrame;
}

-(void)setStoreAnnotation:(WSStoreAnnotation *)storeAnnotation{
    _storeAnnotation = storeAnnotation;
//    [_storeNameLabel setText:storeAnnotation.store.name];
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentCenter;
    paraStyle.lineSpacing = 0.0; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0.0;
    paraStyle.tailIndent = 0.0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:FONT_SIZE_PINGFANG_MEDIUM(13.0), NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.5f
                          };

    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:storeAnnotation.store.name attributes:dic];
    
    _storeNameLabel.attributedText = attributeStr;
//    [_storeNameLabel sizeToFit];
    
    [_foldlineImageView setImage:[UIImage imageNamed:@"brokenLine_point_icon"]];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
