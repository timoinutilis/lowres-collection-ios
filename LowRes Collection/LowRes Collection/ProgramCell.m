//
//  ProgramCell.m
//  LowRes Collection
//
//  Created by Timo Kloss on 13.10.22.
//

#import "ProgramCell.h"
#import <GameKit/GameKit.h>

@interface ProgramCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *leaderboardButton;
@property ProgramModel *programModel;
@end

@implementation ProgramCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.layer.magnificationFilter = kCAFilterNearest;
}

- (void)setupProgramModel:(ProgramModel *)programModel {
    self.programModel = programModel;
    self.imageView.image = programModel.image;
    if (@available(iOS 14.0, *)) {
        self.leaderboardButton.hidden = !programModel.hasLeaderboard;
    } else {
        self.leaderboardButton.hidden = YES;
    }
}

- (IBAction)onLeaderboardAction:(id)sender {
    [self.delegate didSelectLeaderboardForProgram:self.programModel];
}

@end
