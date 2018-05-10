//
//  PlayerDetailsView.m
//  Leaderboard
//
//  Created by Alex on 08/05/2018.
//  Copyright © 2018 Bianca Bucur. All rights reserved.
//

#import "PlayerDetailsView.h"

// TODO: Show the languages of the player

// MARK: -

@interface PlayerDetailsView ()

@property (weak, nonatomic) IBOutlet UIView *blackView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *countryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *premiumImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *streakLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@end;

// MARK: -

@implementation PlayerDetailsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// MARK: - IBAction Methods

- (IBAction)closeButtonTouchUp:(id)sender {
    
    [UIView animateWithDuration:0.25 animations:^{
        self.blackView.alpha = 0;
        self.alpha = 0;
    }];
}

// MARK: - Public Methods

- (void)showForPlayer:(Player *)player fromCountry:(Country *)country {
    
    self.avatarImageView.image = player.avatar;
    self.countryImageView.image = country.flag;
    self.premiumImageView.hidden = !player.hasPremium;
    
    self.nameLabel.text = player.name;
    self.countryLabel.text = country.name;
    self.scoreLabel.text = [NSString stringWithFormat:@"%d", player.score];
    self.streakLabel.text = [NSString stringWithFormat:@"%d", player.streak];
    self.levelLabel.text = [NSString stringWithFormat:@"%d", player.level];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.blackView.alpha = 0.5;
        self.alpha = 1;
    }];
}

@end
