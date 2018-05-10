//
//  ViewController.m
//  Leaderboard
//
//  Created by Alex on 22/03/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import "ViewController.h"

// TODO: Refactor the code
// TODO: Insert comments where needed
// TODO: Player selection

// MARK: -

@interface ViewController ()

@property (strong, nonatomic) FIRDatabaseReference *dbReference;

@property (weak, nonatomic) IBOutlet CustomSlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (weak, nonatomic) IBOutlet UIButton *countryButton;
@property (weak, nonatomic) IBOutlet UIButton *globalButton;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIButton *backwardButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet PlayerDetailsView *playerDetailsView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property int locationFetchCounter;

@property (strong, nonatomic) NSString *currentActiveTab;

@property (strong, nonatomic) NSMutableArray *months;

@property (strong, nonatomic) NSMutableDictionary<NSString *, Country *> *countries;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *> *countriesLeaderboard;
@property (strong, nonatomic) NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *allTimeCountriesLeaderboard;

@property (strong, nonatomic) NSMutableDictionary<NSString *, Player *> *players;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *> *playersLeaderboard;
@property (strong, nonatomic) NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *allTimePlayersLeaderboard;

@property int currentMonthIndex;
@property int localLeaderboardIndex;

@end

// MARK: -

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dbReference = [[FIRDatabase database] reference];
    
    UIImage *sliderThumb = [UIImage imageNamed:@"slider-thumb.png"];
    [self.slider setThumbImage:sliderThumb forState:UIControlStateNormal];
    [self.slider setThumbImage:sliderThumb forState:UIControlStateHighlighted];
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.geocoder = [[CLGeocoder alloc] init];
        self.locationFetchCounter = 0;
        
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];

    } else {
        NSLog(@"Location services are not enabled");
    }
    
//    NSDate *now = [NSDate date];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MMMM"];
//    NSString *currentMonth = [[formatter stringFromDate:now] uppercaseString];
    
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.months = [NSMutableArray new];
    self.countries = [NSMutableDictionary new];
    self.countriesLeaderboard = [NSMutableDictionary new];
    self.allTimeCountriesLeaderboard = [NSMutableArray new];
    self.players = [NSMutableDictionary new];
    self.playersLeaderboard = [NSMutableDictionary new];
    self.allTimePlayersLeaderboard = [NSMutableArray new];
    
    [self getCountriesFromDatabase]; // 2nd executed
    [self getPlayersFromDatabase]; // 3rd executed
    [self getLeaderboardFromDatabase]; // 1st executed
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

// MARK: - IBAction Methods

- (IBAction)sliderTouchUp:(id)sender {
    
    NSInteger sliderValue = lroundf(self.slider.value);
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.slider setValue:sliderValue animated:YES];
    }];
    
    CATransition *transition = [self createTransitionOfType:kCATransitionFade andSubtype:nil withDuration:0.25];
    [self.friendsButton.layer addAnimation:transition forKey:nil];
    [self.countryButton.layer addAnimation:transition forKey:nil];
    [self.globalButton.layer addAnimation:transition forKey:nil];
    
    if (self.self.slider.value == 0) {
        self.friendsButton.hidden = YES;
        self.countryButton.hidden = YES;
        self.globalButton.hidden = YES;
        
    } else {
        self.friendsButton.hidden = NO;
        self.countryButton.hidden = NO;
        self.globalButton.hidden = NO;
    }
    
    self.localLeaderboardIndex = 0;
    [self.tableView reloadData];
}

- (IBAction)friendsButtonTouchUp:(id)sender {
    
    [self.friendsButton setBackgroundImage:[UIImage imageNamed:@"tab-button_active.png"] forState:UIControlStateNormal];
    [self.friendsButton setImage:[UIImage imageNamed:@"friends-icon-fill.png"] forState:UIControlStateNormal];
    
    [self.countryButton setBackgroundImage:[UIImage imageNamed:@"tab-button_inactive.png"] forState:UIControlStateNormal];
    [self.countryButton setImage:[UIImage imageNamed:@"country-icon-empty.png"] forState:UIControlStateNormal];
    
    [self.globalButton setBackgroundImage:[UIImage imageNamed:@"tab-button_inactive.png"] forState:UIControlStateNormal];
    [self.globalButton setImage:[UIImage imageNamed:@"global-icon-empty.png"] forState:UIControlStateNormal];
    
    self.currentActiveTab = self.friendsButton.currentTitle;
    [self.tableView reloadData];
}

