//
//  GFDDIndexPath.m
//  60fen
//
//  Created by TianGuanghui on 2017/5/23.
//  Copyright © 2017年 Xuelang Borui Education Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "GFDDIndexPath.h"

@implementation GFDDIndexPath
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
    }
    return self;
}

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row {
    GFDDIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}
@end
