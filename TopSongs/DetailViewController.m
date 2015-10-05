//
//  DetailViewController.m
//  TopSongs
//
//  Created by Hidayathulla on 9/25/13.
//  Copyright (c) 2013 Individual. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "DetailViewController.h"
#import "TopSongsUtil.h"
#import "TopSongsConstant.h"
#import "TopSongsAppDelegate.h"

@interface DetailViewController ()

@end

@implementation DetailViewController{
    UIBarButtonItem *leftBarButton;
    UIButton *leftBackButton;
    UIView *headerView;
    UILabel *headerLabel;
    UIView *bodyView;
    UIImageView *imageView;
    UIScrollView *scrollView;
    CGFloat lastScale;
}
static const float TABLE_HEADER_HEIGHT = 40.0;

@synthesize songTitle;
@synthesize ituneURL;
@synthesize iconURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

// To navigate to App store
- (void)imageArtworkTapped {
    NSString *escaped = [ituneURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:escaped]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Bar
    leftBackButton = [self createButtonItemWithNamedImage:@"icon_back.png" target:self action:@selector(back:)];
    
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,TABLE_HEADER_HEIGHT)];
    [headerView addSubview:leftBackButton];
    
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TitleBGImage.png"]]];
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, headerView.frame.size.width, headerView.frame.size.height)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.font = [UIFont fontWithName:TITLE_FONT size:TITLE_FONT_SIZE];
    [headerLabel setTextColor:[UIColor whiteColor]];
    headerLabel.text = songTitle;
    [headerView addSubview:headerLabel];
    [self.view addSubview:headerView];
    
    bodyView = [[UIView alloc] initWithFrame:CGRectMake(0,headerView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height - headerView.frame.size.height )];
    [bodyView setBackgroundColor:[TopSongsUtil colorWithHex:BODY_COLOR]];
    [self.view addSubview:bodyView];
    // Custom initialization
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageArtworkTapped)];
    singleTap.numberOfTapsRequired = 1;
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
   
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconURL]]];
    imageView = [[UIImageView alloc]init];
    [imageView setImage:image];
    
    imageView.center = self.view.center;
    [imageView addGestureRecognizer:singleTap];
    imageView.userInteractionEnabled = YES;
    
    bodyView.clipsToBounds = YES;
    bodyView.multipleTouchEnabled = YES;
    imageView.multipleTouchEnabled = YES;
    imageView.exclusiveTouch = NO;
    
    
    [bodyView addSubview:imageView];
    
    [imageView addGestureRecognizer:pinch];
    
}
-(void)back:(UIButton *)button{
    
    TopSongsAppDelegate *appDelegate = (TopSongsAppDelegate *)[UIApplication sharedApplication].delegate;
    RootViewController *rootViewController = [[RootViewController alloc]init];
    [appDelegate transitionToViewController:rootViewController
                             withTransition:UIViewAnimationOptionTransitionFlipFromLeft];

}

-(UIButton *)createButtonItemWithNamedImage:(NSString *)imageName target:(NSObject *)target action:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 8, image.size.width/2.0, image.size.height/2)];
    
    return button;
    
}

// To handle pinch gesstures for zoom-in/out
- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (BOOL)shouldAutorotate {
   
    headerView.frame = CGRectMake(0,0,self.view.bounds.size.width,40);
    headerLabel.frame = CGRectMake(25, 0, headerView.frame.size.width, headerView.frame.size.height);
    bodyView.frame = CGRectMake(0,headerView.frame.size.height,self.view.bounds.size.width,self.view.bounds.size.height - headerView.frame.size.height);
    imageView.frame = CGRectMake(50, 50, self.view.bounds.size.width-100, self.view.bounds.size.height-140);
    
    return YES;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
