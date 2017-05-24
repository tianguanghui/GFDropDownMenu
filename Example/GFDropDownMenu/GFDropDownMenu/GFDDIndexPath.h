//
//  GFDDIndexPath.h
//  60fen
//
//  Created by TianGuanghui on 2017/5/23.
//  Copyright © 2017年 Xuelang Borui Education Technology (Beijing) Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GFDDIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row;

@end
