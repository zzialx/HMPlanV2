//
//  WSPrograssView.m
//  WinSFA
//
//  Created by mac on 2018/8/30.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSPrograssView.h"

//ProgressViewColor
#define PROGRSSVIEW_POINT_COLOR             ([UIColor colorForKey:@"WSProgressViewPointColor"] ? :[UIColor colorWithRed:223.0f/255 green:223.0f/255 blue:223.0f/255 alpha:1.0f])
#define PROGRSSVIEW_LINE_COLOR              ([UIColor colorForKey:@"WSProgressViewLineColor"] ? : [UIColor colorWithRed:83.0f/255 green:152.0f/255 blue:238.0f/255 alpha:1.0f])
#define PROGRSSVIEW_BackGround_COLOR        ([UIColor colorForKey:@"WSProgressViewBackgroundColor"]? : [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:245.0f/255 alpha:1.0f])

#define LineWidth 5
@interface WSPrograssView()
{
    CGFloat _startAngle; // 开始的角度
    NSInteger _startRate;
}
//   半径r
@property(nonatomic,assign) CGFloat rWidth;
//    显示圆的边缘图层
@property(nonatomic,strong) CAShapeLayer *shapeLayer;
//    定时器
@property(nonatomic,strong) CADisplayLink *displayLink;
//     显示圆的路径
@property(nonatomic,strong) UIBezierPath *bPath;
//      显示rate
@property (nonatomic, strong) UILabel *rateLbl;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSString *imageName;
@end
@implementation WSPrograssView


+ (instancetype)sharedProgressViewManagerInitwithframe:(CGRect)frame imageName:(NSString *)imageName progressRate:(NSInteger)rate isNeedshowRate :(BOOL) isNeedShow{
    return [[self alloc] initWithFrame:frame ImageViewName:imageName progressRate:rate isNeedshowRate: isNeedShow];
}

-(instancetype)initWithFrame:(CGRect)frame ImageViewName :(NSString *)imageName progressRate :(NSInteger) rate isNeedshowRate :(BOOL) isNeedShow
{
    self =  [super initWithFrame:frame];
    if (self) {
        _startAngle = -90; // 从圆的最顶部开始
        _rWidth = frame.size.width * 0.5;
        _bPath = [UIBezierPath bezierPath];
        if (imageName.length > 0) {
            self.imageName = imageName;
            [self confingImage];
        }
        
        self.rate = rate;
        [self configBgCircle];
        [self configShapeLayer];
        [self configDisplayLink];
        [self addPointView];
        
        if (isNeedShow) {
            [self configLab];
        }
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        self.layer.cornerRadius = self.frame.size.width * 0.5;
        self.layer.masksToBounds = YES;
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (void) confingImage{
    self.imageView.image = [UIImage imageNamed:self.imageName];
    [self addSubview:self.imageView];
}

- (void)configBgCircle
{
    UIBezierPath *bPath = [UIBezierPath bezierPathWithArcCenter:(CGPoint){self.bounds.size.width *0.5,self.bounds.size.height *0.5} radius:_rWidth startAngle:0 endAngle:360 clockwise:YES];
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.lineWidth = LineWidth;
    shaperLayer.strokeColor = PROGRSSVIEW_BackGround_COLOR.CGColor;
    shaperLayer.fillColor = nil;
    shaperLayer.path = bPath.CGPath;
    [self.layer addSublayer:shaperLayer];
}

- (void)configShapeLayer
{
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.lineWidth = LineWidth;
    _shapeLayer.strokeColor = PROGRSSVIEW_LINE_COLOR.CGColor;
    _shapeLayer.fillColor = nil;
    _shapeLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_shapeLayer];
}

- (void)configDisplayLink
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawCircle)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)configLab
{
    CGFloat rateLabX = 10;
    CGFloat rateLabW = self.frame.size.width - 2 * rateLabX;
    CGFloat rateLabH = 40;
    CGFloat rateLabY = (self.frame.size.height - rateLabH) * 0.5;
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(rateLabX, rateLabY, rateLabW, rateLabH)];
    _rateLbl = lab;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = [UIColor blackColor];
    lab.text = @"0%";
    [self addSubview:lab];
}

- (void)drawCircle
{
    if (_startRate >= _rate) {
        _bPath = [UIBezierPath bezierPath];
        return;
    }
    _startRate ++;
//    _rateLbl.text = [NSString stringWithFormat:@"%ld%%",_startRate];
    [_bPath addArcWithCenter:CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5) radius:_rWidth  startAngle:(M_PI /180.0) *_startAngle endAngle:(M_PI /180.0) *(_startAngle + 3.6) clockwise:YES];
    _shapeLayer.path = _bPath.CGPath;
    _startAngle += 3.6;
    
   
}

- (void)startAnimation
{
    [CATransaction begin];
    
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [CATransaction setAnimationDuration:15];
    [CATransaction commit];
}

- (void) setRate:(float)rate{
    if (rate >100) {
        _rate = 100;
    }else if (rate < 0){
        _rate = 0;
    }
    else{
        _rate = rate;
    }
}
-(void)addPointView
{
    
    for (int i=0; i<10; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LineWidth, LineWidth)];
        view.layer.cornerRadius = LineWidth * 0.5;
        view.backgroundColor = PROGRSSVIEW_POINT_COLOR;
        view.frame = [self getEndPointFrameWithProgress:0.1*i];
        [self addSubview:view];
    }
}

#pragma mark 计算圆圈上点在IOS系统中的坐标
-(CGRect)getEndPointFrameWithProgress:(float)progress
{
    CGFloat angle = M_PI*2.0*progress;//将进度转换成弧度
    CGFloat radius = self.bounds.size.width * 0.5;//半径
    int index = (angle)/M_PI_2;//用户区分在第几象限内
    float needAngle = angle - index*M_PI_2;//用于计算正弦/余弦的角度
    CGFloat x = 0,y = 0;//用于保存view的frame
    switch (index) {
        case 0:
            //            NSLog(@"第一象限");
            x = radius + sinf(needAngle)*radius;
            y = radius - cosf(needAngle)*radius;
            break;
        case 1:
            //            NSLog(@"第二象限");
            x = radius + cosf(needAngle)*radius;
            y = radius + sinf(needAngle)*radius;
            break;
        case 2:
            //            NSLog(@"第三象限");
            x = radius - sinf(needAngle)*radius;
            y = radius + cosf(needAngle)*radius;
            break;
        case 3:
            //            NSLog(@"第四象限");
            x = radius - cosf(needAngle)*radius;
            y = radius - sinf(needAngle)*radius;
            break;
            
        default:
            break;
    }
    
    //更新圆环的frame
    CGRect rect = CGRectMake(0, 0, LineWidth, LineWidth);
    //让圆圈的中心和圆环的中心重合
    rect.origin.x = x-LineWidth*0.5;
    rect.origin.y = y-LineWidth*0.5;
    return  rect;
    
}
@end
