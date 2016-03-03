//
//  ParentViewController.m
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 1/31/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "ParentViewController.h"
#import "Connection.h"
#import "YTPlayerView.h"

#import "StandardYTCell.h"
#import "TopYTCell.h"
#import "SMCell.h"

@import GoogleMobileAds;

@interface ParentViewController ()<UITableViewDataSource, UITableViewDelegate, YTPlayerViewDelegate, UITextFieldDelegate, GADInterstitialDelegate>

@property (nonatomic) UITableView *tableView;

@property (nonatomic) YTPlayerView *currentMovieView;

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIView *coverView;

@property (nonatomic) NSArray *videos;

@property (nonatomic) UIView *searchView;
@property (nonatomic) UITextField *searchTextField;
@property (nonatomic) UIButton *doneSearchingButton;

@property (nonatomic) UILabel *videoSavedLabel;

@property (nonatomic) BOOL isSearching;
@property (nonatomic) BOOL justFinishedSearchingAndPlayingVideo;


@property (nonatomic) UIView *pinView;
@property (nonatomic) UITextField *f1;
@property (nonatomic) UIButton *pinButton;

@property (nonatomic) UIView *coverTappableView;

@property (nonatomic) GADInterstitial *watchVideoAd;
@property (nonatomic) int countOfRows;
@property (nonatomic) NSArray *adUnitIds;

@property (nonatomic) NSIndexPath *indexPathSelected;

@property (nonatomic) BOOL adVersion;

@end

@implementation ParentViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Ad version, change this
    self.adVersion = NO;
    
    self.isSearching = NO;
    self.justFinishedSearchingAndPlayingVideo = NO;
    self.countOfRows = 0;
    
    self.adUnitIds = @[@"ca-app-pub-6845273842854200/6488032372", @"ca-app-pub-6845273842854200/9022696370", @"ca-app-pub-6845273842854200/1499429572"];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Parents";
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22.0];
    titleLabel.frame = CGRectMake(0, 0, 150, 30);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 0.0) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([StandardYTCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([StandardYTCell class])];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TopYTCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([TopYTCell class])];
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SMCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SMCell class])];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    self.currentMovieView = [YTPlayerView new];
    self.currentMovieView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.width * 189.0 / 320.0);
    self.currentMovieView.alpha = 0.0;
    self.currentMovieView.delegate = self;
    
    self.currentMovieView.userInteractionEnabled = YES;
    
    
    [self.view addSubview:self.currentMovieView];
    
    self.coverTappableView = [UIView new];
    self.coverTappableView.frame = CGRectMake(0.0, 0.0, self.currentMovieView.frame.size.width, self.currentMovieView.frame.size.height - 44.0);
    self.coverTappableView.backgroundColor = [UIColor clearColor];
    self.coverTappableView.userInteractionEnabled = YES;
    self.coverTappableView.alpha = 0.0;
    
    [self.view addSubview:self.coverTappableView];
    
    self.videoSavedLabel = [UILabel new];
    self.videoSavedLabel.frame = CGRectMake(10.0, self.view.bounds.size.height - 80.0, self.view.bounds.size.width - 20.0, 50.0);
    self.videoSavedLabel.backgroundColor = [UIColor colorWithRed:53.0 / 255.0 green:137.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
    self.videoSavedLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22.0];
    self.videoSavedLabel.textColor = [UIColor whiteColor];
    self.videoSavedLabel.textAlignment = NSTextAlignmentCenter;
    self.videoSavedLabel.text = @"Video Saved";
    self.videoSavedLabel.alpha = 0.0;
    self.videoSavedLabel.layer.cornerRadius = 3.0;
    [self.view addSubview:self.videoSavedLabel];
    
    
    _coverView = [UIView new];
    _coverView.frame = self.view.frame;
    _coverView.backgroundColor = [UIColor colorWithWhite:34.0 / 255.0 alpha:0.8];
    [self.view addSubview:_coverView];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = self.view.center;
    [_activityIndicator startAnimating];
    [_coverView addSubview:_activityIndicator];
    _coverView.alpha = 0.0;

    [self loadSavedVideos];
    
    UIBarButtonItem *switchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"switchArrows"] style:UIBarButtonItemStylePlain target:self action:@selector(doneInParent)];
    
//    self.navigationItem.rightBarButtonItem = switchButton;
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonAction:)];
    
    self.navigationItem.rightBarButtonItems = @[switchButton, searchButton];
    
    self.watchVideoAd = [self createAndLoadInterstitial];
}

