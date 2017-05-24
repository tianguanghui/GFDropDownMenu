//
//  GFDropDownMenu.h
//  60fen
//
//  Created by TianGuanghui on 2017/5/23.
//  Copyright © 2017年 Xuelang Borui Education Technology (Beijing) Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFDDIndexPath.h"

#pragma mark - GFDropDownMenuDataSource
@class GFDropDownMenu;

@protocol GFDropDownMenuDataSource <NSObject>

@required
- (NSInteger)menu:(GFDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column;
- (NSString *)menu:(GFDropDownMenu *)menu titleForRowAtIndexPath:(GFDDIndexPath *)indexPath;
@optional
//default value is 1
- (NSInteger)numberOfColumnsInMenu:(GFDropDownMenu *)menu;

@end

#pragma mark - GFDropDownMenuDelegate
@protocol GFDropDownMenuDelegate <NSObject>
@optional
- (void)menu:(GFDropDownMenu *)menu didSelectRowAtIndexPath:(GFDDIndexPath *)indexPath;
@end

#pragma mark - interface
@interface GFDropDownMenu : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id <GFDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <GFDropDownMenuDelegate> delegate;

@property (nonatomic, strong) UIColor *indicatorColor;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *separatorColor;
/**
 *  the width of menu will be set to screen width defaultly
 *
 *  @param origin the origin of this view's frame
 *  @param height menu's height
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;
- (NSString *)titleForRowAtIndexPath:(GFDDIndexPath *)indexPath;

//programmatically dismiss
- (void)dismiss;

//programmatically select row
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

