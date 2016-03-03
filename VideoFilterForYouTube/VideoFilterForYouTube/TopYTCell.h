//
//  TopYTCell.h
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 1/31/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface TopYTCell : UITableViewCell

@property (strong, nonatomic) IBOutlet YTPlayerView *youtubeVideo;
@property (nonatomic) NSString *videoId;
- (void)playVideoWithId:(NSString *)video_id;

@end
