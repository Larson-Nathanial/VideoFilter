//
//  Connection.m
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 2/1/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import "Connection.h"

@interface Connection ()

@property (nonatomic) NSString *verification;
@property (nonatomic) NSString *googleAPIKEY;

@end

@implementation Connection

/// Some neat information.
+ (Connection *)connection
{
    static Connection *connection = nil;
    
    if (!connection) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            connection = [[self alloc] initPrivate];
        });
    }
    return connection;
}

- (instancetype)initPrivate
{
    self = [super init];
    _verification = @"iefMksUIuchfu2834y823e9hskdfj283r9jhs3dlOIjrhqSDFA4faufDFAfhosdfho48Fdh2j3kfDAGueiwlF32kdjf2";
    _googleAPIKEY = @"AIzaSyASX7gExs0_zaF4URRtxT4a_zzA1kC3PPM";
    return self;
}

- (BOOL)didCreateUserAccount
{
    NSString *post = [NSString stringWithFormat:@"verify=%@", _verification];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.appselevated.com/YTFilter/CreateUser.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (responseData == nil) {
        return NO;
    }else {
        [[NSUserDefaults standardUserDefaults] setValue:[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] forKey:@"user_id"];
        return YES;
    }
    
    return YES;
}

- (BOOL)didSaveVideoId:(NSString *)video_id andTitle:(NSString *)video_title andChannel:(NSString *)channel andImageUrl:(NSString *)image_url
{
    NSString *post = [NSString stringWithFormat:@"verify=%@&user_id=%@&video_id=%@&video_title=%@&channel=%@&image_url=%@", _verification, [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"], video_id, video_title, channel, image_url];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.appselevated.com/YTFilter/SaveVideo.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (responseData == nil) {
        return NO;
    }else {
        return YES;
    }
    
    return YES;
}

- (NSArray *)loadSavedVideosForUserId
{
    NSString *post = [NSString stringWithFormat:@"verify=%@&user_id=%@", _verification, [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.appselevated.com/YTFilter/LoadSavedVideos.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (responseData == nil) {
        return nil;
    }else {
        NSArray *returnData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
            
            if (returnData.count > 0) {
                return returnData;
            }else {
                return nil;
            }
        }
    }
    
    return nil;
}


- (NSArray *)searchResultsForType:(NSString *)search_type andKeyWord:(NSString *)key_word
{
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=\%@&type=\%@&key=\%@&maxResults=50", key_word, search_type, _googleAPIKEY];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *getURL = [NSURL URLWithString:urlString];
    
    NSData *returnData = [NSData dataWithContentsOfURL:getURL];
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:nil];
    NSArray *array = [dictionary valueForKey:@"items"];
    NSLog(@"%@", [[[dictionary valueForKey:@"items"][0] valueForKey:@"id"] valueForKey:@"videoId"]);
    
    return array;
}

- (BOOL)didDeleteSavedVideoWithId:(NSString *)video_unique_id
{
    NSString *post = [NSString stringWithFormat:@"verify=%@&user_id=%@&video_id=%@", _verification, [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"], video_unique_id];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.appselevated.com/YTFilter/DeleteVideo.php"]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if (responseData == nil) {
        return NO;
    }else {
        return YES;
    }
    
    return YES;
}


@end