- (IBAction)countryButtonTouchUp:(id)sender {
    
    [self.friendsButton setBackgroundImage:[UIImage imageNamed:@"tab-button_inactive.png"] forState:UIControlStateNormal];
    [self.friendsButton setImage:[UIImage imageNamed:@"friends-icon-empty.png"] forState:UIControlStateNormal];
    
    [self.countryButton setBackgroundImage:[UIImage imageNamed:@"tab-button_active.png"] forState:UIControlStateNormal];
    [self.countryButton setImage:[UIImage imageNamed:@"country-icon-fill.png"] forState:UIControlStateNormal];
    
    [self.globalButton setBackgroundImage:[UIImage imageNamed:@"tab-button_inactive.png"] forState:UIControlStateNormal];
    [self.globalButton setImage:[UIImage imageNamed:@"global-icon-empty.png"] forState:UIControlStateNormal];
    
    self.currentActiveTab = self.countryButton.currentTitle;
    self.localLeaderboardIndex = 0;
    [self.tableView reloadData];
}

- (IBAction)globalButtonTouchUp:(id)sender {
    
    [self.friendsButton setBackgroundImage:[UIImage imageNamed:@"tab-button_inactive.png"] forState:UIControlStateNormal];
    [self.friendsButton setImage:[UIImage imageNamed:@"friends-icon-empty.png"] forState:UIControlStateNormal];
    
    [self.countryButton setBackgroundImage:[UIImage imageNamed:@"tab-button_inactive.png"] forState:UIControlStateNormal];
    [self.countryButton setImage:[UIImage imageNamed:@"country-icon-empty.png"] forState:UIControlStateNormal];
    
    [self.globalButton setBackgroundImage:[UIImage imageNamed:@"tab-button_active.png"] forState:UIControlStateNormal];
    [self.globalButton setImage:[UIImage imageNamed:@"global-icon-fill.png"] forState:UIControlStateNormal];
    
    self.currentActiveTab = self.globalButton.currentTitle;
    [self.tableView reloadData];
}