- (void)doneInParent
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadSavedVideos
{
    [UIView animateWithDuration:0.3 animations:^{
        _coverView.alpha = 1.0;
    }];
    
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(aQueue, ^{
        
        
        self.videos = [[Connection connection] loadSavedVideosForUserId];
        
        if (self.adVersion) {
            int count = (int)(self.videos.count / 4 ) + 1;
            
            NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.videos];
            
            int runningCounter = 0;
            for (int i = 0; i < mArray.count + count; i++) {
                if (i == 3) {
                    [mArray insertObject:[self.adUnitIds objectAtIndex:runningCounter] atIndex:i];
                    runningCounter++;
                }else if (i % 4 == 1 && i > 4) {
                    if (i > mArray.count) {
                        [mArray addObject:[self.adUnitIds objectAtIndex:runningCounter]];
                    }else {
                        [mArray insertObject:[self.adUnitIds objectAtIndex:runningCounter] atIndex:i];
                    }
                    runningCounter++;
                }
                if (runningCounter > 2) {
                    runningCounter = 0;
                }
            }
            
            self.videos = [NSArray arrayWithArray:mArray];
        }
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
            [UIView animateWithDuration:0.5 animations:^{
                _coverView.alpha = 0.0;
            }];
        });
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1) {
        return NO;
    }
    return YES;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *removeAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Add Video" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              
                                              dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                                              dispatch_async(aQueue, ^{
                                                  
                                                  if (self.isSearching) {
                                                      [[Connection connection] didSaveVideoId:[[self.videos[indexPath.row - 2] valueForKey:@"id"] valueForKey:@"videoId"] andTitle:[[self.videos[indexPath.row - 2] valueForKey:@"snippet"] valueForKey:@"title"] andChannel:[[self.videos[indexPath.row - 2] valueForKey:@"snippet"] valueForKey:@"channelTitle"] andImageUrl:[[[[self.videos[indexPath.row - 2] valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"high"] valueForKey:@"url"]];
                                                  }else {
                                                      [[Connection connection] didSaveVideoId:[self.videos[indexPath.row - 2] valueForKey:@"video_id"] andTitle:[self.videos[indexPath.row - 2] valueForKey:@"title"] andChannel:[self.videos[indexPath.row - 2] valueForKey:@"channel"] andImageUrl:[self.videos[indexPath.row - 2] valueForKey:@"image_url"]];
                                                  }
                                                  
                                                  
                                                  
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                                                      
                                                      [UIView animateWithDuration:1.5 animations:^{
                                                          self.videoSavedLabel.alpha = 1.0;
                                                      }completion:^(BOOL finished){
                                                          [UIView animateWithDuration:1.5 animations:^{
                                                              self.videoSavedLabel.alpha = 0.0;
                                                          }completion:^(BOOL finished){
                                                              
                                                          }];
                                                      }];
                                                      
                                                      
                                                  });
                                              });
                                          }];
    removeAction.backgroundColor = [UIColor colorWithRed:53.0 / 255.0 green:137.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
    
    return @[removeAction];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count + 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1) {
        return 50.0;
    }else if (indexPath.row == 2) {
        float value = self.view.bounds.size.width * 189.0 / 320.0;
        return value;
    }else if ([[self.videos objectAtIndex:indexPath.row - 2] isKindOfClass:[NSString class]]) {
        return 50.0;
    }else {
        return 120.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        SMCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SMCell class]) forIndexPath:indexPath];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"silent_mode"] isEqualToString:@"ON"]) {
            cell.silentSwitchOutlet.on = YES;
        }else {
            cell.silentSwitchOutlet.on = NO;
        }
        
        cell.silentMode = ^(id sender) {
            UISwitch *s = (UISwitch *)sender;
            if (s.on) {
                [[NSUserDefaults standardUserDefaults] setValue:@"ON" forKey:@"silent_mode"];
            }else {
                [[NSUserDefaults standardUserDefaults] setValue:@"OFF" forKey:@"silent_mode"];
            }
        };
        
        return cell;
    }else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
        cell.textLabel.text = @"Require Passcode";
        
        [[cell viewWithTag:254] removeFromSuperview];
        [[cell viewWithTag:523] removeFromSuperview];
        
        UISwitch *s = [UISwitch new];
        s.tag = 523;
        s.onTintColor = [UIColor colorWithRed:53.0 / 255.0 green:137.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
        s.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
        [s addTarget:self action:@selector(requirePasscode:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = s;
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"pin_req"] isEqualToString:@"YES"]) {
            s.on = YES;
        }else {
            s.on = NO;
        }
        
        return cell;
    }else if (indexPath.row == 2) {
        TopYTCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TopYTCell class]) forIndexPath:indexPath];
        
        if (self.isSearching) {
            [cell playVideoWithId:[[self.videos[indexPath.row - 2] valueForKey:@"id"] valueForKey:@"videoId"]];
        }else {
            [cell playVideoWithId:[self.videos[indexPath.row - 2] valueForKey:@"video_id"]];
        }
        
        
        
        return cell;
    }else if ([[self.videos objectAtIndex:indexPath.row - 2] isKindOfClass:[NSString class]]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
        
        [[cell viewWithTag:254] removeFromSuperview];
        [[cell viewWithTag:523] removeFromSuperview];
        cell.textLabel.text = @"";
        cell.accessoryView = nil;
        
        GADBannerView *bannerView = [GADBannerView new];
        bannerView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 50.0);
        bannerView.tag = 254;
        bannerView.adUnitID = [self.videos objectAtIndex:indexPath.row - 2];
        bannerView.rootViewController = self;
        
        [cell addSubview:bannerView];
        
        [bannerView loadRequest:[GADRequest request]];
        
