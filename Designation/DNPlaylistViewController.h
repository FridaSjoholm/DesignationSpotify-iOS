//
//  DNPlaylistViewController.h
//  Designation
//
//  Created by Brent Hronk on 4/2/14.
//  Copyright (c) 2014 Hronik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface DNPlaylistViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

-(void)handleNewSession:(SPTSession *)session;

@end
