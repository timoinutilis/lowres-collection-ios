//
//  ProgramCell.m
//  LowRes Collection
//
//  Created by Timo Kloss on 13.10.22.
//

#import "ProgramCell.h"

@interface ProgramCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property ProgramModel *programModel;
@end

@implementation ProgramCell

- (void)setupProgramModel:(ProgramModel *)programModel {
    self.programModel = programModel;
    self.imageView.image = programModel.image;
}

@end
