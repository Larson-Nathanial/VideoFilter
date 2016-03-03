//
//  TopYTCell.m
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 1/31/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "TopYTCell.h"

@implementation TopYTCell

- (void)playVideoWithId:(NSString *)video_id
{
    NSDictionary *playerVars = @{
                                 @"playsinline" : @1,
                                 @"showinfo" : @0,
                                 @"rel" : @0,
                                 @"modestbranding" : @1,
                                 @"origin" : @"https://www.appselevated.com"
                                 };
    [self.youtubeVideo loadWithVideoId:video_id playerVars:playerVars];
    //    self.addButtonOutlet.alpha = 0.0;
    self.videoId = video_id;
}

@end
