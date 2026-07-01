//
//  WCMultipleChoiceLabel.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 4/8/13.
//
//

#import "WSMultipleChoiceLabel.h"

@implementation WSMultipleChoiceLabel

@synthesize iContent = _iContent;
@synthesize iInfos = _iInfos;
@synthesize iNotificationPrefix = _iNotificationPrefix;
@synthesize iRow = _iRow;
@synthesize iColumn = _iColumn;
@synthesize iDataType = _iDataType;
@synthesize iDicNotificationName = _iDicNotificationName;
@synthesize iLogicType = _iLogicType;
@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableDictionary *)iInfos
{
    if (_iInfos == nil) {
        _iInfos = [[NSMutableDictionary alloc] initWithCapacity:8];
    }
    return _iInfos;
}


- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
//    NSLog(@"%d--%s---%p", __LINE__, __FUNCTION__,self);
    
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
    //    self.iRow = aRow;
    //    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        //        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
//    NSLog(@"%s---%d", __FUNCTION__, __LINE__);
}

- (void)updateState:(NSNotification *)sender
{
//    NSLog(@"%d--%s--%p", __LINE__, __FUNCTION__,self);
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        BOOL isEnable = [number boolValue];
        if (!isEnable) {
            self.text = @"0";
            self.iContent = nil;
        }
        self.userInteractionEnabled = isEnable;
    }
}

- (BOOL)isValueChange {
    return _isValueChange;
}

- (BOOL)entityIsEnable
{
    return self.isUserInteractionEnabled;
}

- (NSString *)getTextValue
{
    return self.iContent;
}

- (BOOL)isValueLegal
{
    return (self.iContent != nil && [self.iContent length] > 0) ? YES : NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
