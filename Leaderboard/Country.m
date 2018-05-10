//
//  Country.m
//  Leaderboard
//
//  Created by Alex on 05/05/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import "Country.h"

@implementation Country

- (instancetype)init:(NSString*)name withFlags: (UIImage *)flag and:(UIImage *)roundFlag {
    
    if (self = [super init]) {
        
        self.name = name;
        self.flag = flag;
        self.roundFlag = roundFlag;
        self.score = 0;
    }
    
    return self;
}

@end