- (IBAction)backwardButtonTouchUp:(id)sender {
    
    if (self.currentMonthIndex > 0) {
        self.currentMonthIndex--;
    }
    
    CATransition *transition = [self createTransitionOfType:kCATransitionPush andSubtype:kCATransitionFromLeft withDuration:0.4];
    [self.monthLabel.layer addAnimation:transition forKey:nil];
    [self.tableView.layer addAnimation:transition forKey:nil];
    
    self.monthLabel.text = self.months[self.currentMonthIndex];
    
    self.localLeaderboardIndex = 0;
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
    
    if (self.currentMonthIndex == 0) {
        self.backwardButton.enabled = NO;
        
    }
    
    if (self.currentMonthIndex < self.months.count - 1) {
        UIImage *backwardArrow = [UIImage imageNamed:@"arrow.png"];
        UIImage *forwardArrow = [UIImage imageWithCGImage:backwardArrow.CGImage scale:backwardArrow.scale orientation:UIImageOrientationUpMirrored];
        
        [self.forwardButton setImage:forwardArrow forState:UIControlStateNormal];
        [self.forwardButton setTitle:nil forState:UIControlStateNormal];
        
    } else if (self.currentMonthIndex == self.months.count - 1) {
        self.forwardButton.enabled = YES;
        [self.forwardButton setImage:nil forState:UIControlStateNormal];
        [self.forwardButton setTitle:@"All time" forState:UIControlStateNormal];
        [self.forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

- (IBAction)forwardButtonTouchUp:(id)sender {
    
    if (self.currentMonthIndex < self.months.count) {
        self.currentMonthIndex++;
    }
    
    CATransition *transition = [self createTransitionOfType:kCATransitionPush andSubtype:kCATransitionFromRight withDuration:0.4];
    [self.monthLabel.layer addAnimation:transition forKey:nil];
    [self.tableView.layer addAnimation:transition forKey:nil];
    
    self.monthLabel.text = self.currentMonthIndex < self.months.count ? self.months[self.currentMonthIndex] : @"ALL TIME";
    
    self.localLeaderboardIndex = 0;
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    
    if (self.currentMonthIndex > 0) {
        self.backwardButton.enabled = YES;
    }
    
    if (self.currentMonthIndex == self.months.count - 1) {
        [self.forwardButton setImage:nil forState:UIControlStateNormal];
        [self.forwardButton setTitle:@"All time" forState:UIControlStateNormal];
        
    } else if (self.currentMonthIndex == self.months.count) {
        self.forwardButton.enabled = NO;
        [self.forwardButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateNormal];
    }
}

// MARK: - UITableView Interface Methods

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CustomTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" ];
//    }
    
    int index = (int)indexPath.row;
    
    cell.rankLabel.text = [NSString stringWithFormat:@"%d", index + 1];
    
    switch ((int)self.slider.value) {
        case 0:
            {
                NSArray *currentLeaderboard = [self.monthLabel.text isEqualToString:@"ALL TIME"] ? self.allTimeCountriesLeaderboard : self.countriesLeaderboard[self.monthLabel.text];
                
                NSString *countryCode = [currentLeaderboard[index] allKeys][0];
                
                cell.avatarImageView.image = self.countries[countryCode].roundFlag;
                cell.countryImageView.image = nil;
                cell.premiumImageView.hidden = YES;
                cell.nameLabel.text = self.countries[countryCode].name;
                cell.scoreLabel.text = [NSString stringWithFormat:@"%@", currentLeaderboard[index][countryCode]];
            }
            break;
        case 1:
            {
                NSArray *currentLeaderboard = [self.monthLabel.text isEqualToString:@"ALL TIME"] ? self.allTimePlayersLeaderboard : self.playersLeaderboard[self.monthLabel.text];
                
                if ([self.currentActiveTab isEqualToString:self.countryButton.currentTitle]) {
                    index = self.localLeaderboardIndex;
                    
                    if (index >= currentLeaderboard.count) {
                        break;
                    }
                    
                    Player *player = self.players[[currentLeaderboard[index] allKeys][0]];
                    
                    while (![self.countries[player.country].name isEqualToString:self.countryButton.currentTitle] && index < currentLeaderboard.count - 1) {
                        index++;
                        player = self.players[[currentLeaderboard[index] allKeys][0]];
                    }
                    
                    self.localLeaderboardIndex = index + 1;
                    
                } else if ([self.currentActiveTab isEqualToString:self.friendsButton.currentTitle]) {
                    // TODO: "Points" -> "Friends"
                }
                
                NSString *playerUsername = [currentLeaderboard[index] allKeys][0];
                
                cell.avatarImageView.image = self.players[playerUsername].avatar;
                cell.countryImageView.image = nil;
                cell.premiumImageView.hidden = !self.players[playerUsername].hasPremium;
                cell.nameLabel.text = self.players[playerUsername].name;
                cell.scoreLabel.text = [NSString stringWithFormat:@"%@", currentLeaderboard[index][playerUsername]];
                
                if ([self.currentActiveTab isEqualToString:self.globalButton.currentTitle]) {
                    cell.countryImageView.image = self.countries[self.players[playerUsername].country].flag;
                }
            }
            break;
        case 2:
            {
                // TODO: "Streak"
            }
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count = 0;
    
    switch ((int)self.slider.value) {
    case 0:
        {
            NSArray *currentLeaderboard = [self.monthLabel.text isEqualToString:@"ALL TIME"] ? self.allTimeCountriesLeaderboard : self.countriesLeaderboard[self.monthLabel.text];
            
            count = (int)currentLeaderboard.count;
        }
        break;
    case 1:
        {
            NSArray *currentLeaderboard = [self.monthLabel.text isEqualToString:@"ALL TIME"] ? self.allTimePlayersLeaderboard : self.playersLeaderboard[self.monthLabel.text];
            
            if ([self.currentActiveTab isEqualToString:self.globalButton.currentTitle]) {
                count = (int)currentLeaderboard.count;
                
            } else if ([self.currentActiveTab isEqualToString:self.countryButton.currentTitle]) {
                for (NSDictionary *monthLeaderboard in currentLeaderboard) {
                    Player *player = self.players[[monthLeaderboard allKeys][0]];
                    
                    if ([self.countries[player.country].name isEqualToString:self.countryButton.currentTitle]) {
                        count++;
                    }
                }
                
            } else if ([self.currentActiveTab isEqualToString:self.friendsButton.currentTitle]) {
                // TODO: "Points" -> "Friends"
            }
        }
        break;
    case 2:
        {
            // TODO: "Streak"
        }
        break;
    }
    
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.slider.value == 0) {
        return;
    }
    
    CustomTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Below line works only if the player's username is the same as the player's name (ignoring the case)
    // So... TODO: Find a better way to access the player
    Player *player = self.players[[cell.nameLabel.text lowercaseString]];
    Country *country = self.countries[player.country];
    
    [self.playerDetailsView showForPlayer:player fromCountry:country];
}

// MARK: - CLLocationManager Interface Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    if (self.locationFetchCounter > 0) {
        return;
    }
    
    self.locationFetchCounter++;
    
    [self.geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks lastObject];
        NSString *country = placemark.country;
        
        [self.countryButton setTitle:country forState:UIControlStateNormal];
        self.currentActiveTab = self.countryButton.currentTitle;
        
        self.localLeaderboardIndex = 0;
        [self.tableView reloadData];
        
        [self.locationManager stopUpdatingLocation];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to fetch current location: %@", error);
}

