//
//  EditView.m
//  MKTV
//
//  Created by Alex_Wu on 4/15/19.
//  Copyright © 2019 北京视达科科技有限公司. All rights reserved.
//

#import "EditView.h"

@implementation EditView
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self addSubview:self.allButton];
        [self.allButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.left.mas_equalTo(self.mas_left);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(self).multipliedBy(0.5);
        }];
        
        [self addSubview:self.deleteButton];
        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.right.mas_equalTo(self.mas_right);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.width.mas_equalTo(self).multipliedBy(0.5);
        }];
        
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectZero];
        [verticalLine setBackgroundColor:deleteNormalTitleColor()];
        [self addSubview:verticalLine];
        [verticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).with.offset(10).with.priority(999);
            make.bottom.mas_equalTo(self.mas_bottom).with.offset(-10).with.priority(999);
            make.width.mas_equalTo(1);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        UIView *shadowLine = [[UIView alloc] initWithFrame:CGRectZero];
        [shadowLine setBackgroundColor:deleteNormalTitleColor()];
        [self addSubview:shadowLine];
        [shadowLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
        [self.allButton setTitle:Cache_Select_All_Str()
                        forState:UIControlStateNormal];
        [self.allButton setTitleColor:allNormalTitleColor()
                             forState:UIControlStateNormal];
        
        [self.deleteButton setTitle:Cache_Delete_Str()
                           forState:UIControlStateNormal];
        [self.deleteButton setTitleColor:deleteNormalTitleColor()
                                forState:UIControlStateNormal];
    }
    return self;
}

- (UIButton *)allButton
{
    if (!_allButton) {
        _allButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _allButton.backgroundColor = [UIColor whiteColor];
    }
    return _allButton;
}

- (UIButton *)deleteButton
{
    if(!_deleteButton){
        _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _deleteButton.backgroundColor = [UIColor whiteColor];
    }
    return _deleteButton;
}
@end
