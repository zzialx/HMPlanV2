//
//  SelectListControl.m
//  SelectList
//
//  Created by Jiepeng Zheng on 12-8-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SelectListControl.h"
#import "QuartzCore/QuartzCore.h"

#define defaultString           NSLocalizedString(@"please_select", nil)

@implementation SelectListControl

//@synthesize title = _title;
@synthesize titleTable = _titleTable;
@synthesize content = _content;
@synthesize sourceTable = _sourceTable;
@synthesize selectedIndex = _selectedIndex;
@synthesize backView = _backView;
@synthesize title = _title;

@synthesize selectListDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame style:UITableViewStylePlain];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    frame.size.height = 32;
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self)
    {
        self.backgroundView = nil;
        self.delegate = self;
        self.dataSource = self;
        self.sectionHeaderHeight = 0;
        self.backgroundColor = [UIColor clearColor];
        self.scrollEnabled = NO;
    }
    return self;
}

- (void)touch
{
    [_backView removeFromSuperview];
    [_sourceTable removeFromSuperview];
    self.hidden = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self)
        return 1;
    return [_content count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"tb";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    if (tableView == self)
    {
        UIButton *accessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryView.frame = CGRectMake(0, 0, 14, 10);
        accessoryView.userInteractionEnabled = NO;
        [accessoryView setImage:[UIImage imageNamed:@"chevron.png"] forState:UIControlStateNormal];
        [accessoryView setImage:[UIImage imageNamed:@"chevron-active.png"] forState:UIControlStateHighlighted];
        cell.accessoryView = accessoryView;
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@:", self.title];
        cell.detailTextLabel.text = [_content objectAtIndex:_selectedIndex];
        UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        cell.textLabel.font = font;
        cell.detailTextLabel.font = font;
        
        return cell;
    }
    
    cell.accessoryView = nil;
    if ([indexPath row] == 0)
    {
        cell.textLabel.text = defaultString;//self.titleLabel.text;
        cell.detailTextLabel.text = self.title;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIButton *accessoryView = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryView.frame = CGRectMake(0, 0, 14, 10);
        accessoryView.userInteractionEnabled = NO;
        UIImage *image = [UIImage imageNamed:@"chevron.png"];
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        [accessoryView setImage:image forState:UIControlStateNormal];
        [accessoryView setTransform:transform];
        
        cell.accessoryView = accessoryView;
    }
    else
    {
        cell.textLabel.text = [_content objectAtIndex:[indexPath row] - 1];
        cell.detailTextLabel.text = @"";
        if ([indexPath row] - 1 != _selectedIndex)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    cell.textLabel.font = font;
    cell.detailTextLabel.font = font;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self)
    {
        tableView.hidden = YES;
//        UIWindow *wc = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        
        
//        UIView *rootView = wc.rootViewController.view;
        
        
        
        if (_sourceTable == nil)
        {
            _sourceTable = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 200) style:UITableViewStylePlain];
            _sourceTable.backgroundView = nil;
            _sourceTable.delegate = self;
            _sourceTable.dataSource = self;
            _sourceTable.sectionHeaderHeight = 0;
            _sourceTable.sectionFooterHeight = 0;
            _sourceTable.backgroundColor = [UIColor clearColor];
            
            [_sourceTable reloadData];
            
            CGRect rect = _sourceTable.frame;
            
            CGPoint point = rect.origin;
            
            point = [[self superview] convertPoint:point toView:self.viewController.view];
            rect.origin = point;
//            rect.origin.y =rect.origin.x -64 ;
//            rect.origin.x = 0;
            _sourceTable.frame = rect;

        }
        [_sourceTable reloadData];
        
        CGRect rect = _sourceTable.frame;
        if (rect.origin.y + _sourceTable.contentSize.height > self.viewController.view.frame.size.height)
        {
            rect.size.height = self.viewController.view.frame.size.height - rect.origin.y;
        }
        else
        {
            rect.size.height = _sourceTable.contentSize.height;
            //                _sourceTable.scrollEnabled = NO;
        }
        _sourceTable.frame = rect;

        if (_backView == nil)
        {
            _backView = [[UIView alloc] initWithFrame:rect];
            _backView.backgroundColor =[UIColor whiteColor];
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
            [tapRecognizer setNumberOfTapsRequired:1];
            [tapRecognizer setNumberOfTouchesRequired:1];
            [_backView addGestureRecognizer:tapRecognizer];

        }
        [self.viewController.view addSubview:_backView];
        [self.viewController.view addSubview:_sourceTable];
        [self.viewController.view bringSubviewToFront:_sourceTable];
        
        _sourceTable.hidden = NO;
        _sourceTable.contentOffset = CGPointMake(0, 0);
        _backView.hidden = NO;
    }
    else 
    {
        _backView.hidden = YES;
        self.hidden = NO;
        _sourceTable.hidden = YES;
        if ([indexPath row] == 0)
        {
            return;
        }
        if (_selectedIndex != [indexPath row] - 1)
        {
            _selectedIndex = [indexPath row] - 1;
            
            [self reloadData];
            [_sourceTable reloadData];
            if (self.selectListDelegate && [self.selectListDelegate respondsToSelector:@selector(selectListChange:)])
            {
                [self.selectListDelegate performSelector:@selector(selectListChange:) withObject:self];
            }
        }
    }
}

@end