// MARK: - Database Related Methods

- (void)getCountriesFromDatabase {
    
    [[self.dbReference child:@"Countries"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSEnumerator *allCountries = snapshot.children;
        FIRDataSnapshot *countrySnapshot;
        while (countrySnapshot = [allCountries nextObject]) {
            NSString *countryName = countrySnapshot.value[@"Name"];
            NSString *countryFlag = countrySnapshot.value[@"Flag"];
            NSString *countryRoundFlag = countrySnapshot.value[@"RoundFlag"];
            
            Country *country = [[Country alloc] init:countryName withFlags:[UIImage imageNamed:countryFlag] and:[UIImage imageNamed:countryRoundFlag]];
            
            [self.countries setObject:country forKey:countrySnapshot.key];
        }
        
        //        self.localLeaderboardIndex = 0;
        //        [self.tableView reloadData];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)getPlayersFromDatabase {
    
    [[self.dbReference child:@"Players"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSEnumerator *allPlayers = snapshot.children;
        FIRDataSnapshot *playerSnapshot;
        while (playerSnapshot = [allPlayers nextObject]) {
            NSString *playerUsername = playerSnapshot.key;
            NSString *playerName = playerSnapshot.value[@"Name"];
            NSString *playerAvatar = playerSnapshot.value[@"Avatar"];
            NSString *playerCountry = playerSnapshot.value[@"Country"];
            
            Player *player = [[Player alloc] init:playerName withAvatar:[UIImage imageNamed:playerAvatar] from:playerCountry];
            player.level = [(NSNumber *)playerSnapshot.value[@"Level"] intValue];
            player.streak = [(NSNumber *)playerSnapshot.value[@"Streak"] intValue];
            player.hasPremium = [(NSNumber *)playerSnapshot.value[@"Premium"] boolValue];
            
            for (NSArray *monthLeaderboard in self.playersLeaderboard.allValues) {
                for (NSDictionary *playerScore in monthLeaderboard) {
                    if ([playerUsername isEqualToString:[playerScore allKeys][0]]) {
                        player.score += [playerScore[playerUsername] intValue];
                        break;
                    }
                }
            }
            
            [self.players setObject:player forKey:playerUsername];
            
            self.countries[player.country].score += player.score;
        }
        
        NSArray *playerUsernames = [self.players keysSortedByValueUsingComparator:^NSComparisonResult(id first, id second) {
            
            Player *firstPlayer = (Player *)first;
            Player *secondPlayer = (Player *)second;
            
            return [[NSNumber numberWithInt:secondPlayer.score] compare:[NSNumber numberWithInt:firstPlayer.score]];
        }];
        
        for (NSString *playerUsername in playerUsernames) {
            [self.allTimePlayersLeaderboard addObject:@{playerUsername: [NSNumber numberWithInt:self.players[playerUsername].score]}];
        }
        
        NSArray *countryCodes = [self.countries keysSortedByValueUsingComparator:^NSComparisonResult(id first, id second) {
            
            Country *firstCountry = (Country *)first;
            Country *secondCountry = (Country *)second;
            
            return [[NSNumber numberWithInt:secondCountry.score] compare:[NSNumber numberWithInt:firstCountry.score]];
        }];
        
        for (NSString *countryCode in countryCodes) {
            [self.allTimeCountriesLeaderboard addObject:@{countryCode: [NSNumber numberWithInt:self.countries[countryCode].score]}];
        }
        
        for (NSString *month in self.playersLeaderboard) {
            NSArray *monthlyPlayersLeaderboard = self.playersLeaderboard[month];
            
            NSMutableDictionary *monthlyCountriesScores = [NSMutableDictionary new];
            NSMutableArray *monthlyCountriesLeaderboard = [NSMutableArray new];
            
            for (NSDictionary *playerAndScore in monthlyPlayersLeaderboard) {
                NSString *playerUsername = [playerAndScore allKeys][0];
                NSString *playerCountry = self.players[playerUsername].country;
                
                if (monthlyCountriesScores[playerCountry] == nil) {
                    [monthlyCountriesScores setObject:playerAndScore[playerUsername] forKey:playerCountry];
                    
                } else {
                    NSNumber *playerScore = (NSNumber *)playerAndScore[playerUsername];
                    NSNumber *countryScore = monthlyCountriesScores[playerCountry];
                    NSNumber *newCountryScore = [NSNumber numberWithInt:[playerScore intValue] + [countryScore intValue]];
                    
                    [monthlyCountriesScores setObject:newCountryScore forKey:playerCountry];
                }
            }
            
            NSArray *countryCodes = [monthlyCountriesScores keysSortedByValueUsingComparator:^NSComparisonResult(id first, id second) {
                
                return [second compare:first];
            }];
            
            for (NSString *countryCode in countryCodes) {
                [monthlyCountriesLeaderboard addObject:@{countryCode: monthlyCountriesScores[countryCode]}];
            }
            
            [self.countriesLeaderboard setObject:monthlyCountriesLeaderboard forKey:month];
        }
        
        self.localLeaderboardIndex = 0;
        [self.tableView reloadData];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)getLeaderboardFromDatabase {
    
    [[self.dbReference child:@"Leaderboard"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSEnumerator *months = snapshot.children;
        FIRDataSnapshot *month;
        while (month = [months nextObject]) {
            NSString *monthName = [month.value[@"Month"] uppercaseString];
            
            [self.months addObject:monthName];
            
            NSDictionary *monthPlayers = month.value[@"Players"];
            
            NSArray *monthLeaderboardUsernames = [monthPlayers keysSortedByValueUsingComparator:^(id first, id second) {
                
                return [second compare:first];
            }];
            
            NSMutableArray *monthLeaderboard = [NSMutableArray new];
            for (NSString *playerUsername in monthLeaderboardUsernames) {
                [monthLeaderboard addObject:@{playerUsername: monthPlayers[playerUsername]}];
            }
            
            [self.playersLeaderboard setObject:monthLeaderboard forKey:monthName];
        }
        
        self.currentMonthIndex = (int)self.months.count - 1;
        self.monthLabel.text = self.months[self.currentMonthIndex];
        
        //        self.localLeaderboardIndex = 0;
        //        [self.tableView reloadData];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

// MARK: - Animation Methods

-(CATransition *)createTransitionOfType:(NSString *)type andSubtype:(NSString *)subtype withDuration:(float)duration {
    
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = type;
    transition.subtype = subtype;
    
    return transition;
}

@end