//        self.countOfRows++;
//        if (self.countOfRows > self.adUnitIds.count - 1) {
//            self.countOfRows = 0;
//        }
        
        return cell;
        
    }
    else {
        StandardYTCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([StandardYTCell class]) forIndexPath:indexPath];
        
        //        [cell playVideoWithId:@"qrHFg47Mopk"];
        
        if (self.isSearching) {
            [cell loadVideoArtWithURL:[[[[self.videos[indexPath.row - 2] valueForKey:@"snippet"] valueForKey:@"thumbnails"] valueForKey:@"high"] valueForKey:@"url"]];
            
            cell.videoTitleLabel.text = [[self.videos[indexPath.row - 2] valueForKey:@"snippet"] valueForKey:@"title"];
            cell.channelTitle.text = [[self.videos[indexPath.row - 2] valueForKey:@"snippet"] valueForKey:@"channelTitle"];
            cell.videoId = [[self.videos[indexPath.row - 2] valueForKey:@"id"] valueForKey:@"videoId"];
        }else {
            [cell loadVideoArtWithURL:[self.videos[indexPath.row - 2] valueForKey:@"image_url"]];
            
            cell.videoTitleLabel.text = [self.videos[indexPath.row - 2] valueForKey:@"title"];
            cell.channelTitle.text = [self.videos[indexPath.row - 2] valueForKey:@"channel"];
            cell.videoId = [self.videos[indexPath.row - 2] valueForKey:@"video_id"];
        }
        
        
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.indexPathSelected = indexPath;
    
    if (indexPath.row > 1 && ![[self.videos objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        if (self.adVersion) {
            if ([self.watchVideoAd isReady]) {
                [self.watchVideoAd presentFromRootViewController:self];
            }
        }else {
            
            [self loadVideo];
        }
        
    }
//    [self doneSearching];
    
    
    
    
}

- (void)loadVideo
{
    self.justFinishedSearchingAndPlayingVideo = NO;
    
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"showinfo" : @0,
                                 @"rel" : @0,
                                 @"modestbranding" : @1,
                                 @"origin" : @"https://www.appselevated.com"
                                 };
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        if (self.isSearching) {
            self.currentMovieView.alpha = 1.0;
            self.coverTappableView.alpha = 1.0;
            self.currentMovieView.frame = CGRectMake(0.0, 44.0, self.currentMovieView.frame.size.width, self.currentMovieView.frame.size.height);
            self.tableView.frame = CGRectMake(0.0, self.currentMovieView.frame.size.height + 44.0, self.view.bounds.size.width, self.view.bounds.size.height - self.currentMovieView.frame.size.height - 44.0);
        }else {
            self.currentMovieView.alpha = 1.0;
            self.coverTappableView.alpha = 1.0;
            self.currentMovieView.frame = CGRectMake(0.0, 0.0, self.currentMovieView.frame.size.width, self.currentMovieView.frame.size.height);
            self.tableView.frame = CGRectMake(0.0, self.currentMovieView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.currentMovieView.frame.size.height);
        }
    }completion:^(BOOL finished){
        
        if (self.indexPathSelected.row > 0) {
            StandardYTCell *cell = [self.tableView cellForRowAtIndexPath:self.indexPathSelected];
            [self.currentMovieView loadWithVideoId:cell.videoId playerVars:playerVars];
        }
        
        
    }];

}


