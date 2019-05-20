//
//  EditViewProtocol.h
//  MKTV
//
//  Created by Alex_Wu on 4/15/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#ifndef EditViewProtocol_h
#define EditViewProtocol_h

#import "EditView.h"

@protocol EditViewProtocol <NSObject>
@property (nonatomic, strong) EditView *editview;
/**
 点击编辑按钮
 
 @param sender sender
 */
- (void)startEdit:(UIButton *)sender;


/**
 完成编辑
 
 @param sender sender
 */
- (void)endEdit:(UIButton *)sender;


/**
 点击全选
 
 @param sender sender
 */
- (void)selectedAll:(id)sender;


/**
 点击取消全选
 
 @param sender sender
 */
- (void)cancelSelectedAll:(id)sender;


/**
 点击删除
 
 @param sender sender
 */
- (void)deleteSelected:(id)sender;

/**
 更新按钮title显示
 
 @param count 选中的
 @param totalCount 总计的
 */
- (void)updateWithSelectedCount:(NSUInteger)count totalCount:(NSUInteger)totalCount;

@end

@protocol EditDataProtocol<EditViewProtocol>
@property (nonatomic, strong) NSMutableArray *datas;
@end

#endif /* EditViewProtocol_h */
