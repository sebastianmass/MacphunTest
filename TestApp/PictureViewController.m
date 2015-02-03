//
//  ViewController.m
//  TestApp
//
//  Created by Test on 02.02.15.
//  Copyright (c) 2015 Test. All rights reserved.
//

#import "PictureViewController.h"

@interface PictureViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImage *currentPhoto;
@property (nonatomic, strong) NSArray *filterNamesArray;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic) int currentPage;
@end

@implementation PictureViewController

-(id)initWithPhoto:(UIImage *)aPhoto
{
    if (self = [super init])
    {
        self.currentPhoto = aPhoto;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filterNamesArray = [CIFilter filterNamesInCategory:kCICategoryColorEffect];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    self.mainScrollView = scrollView;
    
    scrollView.pagingEnabled = YES;
    
    scrollView.delegate = self;
    
    scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:scrollView];
    
    self.currentPage = 0;
    
    [self setupScrollView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupScrollView
{
    [self.mainScrollView setContentSize:CGSizeMake(self.view.bounds.size.width * [self.filterNamesArray count], self.view.bounds.size.height)];
    
    for (int i = 0; i < [self.filterNamesArray count]; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width *i, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        imgView.tag = i;
        [self.mainScrollView addSubview:imgView];
        [imgView setImage:self.currentPhoto];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    int selectedPage = roundf(sender.contentOffset.x/self.view.bounds.size.width);
    
    if (selectedPage != self.currentPage) {
        
        self.currentPage = selectedPage;
        
        [self applyFilterWithName:self.filterNamesArray[self.currentPage] toImageView:(UIImageView *)[self.mainScrollView viewWithTag:self.currentPage]];
    }

}

#pragma mark CIImage

- (void)applyFilterWithName:(NSString *)filterName toImageView:(UIImageView *)imageView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        CIImage *beginImage = [CIImage imageWithCGImage:self.currentPhoto.CGImage];
        
        CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, beginImage, nil];
        
        CIImage *outputImage = [filter outputImage];
        
        UIImage *newImage = [UIImage imageWithCIImage:outputImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = newImage;
        });

    });
}

@end
