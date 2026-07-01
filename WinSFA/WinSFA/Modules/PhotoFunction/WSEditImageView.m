//
//  WSEditImageView.m
//  WinSFA
//
//  Created by zhangke on 1GAP/1/14.
//  Copyright (c) 201GAP年 WinChannel. All rights reserved.
//

#import "WSEditImageView.h"
#define GAP 10


typedef enum
{
    LeftTop = 0,
    RightTop=1,
    LeftBottom = 2,
    RightBottom = 3,
    MoveCenter = 4,
    None = 5,
    
}
rectPoint;

@interface WSEditImageView (){
    rectPoint _movePoint;
    CGPoint _lastMovePoint;
    UIView* _cropView;
}


@end




@implementation WSEditImageView


-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if(self){
        
        self.viewArray=[NSMutableArray array];
        
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Begins");
    
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > self.bounds.size.width || locationPoint.y > self.bounds.size.height)
    {
        return;
    }
    _lastMovePoint = locationPoint;
    
    _cropView=nil;
    
    for(NSInteger i=self.viewArray.count-1;i>-1;i--){
        UIView* view =[self.viewArray objectAtIndex:i];
        _movePoint=None;
        
        if( view.left - GAP  < locationPoint.x  && locationPoint.x  <  view.left + GAP )
        {
            if(view.top - GAP < locationPoint.y && locationPoint.y  < view.top + GAP  )
                _movePoint = LeftTop;
            else if (view.bottom - GAP < locationPoint.y  &&  locationPoint.y  < view.bottom + GAP)
                _movePoint = LeftBottom;
        }
        else if( view.right- GAP < locationPoint.x && locationPoint.x <view.right + GAP)
        {
            if(  view.top - GAP <locationPoint.y && locationPoint.y  <  view.top + GAP )
                _movePoint = RightTop;
            else if (view.bottom - GAP < locationPoint.y  && locationPoint.y  < view.bottom + GAP)
                _movePoint = RightBottom;
        }
        else if ( view.left + GAP < locationPoint.x  && locationPoint.x < view.right-GAP  && view.top+GAP <locationPoint.y && locationPoint.y<view.bottom-GAP)
        {
            _movePoint = MoveCenter;
        }
        
        if(_movePoint!=None){
            _cropView=view;
            break;
        }
        
    }
    
    
    if(_cropView==nil){
        _cropView = [[UIView alloc] initWithFrame:CGRectMake(locationPoint.x, locationPoint.y, 0, 0)];
        _cropView.layer.borderColor=[[UIColor redColor] CGColor];
        _cropView.layer.borderWidth=2;
        [self addSubview:_cropView];
        [self.viewArray addObject:_cropView];
        _movePoint=RightBottom;
    }
    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    
    if(locationPoint.x < 0 || locationPoint.y < 0 || locationPoint.x > self.bounds.size.width || locationPoint.y > self.bounds.size.height)
    {
        return;
    }
    
    switch (_movePoint) {
        case LeftTop:
            _cropView.frame = CGRectMake(locationPoint.x, locationPoint.y,
                                         _cropView.width + (_cropView.left - locationPoint.x),
                                         _cropView.height + (_cropView.top - locationPoint.y));
            break;
        case LeftBottom:
            
            _cropView.frame = CGRectMake(locationPoint.x, _cropView.top,
                                         _cropView.width + (_cropView.left - locationPoint.x),
                                         locationPoint.y - _cropView.top);
            break;
        case RightTop:
            
            _cropView.frame= CGRectMake(_cropView.left, locationPoint.y,
                                        locationPoint.x - _cropView.left,
                                        _cropView.height + (_cropView.top - locationPoint.y));
            break;
        case RightBottom:
            
            _cropView.frame= CGRectMake(_cropView.left, _cropView.top,
                                        locationPoint.x - _cropView.left,
                                        locationPoint.y - _cropView.top);
            break;
        case MoveCenter:
            _cropView.center=CGPointMake(_cropView.center.x+(locationPoint.x  - _lastMovePoint.x) , _cropView.center.y+(locationPoint.y  - _lastMovePoint.y));
            
            _lastMovePoint = locationPoint;
            break;
        default:
            break;
    }
}





@end
