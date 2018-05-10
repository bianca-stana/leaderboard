//
//  Country.h
//  Leaderboard
//
//  Created by Alex on 05/05/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Country : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *flag;
@property (strong, nonatomic) UIImage *roundFlag;
@property int score;

- (instancetype)init:(NSString *)name withFlags: (UIImage *)flag and:(UIImage *)roundFlag;

@end
