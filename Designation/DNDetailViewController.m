//
//  DNDetailViewController.m
//  Designation
//
//  Created by Brent Hronk on 4/2/14.
//  Copyright (c) 2014 Hronik. All rights reserved.
//

#import "DNDetailViewController.h"
#import "Spotify/Spotify.h"

@interface DNDetailViewController () <SPTTrackPlayerDelegate>
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;

@property (nonatomic, strong) SPTTrackPlayer *trackPlayer;

@end

@implementation DNDetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"view will disappear\n");
    if (nil != self.trackPlayer) {
        [self.trackPlayer pausePlayback];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Logic

-(void)updateUI {
	if (self.trackPlayer.indexOfCurrentTrack == NSNotFound) {
		self.titleLabel.text = @"Nothing Playing";
		self.albumLabel.text = @"";
		self.artistLabel.text = @"";
		self.coverView.image = nil;
        NSLog(@"updateUi nothing found\n");
	} else {
		NSInteger index = self.trackPlayer.indexOfCurrentTrack;
		SPTAlbum *album = (SPTAlbum *)self.trackPlayer.currentProvider;
		self.titleLabel.text = [album.tracks[index] name];
		self.albumLabel.text = album.name;
		self.artistLabel.text = album.artist.name;
		self.coverView.image = [UIImage imageNamed:@"coverart"];
        NSLog(@"updateUi stuff found\n");
	}
}

- (void) setTrack:(SPTTrack *)track index:(NSInteger)index snapshot:(SPTPlaylistSnapshot*)snapshot session:(SPTSession *)session
{
    if (self.trackPlayer == nil) {
        
		self.trackPlayer = [[SPTTrackPlayer alloc] initWithCompanyName:@"Spotify"
															   appName:@"SimplePlayer"];
		self.trackPlayer.delegate = self;
	}
    
	[self.trackPlayer enablePlaybackWithSession:session callback:^(NSError *error) {
        
		if (error != nil) {
			NSLog(@"*** Enabling playback got error: %@", error);
			return;
		}
        NSLog((@"playback available %hhd\n"), track.availableForPlayback);
        NSLog(@"track uri = %@\n", track.uri);
		[SPTRequest requestItemAtURI:snapshot.uri
						 withSession:session
							callback:^(NSError *error, id object) {
                                
								if (error != nil) {
									NSLog(@"*** track lookup got error %@", error);
									return;
								}
                                
								[self.trackPlayer playTrackProvider:(id <SPTTrackProvider>)object fromIndex:index];
                                NSLog(@"Track callback recieved\n");
							}];
	}];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

#pragma mark - Track Player Delegates

-(void)trackPlayer:(SPTTrackPlayer *)player didStartPlaybackOfTrackAtIndex:(NSInteger)index ofProvider:(id <SPTTrackProvider>)provider {
	NSLog(@"Started playback of track %@ of %@", @(index), provider.uri);
}

-(void)trackPlayer:(SPTTrackPlayer *)player didEndPlaybackOfTrackAtIndex:(NSInteger)index ofProvider:(id<SPTTrackProvider>)provider {
	NSLog(@"Ended playback of track %@ of %@", @(index), provider.uri);
}

-(void)trackPlayer:(SPTTrackPlayer *)player didEndPlaybackOfProvider:(id <SPTTrackProvider>)provider withReason:(SPTPlaybackEndReason)reason {
	NSLog(@"Ended playback of provider %@ with reason %@", provider.uri, @(reason));
}

-(void)trackPlayer:(SPTTrackPlayer *)player didEndPlaybackOfProvider:(id <SPTTrackProvider>)provider withError:(NSError *)error {
	NSLog(@"Ended playback of provider %@ with error %@", provider.uri, error);
}

-(void)trackPlayer:(SPTTrackPlayer *)player didDidReceiveMessageForEndUser:(NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
}

@end
