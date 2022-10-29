//
//  ProgramCell.h
//  LowRes Collection
//
//  Created by Timo Kloss on 13.10.22.
//

#import <UIKit/UIKit.h>
#import "ProgramModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ProgramCellDelegate <NSObject>
- (void)didSelectLeaderboardForProgram:(ProgramModel *)program;
@end

@interface ProgramCell : UICollectionViewCell

@property (weak) id<ProgramCellDelegate> delegate;
- (void)setupProgramModel:(ProgramModel *)programModel;

@end

NS_ASSUME_NONNULL_END
