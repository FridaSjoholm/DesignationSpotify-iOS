//
//  DNDetailViewController.h
//  Designation
//
//  Created by Brent Hronk on 4/2/14.
//  Copyright (c) 2014 Hronik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spotify/Spotify.h"

@interface DNDetailViewController : UIViewController <UISplitViewControllerDelegate>

- (void)setTrack:(SPTTrack *)track index:(NSInteger)index snapshot:(SPTPlaylistSnapshot *)snapshot session:(SPTSession *)session;

@end
