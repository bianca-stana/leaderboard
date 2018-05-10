//
//  Player.m
//  Leaderboard
//
//  Created by Alex on 05/04/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import "Player.h"

@implementation Player

- (instancetype)init:(NSString*)name withAvatar: (UIImage *)avatar from: (NSString *)location {
    
    if (self = [super init]) {
        
        self.name = name;
        self.avatar = avatar;
        self.country = location;
        self.level = 1;
        self.score = 0;
        self.streak = 1;
        self.hasPremium = false;
    }
    
    return self;
}

@end
