//
//  Created by tuo on 4/1/12.
//
// to change "templates" to "placeholder"
//

#import "WSCoverFlowView.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "WSTagImage.h"
#import "WSTagLayer.h"
#define DISTNACE_TO_MAKE_MOVE_FOR_SWIPE 60
#define CACHE_DIR [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface WSCoverFlowView ()

////setup templates
//-(void)setupTemplateLayers;
////setup images
//-(void)setupImages;
////remove sublayers (after a certain delay)
//-(void)removeLayersAfterSeconds:(id)layerToBeRemoved;
////remove all sublayers
//-(void)removeSublayers;
////empty imagelayers
//-(void)cleanImageLayers;
////add reflections
//-(void)showImageAndReflection:(WSTagLayer *)layer;
////adjust the bounds
//-(void)scaleBounds: (CALayer *) layer x:(CGFloat)scaleWidth y:(CGFloat)scaleHeight;
////add uipagecontrol
//-(void)addPageControl;

@property(nonatomic,strong) NSArray *richModelArray;
@end


@implementation WSCoverFlowView {
@private

    NSMutableArray *_images;
    NSMutableArray *_imageLayers;
    NSMutableArray *_templateLayers;
    NSInteger _currentRenderingImageIndex;
    UIPageControl *_pageControl;
    int _sideVisibleImageCount;
    CGFloat _sideVisibleImageScale;
    CGFloat _middleImageScale;
}


@synthesize images = _images;
@synthesize imageLayers = _imageLayers;
@synthesize templateLayers = _templateLayers;
@synthesize currentRenderingImageIndex = _currentRenderingImageIndex;
@synthesize pageControl = _pageControl;
@synthesize sideVisibleImageCount = _sideVisibleImageCount;
@synthesize sideVisibleImageScale = _sideVisibleImageScale;
@synthesize middleImageScale = _middleImageScale;


- (void)adjustReflectionBounds:(CALayer *)layer scale:(CGFloat)scale {
// set originLayer's reflection bounds
    CALayer *reflectLayer = (CALayer*)[layer.sublayers firstObject];
    [self scaleBounds:reflectLayer x:scale y:scale];
    // set originLayer's reflection bounds
    [self scaleBounds:reflectLayer.mask x:scale y:scale];
    // set originLayer's reflection bounds
    [self scaleBounds:(CALayer*)[reflectLayer.sublayers firstObject] x:scale y:scale];
    // set originLayer's reflection position
    reflectLayer.position = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height*1.5);
    // set originLayer's mask position
    reflectLayer.mask.position = CGPointMake(reflectLayer.bounds.size.width/2, reflectLayer.bounds.size.height/2);
    // set originLayer's reflection position
    ((CALayer*)[reflectLayer.sublayers firstObject]).position = CGPointMake(reflectLayer.bounds.size.width/2, reflectLayer.bounds.size.height/2);
}

- (void)removeLayerFromSuper:(CALayer *)layerToBeRemoved {
    [layerToBeRemoved removeFromSuperlayer];
}

