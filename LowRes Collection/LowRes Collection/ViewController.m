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
        program.sourceCodePath = filename;
        program.imagePath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        [self.programs addObject:program];
    }
    
    self.runnerStoryboard = [UIStoryboard storyboardWithName:@"Runner" bundle:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.programs.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProgramCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"ProgramCell" forIndexPath:indexPath];
    [cell setupProgramModel:self.programs[indexPath.item]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize frameSize = collectionView.frame.size;
    CGFloat width = frameSize.width;
    if (frameSize.width > frameSize.height) {
        width = width / 3.0f;
    }
    return CGSizeMake(width, width * 0.8f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ProgramModel *program = self.programs[indexPath.item];
    NSLog(@"Code: %@", program.sourceCode);
    
    NSError *error;
    Runnable *runnable = [Compiler compileSourceCode:program.sourceCode error:&error];
    
    RunnerViewController *vc = [self.runnerStoryboard instantiateInitialViewController];
    vc.runnable = runnable;
    [self presentViewController:vc animated:YES completion:nil];
}

@end
