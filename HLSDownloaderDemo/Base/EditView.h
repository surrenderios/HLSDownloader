//
//  EditView.h
//  MKTV
//
//  Created by Alex_Wu on 4/15/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

NS_INLINE UIColor *allNormalTitleColor(){
    return [UIColor blackColor];
}

NS_INLINE UIColor *deleteNormalTitleColor(){
    return [UIColor grayColor];
}

NS_INLINE UIColor *deleteSelectedTitleColor(){
    return [UIColor redColor];
}

NS_INLINE NSString *Cache_Edit_Str(){
    return @"编辑";
}

NS_INLINE NSString *Cache_Cancel_Str(){
    return @"取消";
}

NS_INLINE NSString *Cache_Select_All_Str(){
    return @"全部选中";
}

NS_INLINE NSString *Cache_Cancel_Select_All_Str(){
    return @"取消全选";
}

NS_INLINE NSString *Cache_Delete_Str(){
    return @"删除";
}

NS_INLINE NSString *Cache_Delete_Count_Str(NSUInteger count){
    return [NSString stringWithFormat:@"删除(%ld)",count];
}

@interface EditView : UIView
@property (nonatomic, strong) UIButton *allButton;
@property (nonatomic, strong) UIButton *deleteButton;
@end

NS_ASSUME_NONNULL_END
