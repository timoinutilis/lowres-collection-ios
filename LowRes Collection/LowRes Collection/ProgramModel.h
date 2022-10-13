//
//  ProgramModel.h
//  LowRes Collection
//
//  Created by Timo Kloss on 13.10.22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgramModel : NSObject

@property NSString *sourceCodePath;
@property NSString *imagePath;

- (UIImage *)image;
- (NSString *)sourceCode;

@end

NS_ASSUME_NONNULL_END