- (void)moveOneStep:(BOOL)isSwipingToLeftDirection {
    //when move the first/last image,disable moving
    if ((self.currentRenderingImageIndex == 0 && !isSwipingToLeftDirection) || (self.currentRenderingImageIndex == self.images.count -1 && isSwipingToLeftDirection))
        return;

    NSInteger offset = isSwipingToLeftDirection ?  -1 : 1;
    NSInteger indexOffsetFromImageLayersToTemplates = (self.currentRenderingImageIndex - self.sideVisibleImageCount < 0) ? (self.sideVisibleImageCount + 1 + offset - self.currentRenderingImageIndex) : 1 + offset;
    for (int i = 0; i < self.imageLayers.count; i++) {
        WSTagLayer *originLayer = [self.imageLayers objectAtIndex:i];
        CALayer *targetTemplate = [self.templateLayers objectAtIndex: i + indexOffsetFromImageLayersToTemplates];

        [CATransaction setAnimationDuration:1];
        originLayer.position = targetTemplate.position;
        originLayer.zPosition = targetTemplate.zPosition;
        originLayer.transform = targetTemplate.transform;
        //set originlayer's bounds

        CGFloat scale = 1.0f;
        if (i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount) {
            scale = self.middleImageScale  / self.sideVisibleImageScale;
        } else if (((i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount - 1) && isSwipingToLeftDirection) ||
                ((i + indexOffsetFromImageLayersToTemplates - 1 == self.sideVisibleImageCount + 1) && !isSwipingToLeftDirection)) {
            scale = self.sideVisibleImageScale / self.middleImageScale;
        }

        originLayer.bounds = CGRectMake(0, 0, originLayer.bounds.size.width * scale, originLayer.bounds.size.height * scale);
        [self adjustReflectionBounds:originLayer scale:scale];

    }

    if (isSwipingToLeftDirection){
        //when current rendering index  >= sidecout
        if(self.currentRenderingImageIndex >= self.sideVisibleImageCount){
            CALayer *removeLayer = [self.imageLayers firstObject];
            if (removeLayer) {
                [self.imageLayers removeObject:removeLayer];
                CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
                [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
                [fadeOut setDuration:0.5f];
                [removeLayer addAnimation:fadeOut forKey:@"fadeout"];
                [self performSelector:@selector(removeLayerFromSuper:) withObject:removeLayer afterDelay:0.5f];

            }
        }
        NSInteger num = self.images.count - self.sideVisibleImageCount - 1;
        if (self.currentRenderingImageIndex < num){
            WSTagImage *candidateImage = [self.images objectAtIndex:self.currentRenderingImageIndex  + self.sideVisibleImageCount + 1];
            WSTagLayer *candidateLayer = [WSTagLayer layer];
            candidateLayer.richModel = candidateImage.richModel;
            candidateLayer.contents = (__bridge id)candidateImage.CGImage;
            CGFloat scale = self.sideVisibleImageScale;
            candidateLayer.bounds = CGRectMake(0, 0, candidateImage.size.width * scale, candidateImage.size.height * scale);
 
            [self.imageLayers addObject:candidateLayer];

            CALayer *template = [self.templateLayers objectAtIndex:self.templateLayers.count - 2];
            candidateLayer.position = template.position;
            candidateLayer.zPosition = template.zPosition;
            candidateLayer.transform = template.transform;

            //show the layer
            [self showImageAndReflection:candidateLayer];
        }

    }else{//if the right, then move the rightest layer and insert one to left (if left is full)

        //when to remove rightest, only when image in the rightest is indeed sitting in the template  imagelayer's rightes
        if (self.currentRenderingImageIndex + self.sideVisibleImageCount <= self.images.count -1) {
            WSTagLayer *removeLayer = [self.imageLayers lastObject];
            if (removeLayer) {
                [self.imageLayers removeObject:removeLayer];
                CABasicAnimation *fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
                [fadeOut setToValue:[NSNumber numberWithFloat:0.0]];
                [fadeOut setDuration:0.5f];
                [removeLayer addAnimation:fadeOut forKey:@"fadeout"];
                [self performSelector:@selector(removeLayerFromSuper:) withObject:removeLayer afterDelay:0.5f];
            }

        }

        //check out whether we need to add layer to left, only when (currentIndex - sideCount > 0)
        if (self.currentRenderingImageIndex > self.sideVisibleImageCount){
            WSTagImage *candidateImage = [self.images objectAtIndex:self.currentRenderingImageIndex - 1 - self.sideVisibleImageCount];
            WSTagLayer *candidateLayer = [WSTagLayer layer];
            candidateLayer.richModel = candidateImage.richModel;
            candidateLayer.contents = (__bridge id)candidateImage.CGImage;
            CGFloat scale = self.sideVisibleImageScale;
            candidateLayer.bounds = CGRectMake(0, 0, candidateImage.size.width * scale, candidateImage.size.height * scale);
            
            if (candidateLayer && candidateLayer != nil && candidateImage && candidateImage != nil) {
                [self.imageLayers insertObject:candidateLayer atIndex:0];
            }

            CALayer *template = [self.templateLayers objectAtIndex:1];
            candidateLayer.position = template.position;
            candidateLayer.zPosition = template.zPosition;
            candidateLayer.transform = template.transform;

            //show the layer
            [self showImageAndReflection:candidateLayer];
        }

    }
    //update index if you move to right, index--
    self.currentRenderingImageIndex = isSwipingToLeftDirection ? self.currentRenderingImageIndex + 1 : self.currentRenderingImageIndex - 1;

}

- (void)scaleBounds:(CALayer*)layer x:(CGFloat)scaleWidth y:(CGFloat)scaleHeight
{
    layer.bounds = CGRectMake(0, 0, layer.bounds.size.width*scaleWidth, layer.bounds.size.height*scaleHeight);
}

- (void)handleGesture:(UIGestureRecognizer *)recognizer {
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        
        if (recognizer.state == UIGestureRecognizerStateChanged)
        {
            //get offset
            CGPoint offset = [(UIPanGestureRecognizer *)recognizer translationInView:recognizer.view];
            if (offset.x > DISTNACE_TO_MAKE_MOVE_FOR_SWIPE) {
                BOOL isSwipingToLeftDirection = (offset.x > 0) ? NO :YES;
                [self moveOneStep:isSwipingToLeftDirection];
                [(UIPanGestureRecognizer *)recognizer setTranslation:CGPointZero inView:recognizer.view];
            }
        }
    }else if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]){
    
        CGPoint touchPoint = [recognizer locationInView:self];
        NSMutableArray * touchLayers = [NSMutableArray arrayWithCapacity:2];
        //遍历当前视图上的子视图的presentationLayer 与点击的点是否有交集
        for (CALayer *subLayer in self.imageLayers) {
            if ([subLayer.presentationLayer hitTest:touchPoint] && [subLayer isKindOfClass:[WSTagLayer class]]) {
                
                [touchLayers addObject:subLayer];
                
                NSLog(@"点击的是：%@",subLayer);
            }
        }
        
        if (touchLayers.count == 2)
        {
            WSTagLayer * Layer1 = touchLayers[0];
            WSTagLayer * Layer2 = touchLayers[1];
           
            NSInteger num1 = [self.imageLayers indexOfObject:Layer1];
            NSInteger num2 = [self.imageLayers indexOfObject:Layer2];
            if (num1 > num2) {
                if (Layer1.frame.origin.x > self.bounds.size.width / 2 ) {
                    if ([self.delegate respondsToSelector:@selector(popImageViewH5With:)]) {
                        [self.delegate popImageViewH5With:Layer2.richModel];
                    }
                }else{
                    if ([self.delegate respondsToSelector:@selector(popImageViewH5With:)]) {
                        [self.delegate popImageViewH5With:Layer1.richModel];
                    }
                
                }
            }else
            {
            
                if (Layer1.frame.origin.x > self.bounds.size.width / 2 ) {
                    if ([self.delegate respondsToSelector:@selector(popImageViewH5With:)]) {
                        [self.delegate popImageViewH5With:Layer1.richModel];
                    }
                }else{
                    if ([self.delegate respondsToSelector:@selector(popImageViewH5With:)]) {
                        [self.delegate popImageViewH5With:Layer2.richModel];
                    }
                    
                }

            }

            
            
        }else if(touchLayers.count == 1){
            
            WSTagLayer * Layer = touchLayers[0];

            if ([self.delegate respondsToSelector:@selector(popImageViewH5With:)]) {
                [self.delegate popImageViewH5With:Layer.richModel];
            }
        }
    
    }
    

}