- (GADInterstitial *)createAndLoadInterstitial {
    GADInterstitial *interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-6845273842854200/5011299173"];
    interstitial.delegate = self;
    [interstitial loadRequest:[GADRequest request]];
    return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    [self loadVideo];
    self.watchVideoAd = [self createAndLoadInterstitial];
}

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    [playerView playVideo];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    //    if (touch.view == self.currentMovieView) {
    
    [UIView animateWithDuration:0.5 animations:^{
        // going from aWidth to 142.
        //
        self.currentMovieView.frame = CGRectMake(self.view.bounds.size.width - 284.0, location.y - (self.currentMovieView.frame.size.height / 2.0), 284.0, 160.0);
    }];
    //    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    //    if (touch.view == self.currentMovieView) {
    if (location.y >= self.view.bounds.size.height / 2.0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.currentMovieView.frame = CGRectMake(self.view.bounds.size.width - 142.0, self.view.bounds.size.height, 142.0, 80.0);
            
            
            if (!self.isSearching) {
                self.tableView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                        withAnimation:UIStatusBarAnimationFade];
            }else {
                self.tableView.frame = CGRectMake(0.0, 44.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0);
            }
            
            
        }completion:^(BOOL finished){
            self.currentMovieView.alpha = 0.0;
            self.coverTappableView.alpha = 0.0;
            self.currentMovieView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.width * 189.0 / 320.0);
            [self.currentMovieView stopVideo];
        }];
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            if (self.isSearching) {
                self.currentMovieView.frame = CGRectMake(0.0, 44.0, self.view.bounds.size.width, self.view.bounds.size.width * 189.0 / 320.0);
            }else {
                if (self.justFinishedSearchingAndPlayingVideo) {
                    self.currentMovieView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.view.bounds.size.width * 189.0 / 320.0);
                }else {
                    self.currentMovieView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.width * 189.0 / 320.0);
                }
                
            }
            
        }];
    }
    //    }
}

- (void)searchButtonAction:(id)sender {
    
//    self.isSearching = YES;
    
    self.searchView = [UIView new];
    self.searchView.backgroundColor = [UIColor colorWithWhite:34.0 / 255.0 alpha:1.0];
    self.searchView.frame = CGRectMake(0.0, -44.0, self.view.bounds.size.width, 44.0);
    [self.view addSubview:self.searchView];
    
    self.searchTextField = [UITextField new];
    self.searchTextField.frame = CGRectMake(10.0, 0.0, self.view.bounds.size.width - 100.0, 44.0);
    self.searchTextField.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
    self.searchTextField.text = @"Enter search...";
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.delegate = self;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [self.searchView addSubview:self.searchTextField];
    
    self.doneSearchingButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.doneSearchingButton.frame = CGRectMake(self.view.bounds.size.width - 90.0, 0.0, 70.0, 44.0);
    [self.doneSearchingButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneSearchingButton setTitleColor:[UIColor colorWithRed:53.0 / 255.0 green:137.0 / 255.0 blue:255.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.doneSearchingButton addTarget:self action:@selector(doneSearching) forControlEvents:UIControlEventTouchUpInside];
    [self.searchView addSubview:self.doneSearchingButton];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        self.searchView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0);
        self.tableView.frame = CGRectMake(0.0, 44.0, self.view.bounds.size.width, self.view.bounds.size.height - 44.0);
    }completion:^(BOOL finished){
        [self.searchTextField becomeFirstResponder];
    }];
    
}

