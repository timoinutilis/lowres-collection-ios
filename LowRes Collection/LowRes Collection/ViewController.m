//
//  ViewController.m
//  LowRes Collection
//
//  Created by Timo Kloss on 11.10.22.
//

#import "ViewController.h"
#import "ProgramCell.h"
#import "ProgramModel.h"
#import "RunnerViewController.h"
#import "Compiler/Compiler.h"
#import "Compiler/Runnable.h"
#import <StoreKit/StoreKit.h>

NSString *const NumProgramsOpenedKey = @"NumProgramsOpened";

@interface ViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSMutableArray<ProgramModel *> *programs;
@property UIStoryboard *runnerStoryboard;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.programs = [[NSMutableArray alloc] init];
    NSArray *files = [[NSBundle mainBundle] pathsForResourcesOfType:@"txt" inDirectory:@"programs"];
    files = [files sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (int i = 0; i < files.count; i++) {
        NSString *filename = files[i];
        ProgramModel *program = [[ProgramModel alloc] init];
        program.name = [[filename lastPathComponent] stringByDeletingPathExtension];
        program.sourceCodePath = filename;
        program.imagePath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        [self.programs addObject:program];
    }
    
    self.runnerStoryboard = [UIStoryboard storyboardWithName:@"Runner" bundle:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSIndexPath *indexPath = self.collectionView.indexPathsForSelectedItems.firstObject;
    if (indexPath != nil) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    [self.collectionView flashScrollIndicators];
    
    if ([self numProgramsOpened] == 10) {
        [SKStoreReviewController requestReview];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    CGSize frameSize = self.collectionView.frame.size;
    CGFloat width = frameSize.width;
    if (frameSize.width > frameSize.height || frameSize.width > 640.0) {
        width = width * 0.5;
    }
    layout.itemSize = CGSizeMake(width, floor(width * 0.8));
}

- (NSInteger)numProgramsOpened
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    return [storage integerForKey:NumProgramsOpenedKey];
}

- (void)onProgramOpened
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    [storage setInteger:([storage integerForKey:NumProgramsOpenedKey] + 1) forKey:NumProgramsOpenedKey];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.programs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProgramCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ProgramCell" forIndexPath:indexPath];
    [cell setupProgramModel:self.programs[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ProgramModel *program = self.programs[indexPath.item];
    
    if (program.runnable == nil) {
        self.collectionView.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            program.runnable = [Compiler compileSourceCode:program.sourceCode error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.collectionView.userInteractionEnabled = YES;
                [self presentProgram:program];
            });
        });
    } else {
        [self presentProgram:program];
    }
}

- (void)presentProgram:(ProgramModel *)program {
    RunnerViewController *vc = [self.runnerStoryboard instantiateInitialViewController];
    vc.runnable = program.runnable;
    vc.programName = program.name;
    [self presentViewController:vc animated:YES completion:nil];
    [self onProgramOpened];
}

@end
