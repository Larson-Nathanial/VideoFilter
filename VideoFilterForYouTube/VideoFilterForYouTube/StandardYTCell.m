//
//  StandardYTCell.m
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 1/31/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "StandardYTCell.h"

@implementation StandardYTCell

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

- (void)loadVideoArtWithURL:(NSString *)artURL
{
    NSURL *imageURL = [NSURL URLWithString:artURL];
    self.artImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            self.artImageView.image = [UIImage imageWithData:imageData];
        });
    });
}

@end
