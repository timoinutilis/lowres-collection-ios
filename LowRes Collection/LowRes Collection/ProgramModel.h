//
//  ProgramModel.h
//  LowRes Collection
//
//  Created by Timo Kloss on 13.10.22.
//

#import <UIKit/UIKit.h>
#import "Runnable.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProgramModel : NSObject

@property NSString *sourceCodePath;
@property NSString *imagePath;
@property NSString *name;
@property Runnable *runnable;
@property BOOL hasLeaderboard;

- (UIImage *)image;
- (NSString *)sourceCode;

@end

NS_ASSUME_NONNULL_END
