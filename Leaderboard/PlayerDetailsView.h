//
//  PlayerDetailsView.h
//  Leaderboard
//
//  Created by Alex on 08/05/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Player.h"
#import "Country.h"

@interface PlayerDetailsView : UIView

- (void)showForPlayer:(Player *)player fromCountry:(Country *)country;

@end