+ (id)coverFlowViewWithFrame:(CGRect)frame andImages:(NSMutableArray *)rawImages sideImageCount:(int)sideCount sideImageScale:(CGFloat)sideImageScale middleImageScale:(CGFloat)middleImageScale {
    WSCoverFlowView *flowView = [[WSCoverFlowView alloc] initWithFrame:frame];

    flowView.sideVisibleImageCount = sideCount;
    flowView.sideVisibleImageScale = sideImageScale;
    flowView.middleImageScale = middleImageScale;

    //default set middle image to the first image in the source images array
    flowView.currentRenderingImageIndex = rawImages.count/2;

    flowView.richModelArray = rawImages;
    flowView.images = [[NSMutableArray alloc]initWithCapacity:rawImages.count];
    
    for (WSRichItemModel *model in rawImages) {
        WSTagImage * image;
        if (model.img_add.length > 0 ) {
            NSString *imgStr = [NSString stringWithFormat:@"%@/richMedia/%@/3d-0.png",CACHE_DIR,model.img_add];
            image = [[WSTagImage alloc] initWithContentsOfFile:imgStr];
            if (image) {
                [flowView.images addObject:image];
            }
        }else{
            
            image =[[WSTagImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"3d-0@3x.png" ofType:nil]];
            if (image) {
                [flowView.images addObject:image];

            }
        }
        image.richModel = model;
    }
    
    
    
    flowView.imageLayers = [[NSMutableArray alloc] initWithCapacity:flowView.sideVisibleImageCount* 2 + 1];
    flowView.templateLayers = [[NSMutableArray alloc] initWithCapacity:(flowView.sideVisibleImageCount + 1)* 2 + 1];

    //register the pan gesture to figure out whether user has intention to move to next/previous image
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:flowView action:@selector(handleGesture:)];
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:flowView action:@selector(handleGesture:)];
    [flowView addGestureRecognizer:gestureRecognizer];
    [flowView addGestureRecognizer:tapGestureRecognizer];

    //now almost setup
    [flowView setupTemplateLayers];

    [flowView setupImages];

    [flowView addPageControl];

    return flowView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //set up perspective
        CATransform3D transformPerspective = CATransform3DIdentity;
                        transformPerspective.m34 = -1.0 / 500.0;
                        self.layer.sublayerTransform = transformPerspective;
    }

    return self;
}

