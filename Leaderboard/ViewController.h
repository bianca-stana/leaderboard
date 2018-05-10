//
//  ViewController.h
//  Leaderboard
//
//  Created by Alex on 22/03/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase.h>
#import <CoreLocation/CoreLocation.h>

#import "CustomSlider.h"
#import "CustomTableViewCell.h"
#import "Player.h"
#import "Country.h"
#import "PlayerDetailsView.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@end

