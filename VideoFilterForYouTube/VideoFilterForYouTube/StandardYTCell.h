//
//  StandardYTCell.h
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 1/31/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface StandardYTCell : UITableViewCell

@property (strong, nonatomic) IBOutlet YTPlayerView *youtubeVideo;
@property (nonatomic) NSString *videoId;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelTitle;
- (void)playVideoWithId:(NSString *)video_id;

- (void)loadVideoArtWithURL:(NSString *)artURL;
@property (weak, nonatomic) IBOutlet UIImageView *artImageView;

@end
