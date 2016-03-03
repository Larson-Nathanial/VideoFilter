//
//  Connection.h
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 2/1/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <Foundation/Foundation.h>
/// This is my connection class!

@interface Connection : NSObject


+ (Connection *)connection;

- (BOOL)didCreateUserAccount;

- (BOOL)didSaveVideoId:(NSString *)video_id andTitle:(NSString *)video_title andChannel:(NSString *)channel andImageUrl:(NSString *)image_url;

- (NSArray *)loadSavedVideosForUserId;

- (NSArray *)searchResultsForType:(NSString *)search_type andKeyWord:(NSString *)key_word;

- (BOOL)didDeleteSavedVideoWithId:(NSString *)video_unique_id;

@end
