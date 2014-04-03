//
//  DNMasterViewController.h
//  Designation
//
//  Created by Brent Hronk on 4/2/14.
//  Copyright (c) 2014 Hronik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Spotify/Spotify.h"

@class DNDetailViewController;

@interface DNMasterViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

- (void)showTracks:(SPTPlaylistSnapshot *)snapshot session:(SPTSession *)session;

@property (strong, nonatomic) DNDetailViewController *detailViewController;


@end
