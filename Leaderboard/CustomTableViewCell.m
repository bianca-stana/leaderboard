//
//  CustomTableViewCell.m
//  Leaderboard
//
//  Created by Alex on 22/03/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

@end