-(void)setupTemplateLayers {
    CGFloat centerX = self.bounds.size.width/2;
    CGFloat centerY = self.bounds.size.height/2;

    //the angle to rotate
    CGFloat leftRadian = M_PI/3;
    CGFloat rightRadian = -M_PI/3;

    //gap between images in side
    CGFloat gapAmongSideImages = 80.0f;

    //gap between middle one and neigbour(this word is so hard to type wrong: WTF)
    CGFloat gapBetweenMiddleAndSide = 150.0f;

    //setup the layer templates
    //let's start from left side
    for(int i = 0; i <= self.sideVisibleImageCount; i++){
       CALayer *layer = [CALayer layer];
       layer.position = CGPointMake(centerX - gapBetweenMiddleAndSide - gapAmongSideImages * (self.sideVisibleImageCount - i), centerY);
       layer.zPosition = (i - self.sideVisibleImageCount - 1) * 10;
       layer.transform = CATransform3DMakeRotation(leftRadian, 0, 1, 0);
       [self.templateLayers addObject:layer];
    }

    //middle

    CALayer *layer = [CALayer layer];
    layer.position = CGPointMake(centerX, centerY);
    [self.templateLayers addObject:layer];
    //right
    for(int i = 0; i <= self.sideVisibleImageCount; i++){
        CALayer *layer = [CALayer layer];
        layer.position = CGPointMake(centerX + gapBetweenMiddleAndSide + gapAmongSideImages * i, centerY);
        layer.zPosition = (i + 1) * -10;
        layer.transform = CATransform3DMakeRotation(rightRadian, 0, 1, 0);
        [self.templateLayers addObject:layer];
    }
}

