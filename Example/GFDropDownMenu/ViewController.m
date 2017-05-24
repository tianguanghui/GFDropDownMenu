//
//  ViewController.m
//  GFDropDownMenu
//
//  Created by TianGuanghui on 2017/5/24.
//  Copyright © 2017年 TianGuanghui. All rights reserved.
//
#define kDropDownMenuHeightIPad     80
#define kDropDownMenuHeightIPhone   40

#import "ViewController.h"
#import "GFDropDownMenuCommon.h"

@interface ViewController () <GFDropDownMenuDataSource, GFDropDownMenuDelegate>
/**
 下拉选择框+CollectionView
 */
@property (nonatomic, strong) GFDropDownMenu *menu;
/**
 分类数组
 */
@property (nonatomic, copy) NSArray *categories;
/**
 价位数组
 */
@property (nonatomic, copy) NSArray *prices;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下拉列表";
    [self.view setBackgroundColor:[UIColor purpleColor]];
    self.categories = @[@"全部课程",@"我的课",@"热销课",@"精品课",@"公开课"];
    self.prices = @[@"全部价格",@"免费",@"0-99元",@"100-200元",@"200元以上"];
    _menu = [[GFDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:(IS_iPad?kDropDownMenuHeightIPad:kDropDownMenuHeightIPhone)];
    _menu.dataSource = self;
    _menu.delegate = self;
    [self.view addSubview:_menu];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - GFDropDownMenuDataSource
- (NSInteger)numberOfColumnsInMenu:(GFDropDownMenu *)menu {
    if (self.categories && self.prices) {
        return 2;
    }
    return 0;
}

- (NSInteger)menu:(GFDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    switch (column) {
        case 0: return [self.categories count];
            break;
        case 1: return [self.prices count];
            break;
        default:
            break;
    }
    return 0;
}

- (NSString *)menu:(GFDropDownMenu *)menu titleForRowAtIndexPath:(GFDDIndexPath *)indexPath {
    switch (indexPath.column) {
        case 0: return self.categories[indexPath.row];
            break;
        case 1: return self.prices[indexPath.row];
            break;
        default:
            return nil;
            break;
    }
}

#pragma mark - GFDropDownMenuDelegate
- (void)menu:(GFDropDownMenu *)menu didSelectRowAtIndexPath:(GFDDIndexPath *)indexPath {
    NSLog(@"column:%li row:%li", (long)indexPath.column, (long)indexPath.row);
    NSLog(@"%@",[menu titleForRowAtIndexPath:indexPath]);
}

@end
