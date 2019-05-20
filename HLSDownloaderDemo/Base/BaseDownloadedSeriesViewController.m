//
//  BaseDownloadedSeriesViewController.m
//  MKTV
//
//  Created by Alex_Wu on 4/16/19.
//  Copyright © 2019 Alex. All rights reserved.
//

#import "BaseDownloadedSeriesViewController.h"

@interface BaseDownloadedSeriesViewController ()
@property (nonatomic, strong, readwrite) UITableView *tableView;
@end

@implementation BaseDownloadedSeriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.downloadItem.uniqueId;
    
    UIColor *bgColor = [UIColor whiteColor];
    self.view.backgroundColor = bgColor;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(10);
        make.left.mas_equalTo(self.view.mas_left);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.right.mas_equalTo(self.view.mas_right);
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // subclass
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // subclass
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    [self updateWithSelectedCount:selectedRows.count totalCount:self.datas.count];
}

#pragma mark - edit
- (void)startEdit:(UIButton *)sender;
{
    [super startEdit:sender];
    
    [self.tableView setEditing:YES animated:YES];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-45);
    }];
    [self updateWithSelectedCount:0 totalCount:self.datas.count];
}

- (void)endEdit:(UIButton *)sender;
{
    [super endEdit:sender];
    
    [self.tableView setEditing:NO animated:YES];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    [self updateWithSelectedCount:0 totalCount:self.datas.count];
}

- (void)selectedAll:(id)sender;
{
    [super selectedAll:sender];
    
    //选中数据
    [self.datas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }];
    
    [self updateWithSelectedCount:self.datas.count totalCount:self.datas.count];
}

- (void)cancelSelectedAll:(id)sender;
{
    [super cancelSelectedAll:sender];
    
    [self.tableView reloadData];
    [self updateWithSelectedCount:0 totalCount:self.datas.count];
}

- (void)deleteSelected:(id)sender
{
    [super deleteSelected:sender];
    
    // subclass
}
@end
