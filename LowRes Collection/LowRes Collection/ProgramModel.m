//
//  ProgramModel.m
//  LowRes Collection
//
//  Created by Timo Kloss on 13.10.22.
//

#import "ProgramModel.h"

@interface ProgramModel ()

@property UIImage *_image;
@property NSString *_sourceCode;

@end

@implementation ProgramModel

- (UIImage *)image {
    if (self._image == nil) {
        self._image = [[UIImage alloc] initWithContentsOfFile:self.imagePath];
    }
    return self._image;
}

- (NSString *)sourceCode {
    if (self._sourceCode == nil) {
        self._sourceCode = [[NSString alloc] initWithContentsOfFile:self.sourceCodePath encoding:NSUTF8StringEncoding error:nil];
    }
    return self._sourceCode;
}

@end
