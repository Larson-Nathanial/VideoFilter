//
//  SMCell.h
//  VideoFilterForYouTube
//
//  Created by Nathan Larson on 2/1/16.
//  Copyright © 2016 appselevated. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMCell : UITableViewCell

@property (nonatomic, copy) void (^silentMode)(id sender);
@property (weak, nonatomic) IBOutlet UISwitch *silentSwitchOutlet;

@end
