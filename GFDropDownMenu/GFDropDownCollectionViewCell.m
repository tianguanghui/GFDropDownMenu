//
//  GFDropDownCollectionViewCell.m
//  60fen
//
//  Created by TianGuanghui on 2017/5/23.
//  Copyright © 2017年 Xuelang Borui Education Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "GFDropDownCollectionViewCell.h"

@implementation GFDropDownCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _textLabel = [[UILabel alloc] init];
    [_textLabel setTextColor:[UIColor blackColor]];
    [_textLabel setFont:IS_iPad?[UIFont systemFontOfSize:28]:[UIFont systemFontOfSize:14]];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setText:@""];
    [self.contentView addSubview:_textLabel];
    UIView *superview = self.contentView;
    [_textLabel makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview);
    }];
    return self;
}

// 告诉 UIKit 你正在使用 AutoLayout
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
}

@end
