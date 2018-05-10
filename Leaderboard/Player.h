//
//  Player.h
//  Leaderboard
//
//  Created by Alex on 05/04/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Player : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSString *country;
@property int level;
@property int score;
@property int streak;
@property bool hasPremium;

- (instancetype)init:(NSString *)name withAvatar: (UIImage *)avatar from: (NSString *)country;

@end