- (void)setupImages {
    // setup the visible area, and start index and end index
    NSInteger startingImageIndex = (self.currentRenderingImageIndex - self.sideVisibleImageCount <= 0) ? 0 : self.currentRenderingImageIndex - self.sideVisibleImageCount;
    NSInteger endImageIndex = (self.currentRenderingImageIndex + self.sideVisibleImageCount < self.images.count )  ? (self.currentRenderingImageIndex + self.sideVisibleImageCount) : (self.images.count -1 );

    //step2: set up images that ready for rendering
    for (NSInteger i = startingImageIndex; i <= endImageIndex; i++) {
       WSTagImage *image = [self.images objectAtIndex:i];
       WSTagLayer *imageLayer = [WSTagLayer layer];
        imageLayer.richModel = image.richModel;
       imageLayer.contents = (__bridge id)image.CGImage;
       CGFloat scale = (i == self.currentRenderingImageIndex) ? self.middleImageScale : self.sideVisibleImageScale;
       imageLayer.bounds = CGRectMake(0, 0, image.size.width * scale, image.size.height*scale);
       [self.imageLayers addObject:imageLayer];
    }

    //step3 : according to templates, set its geometry info to corresponding image layer
    //1 means the extra layer in templates layer
    //damn mathmatics
    NSInteger indexOffsetFromImageLayersToTemplates = (self.currentRenderingImageIndex - self.sideVisibleImageCount < 0) ? (self.sideVisibleImageCount + 1 - self.currentRenderingImageIndex) : 1;
    for (NSInteger i = 0; i < self.imageLayers.count; i++) {
        CALayer *correspondingTemplateLayer = [self.templateLayers objectAtIndex:(i + indexOffsetFromImageLayersToTemplates)];
        WSTagLayer *imageLayer = [self.imageLayers objectAtIndex:i];
        imageLayer.position = correspondingTemplateLayer.position;
        imageLayer.zPosition = correspondingTemplateLayer.zPosition;
        imageLayer.transform = correspondingTemplateLayer.transform;
        //show its reflections
        [self showImageAndReflection:imageLayer];
    }

}

// 添加layer及其“倒影”
- (void)showImageAndReflection:(WSTagLayer*)layer
{
    // 制作reflection
    CALayer *reflectLayer = [CALayer layer];
    reflectLayer.contents = layer.contents;
    reflectLayer.bounds = layer.bounds;
    reflectLayer.position = CGPointMake(layer.bounds.size.width/2, layer.bounds.size.height*1.5);
    reflectLayer.transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);

    // 给该reflection加个半透明的layer
    CALayer *blackLayer = [CALayer layer];
    blackLayer.backgroundColor = [UIColor blackColor].CGColor;
    blackLayer.bounds = reflectLayer.bounds;
    blackLayer.position = CGPointMake(blackLayer.bounds.size.width/2, blackLayer.bounds.size.height/2);
    blackLayer.opacity = 0.6;
    [reflectLayer addSublayer:blackLayer];

    // 给该reflection加个mask
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.bounds = reflectLayer.bounds;
    mask.position = CGPointMake(mask.bounds.size.width/2, mask.bounds.size.height/2);
    mask.colors = [NSArray arrayWithObjects:
                   (__bridge id)[UIColor clearColor].CGColor,
                   (__bridge id)[UIColor whiteColor].CGColor, nil];
    mask.startPoint = CGPointMake(0.5, 0.35);
    mask.endPoint = CGPointMake(0.5, 1.0);
    reflectLayer.mask = mask;

    // 作为layer的sublayer
    [layer addSublayer:reflectLayer];
    
//    CALayer * subLayer = [CALayer layer];
//    subLayer.contents = (__bridge id)[UIImage imageNamed:@"zx"].CGImage;
//    subLayer.frame = CGRectMake(0, 0, layer.frame.size.width * 0.3, layer.frame.size.height * 0.3);
//    [layer addSublayer:subLayer];
    // 加入UICoverFlowView的sublayers
    [self.layer addSublayer:layer];
}

- (void)addPageControl {


}


- (int)getIndexForMiddle {

    return 0;
}



@end