- (void)doneSearching
{
        self.isSearching = NO;
    if (self.currentMovieView.alpha == 1.0) {
        self.justFinishedSearchingAndPlayingVideo = YES;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.searchView.frame = CGRectMake(0.0, -44.0, self.view.bounds.size.width, 44.0);
        
        
        
//        self.tableView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 0.0);
        if (self.currentMovieView.alpha == 1.0) {
            self.currentMovieView.frame = CGRectMake(0.0, 64.0, self.view.bounds.size.width, self.currentMovieView.frame.size.height);
            self.tableView.frame = CGRectMake(0.0, self.currentMovieView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.currentMovieView.frame.size.height));
        }else {
            self.tableView.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - 0.0);
        }
    }completion:^(BOOL finished){
        [self loadSavedVideos];
//        [self.tableView reloadData];
        [self.searchView removeFromSuperview];
        self.searchView = nil;
        
        [self.searchTextField resignFirstResponder];
        [self.searchTextField removeFromSuperview];
        self.searchTextField = nil;
        
        [self.doneSearchingButton removeFromSuperview];
        self.doneSearchingButton = nil;
        
    }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:@"Enter search..."]) {
        textField.text = @"";
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *searchString = @"";
    if (string.length == 0) { // Backspace
        searchString = [textField.text substringToIndex:textField.text.length - 1];
    }else {
        searchString = [[searchString stringByAppendingString:textField.text] stringByAppendingString:string];
    }
    
    //    NSPredicate *pred = [NSPredicate predicateWithFormat:@"business_name CONTAINS[c] %@", searchString];
    //    self.searchResults = [self.businessList filteredArrayUsingPredicate:pred];
    //    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.isSearching = YES;
    
    if (textField.text.length != 0) {
        [UIView animateWithDuration:0.3 animations:^{
            _coverView.alpha = 1.0;
        }];
        
        [textField resignFirstResponder];
        
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(aQueue, ^{
            
            
            self.videos = [[Connection connection] searchResultsForType:@"video" andKeyWord:textField.text];
            
            if (self.adVersion) {
                int count = (int)(self.videos.count / 4 ) + 1;
                
                NSMutableArray *mArray = [NSMutableArray arrayWithArray:self.videos];
                
                int runningCounter = 0;
                for (int i = 0; i < mArray.count + count; i++) {
                    if (i == 3) {
                        [mArray insertObject:[self.adUnitIds objectAtIndex:runningCounter] atIndex:i];
                        runningCounter++;
                    }else if (i % 4 == 1 && i > 4) {
                        if (i > mArray.count) {
                            [mArray addObject:[self.adUnitIds objectAtIndex:runningCounter]];
                        }else {
                            [mArray insertObject:[self.adUnitIds objectAtIndex:runningCounter] atIndex:i];
                        }
                        runningCounter++;
                    }
                    if (runningCounter > 2) {
                        runningCounter = 0;
                    }
                }
                
                self.videos = [NSArray arrayWithArray:mArray];
            }
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
                [UIView animateWithDuration:0.5 animations:^{
                    _coverView.alpha = 0.0;
                }];
            });
        });
    }else {
        [textField resignFirstResponder];
    }
    
    
    
    
    
    return NO;
}

- (void)requirePasscode:(UISwitch *)s
{
    if (s.on) {
        [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"pin_req"];
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"user_pin"] == nil) {
            [self displayPinView];
        }
    }else {
        [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"pin_req"];
    }
}

// Pin View

- (void)displayPinView
{
    self.pinView = [UIView new];
    self.pinView.frame = CGRectMake(self.view.bounds.size.width / 2.0 - 150.0, 100.0, 300.0, 165.0);
    self.pinView.backgroundColor = [UIColor colorWithWhite:245.0 / 255.0 alpha:1.0];
    self.pinView.alpha = 0.0;
    self.pinView.layer.cornerRadius = 5.0;
    [self.view addSubview:self.pinView];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Create Passcode";
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22.0];
    titleLabel.frame = CGRectMake(0, 5.0, self.pinView.frame.size.width, 30);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor blackColor];
    [self.pinView addSubview:titleLabel];
    
    self.f1 = [UITextField new];
    self.f1.frame = CGRectMake(10.0, 50.0, self.pinView.bounds.size.width - 20.0, 44.0);
    self.f1.font = [UIFont fontWithName:@"AvenirNext-Regular" size:22.0];
    self.f1.placeholder = @"7362";
    self.f1.secureTextEntry = YES;
    self.f1.textColor = [UIColor blackColor];
    self.f1.textAlignment = NSTextAlignmentCenter;
    self.f1.delegate = self;
    self.f1.keyboardType = UIKeyboardTypeDecimalPad;
    [self.pinView addSubview:self.f1];
    
    self.pinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.pinButton.frame = CGRectMake(10.0, 110.0, self.pinView.bounds.size.width - 20.0, 44.0);
    [self.pinButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.pinButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.pinButton.backgroundColor = [UIColor colorWithRed:53.0 / 255.0 green:137.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
    self.pinButton.layer.cornerRadius = 5.0;
    [self.pinButton addTarget:self action:@selector(pinComplete) forControlEvents:UIControlEventTouchUpInside];
    [self.pinView addSubview:self.pinButton];
    
    [UIView animateWithDuration:0.6 animations:^{
        self.coverView.alpha = 1.0;
        self.pinView.alpha = 1.0;
    }completion:^(BOOL finished){
        [self.f1 becomeFirstResponder];
    }];
    
    
}

- (void)pinComplete
{
    NSString *text = self.f1.text;
    
    [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"user_pin"];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0.0;
        self.pinView.alpha = 0.0;
    }completion:^(BOOL finished){
        [self.pinView removeFromSuperview];
        self.pinView = nil;
        self.pinButton = nil;
        self.f1 = nil;
    }];
    
}


@end
