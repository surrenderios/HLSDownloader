//
//  EditViewController.m
//  HLJ
//
//  Created by Alex_Wu on 19/04/2018.
//  Copyright © 2018 Starcor. All rights reserved.
//

#import "EditViewController.h"

#pragma mark - EditableViewController

@interface EditViewController ()
@property (nonatomic, assign) BOOL isEditingState;
@property (nonatomic, assign) BOOL shouldShowEditButton;
@end

@implementation EditViewController
@synthesize editview = _editview,datas = _datas;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.editview = [[EditView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.editview];
    [self.editview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.bottom.mas_equalTo(self.mas_bottomLayoutGuideTop);
        make.height.mas_equalTo(0);//未显示高度改为0
    }];
    self.editview.hidden = YES;
}


#pragma mark - protocol
/**
 点击编辑按钮
 
 @param sender sender
 */
- (void)startEdit:(UIButton *)sender;
{
    self.isEditingState = YES;
    
    //显示底部的UI
    [self.editview mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(45);
    }];
    self.editview.hidden = NO;
    [self.view bringSubviewToFront:self.editview];
}

/**
 取消编辑
 
 @param sender sender
 */
- (void)endEdit:(UIButton *)sender;
{
    self.isEditingState = NO;
    
    //隐藏底部的UI
    [self.editview mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    self.editview.hidden = YES;
}


/**
 点击全选
 
 @param sender sender
 */
- (void)selectedAll:(id)sender;
{
    
}

/**
 点击取消全选
 
 @param sender sender
 */
- (void)cancelSelectedAll:(id)sender;
{
    
}

/**
 点击删除
 
 @param sender sender
 */
- (void)deleteSelected:(id)sender;
{
    
}

/**
 更新按钮title显示
 
 @param count 选中的
 @param totalCount 总计的
 */
- (void)updateWithSelectedCount:(NSUInteger)count totalCount:(NSUInteger)totalCount;
{
    //初始化状态
    if (count == 0 && totalCount == 0)
    {
        [self.editview.allButton setTitle:Cache_Select_All_Str()
                                 forState:UIControlStateNormal];
        [self.editview.allButton setTitleColor:allNormalTitleColor()
                                      forState:UIControlStateNormal];
        [self.editview.allButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [self.editview.allButton addTarget:self
                                    action:@selector(selectedAll:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [self.editview.deleteButton setEnabled:NO];
        [self.editview.deleteButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [self.editview.deleteButton setTitle:Cache_Delete_Str()
                                    forState:UIControlStateNormal];
        [self.editview.deleteButton setTitleColor:deleteNormalTitleColor()
                                         forState:UIControlStateNormal];
        
        [self updateEditButton:NO];
    }
    //未选中任何状态
    else if (count == 0 && totalCount != 0)
    {
        [self.editview.allButton setTitle:Cache_Select_All_Str()
                                 forState:UIControlStateNormal];
        [self.editview.allButton setTitleColor:allNormalTitleColor()
                                      forState:UIControlStateNormal];
        [self.editview.allButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [self.editview.allButton addTarget:self
                                    action:@selector(selectedAll:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [self.editview.deleteButton setEnabled:NO];
        [self.editview.deleteButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [self.editview.deleteButton setTitle:Cache_Delete_Str()
                                    forState:UIControlStateNormal];
        [self.editview.deleteButton setTitleColor:deleteNormalTitleColor()
                                         forState:UIControlStateNormal];
        
        [self updateEditButton:YES];
    }
    //选中部分状态
    else if (totalCount != 0 && count != 0 && totalCount != count)
    {
        [self.editview.allButton setTitle:Cache_Select_All_Str()
                                 forState:UIControlStateNormal];
        [self.editview.allButton setTitleColor:allNormalTitleColor()
                                      forState:UIControlStateNormal];
        [self.editview.allButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [self.editview.allButton addTarget:self
                                    action:@selector(selectedAll:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [self.editview.deleteButton setEnabled:YES];
        [self.editview.deleteButton removeTarget:self action:NULL
                                forControlEvents:UIControlEventAllEvents];
        [self.editview.deleteButton addTarget:self action:@selector(deleteSelected:)
                             forControlEvents:UIControlEventTouchUpInside];
        [self.editview.deleteButton setTitle:Cache_Delete_Count_Str(count)
                                    forState:UIControlStateNormal];
        [self.editview.deleteButton setTitleColor:deleteSelectedTitleColor()
                                         forState:UIControlStateNormal];
    }
    //全选状态
    else if (totalCount != 0 && count != 0 && totalCount == count)
    {
        [self.editview.allButton setTitle:Cache_Cancel_Select_All_Str()
                                 forState:UIControlStateNormal];
        [self.editview.allButton setTitleColor:allNormalTitleColor()
                                      forState:UIControlStateNormal];
        [self.editview.allButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        [self.editview.allButton addTarget:self
                                    action:@selector(cancelSelectedAll:)
                          forControlEvents:UIControlEventTouchUpInside];
        
        [self.editview.deleteButton setEnabled:YES];
        [self.editview.deleteButton removeTarget:self action:NULL
                                forControlEvents:UIControlEventAllEvents];
        [self.editview.deleteButton addTarget:self action:@selector(deleteSelected:)
                             forControlEvents:UIControlEventTouchUpInside];
        [self.editview.deleteButton setTitle:Cache_Delete_Count_Str(count)
                                    forState:UIControlStateNormal];
        [self.editview.deleteButton setTitleColor:deleteSelectedTitleColor()
                                         forState:UIControlStateNormal];
    }
}

- (void)updateEditButton:(BOOL)shouldShowEditButton
{
    self.shouldShowEditButton = shouldShowEditButton;
    
    if (self.shouldShowEditButton) {
        if (self.isEditingState) {
            //开始编辑以后,按钮文字改变,事件改变
            [self setNavigationBarRightButtonsWithTitles:@[Cache_Cancel_Str()] selectors:@[NSStringFromSelector(@selector(endEdit:))]];
        }else{
            //取消编辑后,按钮文字改变,事件改编
            [self setNavigationBarRightButtonsWithTitles:@[Cache_Edit_Str()] selectors:@[NSStringFromSelector(@selector(startEdit:))]];
        }
    }else{
        self.navigationItem.rightBarButtonItems = nil;
        
        if (self.editview.frame.size.height != 0)
        {
            [self.editview mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            self.editview.hidden = YES;
        }
    }
}

#pragma mark - helper
- (void)setNavigationBarRightButtonsWithTitles:(NSArray <NSString *> *)titles
                                     selectors:(NSArray <NSString *> *)selectorNames;
{
    if (!titles || titles.count == 0) { self.navigationItem.rightBarButtonItems = nil; }
    
    __block NSMutableArray *items = [[NSMutableArray alloc]initWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString *titleName, NSUInteger idx, BOOL *stop)
     {
         if (!titleName || titleName.length == 0) { return ;}
         
         SEL selector;
         if (selectorNames.count > idx)
         {
             selector = NSSelectorFromString([selectorNames objectAtIndex:idx]);
         }
         else
         {
             selector = nil;
         }
         if (!selector) { return; }
         
         UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(4, 0, 44, 44)];
         [btn setTitle:titleName forState:UIControlStateNormal];
         [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
         [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
         [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
         UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:btn];
         
         [items addObject:item];
     }];
    
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = items;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
