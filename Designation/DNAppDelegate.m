//
//  DNAppDelegate.m
//  Designation
//
//  Created by Brent Hronk on 4/2/14.
//  Copyright (c) 2014 Hronik. All rights reserved.
//

#import "DNAppDelegate.h"
#import "DNPlaylistViewController.h"
#import <Spotify/Spotify.h>

static NSString * const kClientId = @"spotify-ios-sdk-beta";
static NSString * const kCallbackURL = @"spotify-ios-sdk-beta://callback";
static NSString * const kTokenSwapURL = @"http://localhost:1234/swap";
static NSString * const kSessionUserDefaultsKey = @"SpotifySession";

@implementation DNAppDelegate

-(void)enableAudioPlaybackWithSession:(SPTSession *)session {
    NSLog(@"enablePlaybackWithSession\n");
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    DNPlaylistViewController *playlistController = (DNPlaylistViewController *)navController.childViewControllers[0];
    NSLog(@"children controller count = %d", navController.childViewControllers.count);
    [playlistController handleNewSession:session];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    // Override point for customization after application launch.
	id plistRep = [[NSUserDefaults standardUserDefaults] valueForKey:kSessionUserDefaultsKey];
	SPTSession *session = [[SPTSession alloc] initWithPropertyListRepresentation:plistRep];
    
	if (session.credential.length > 0) {
		[self enableAudioPlaybackWithSession:session];
        NSLog(@"Successfully logged in\n");
	} else {
		SPTAuth *auth = [SPTAuth defaultInstance];
		NSURL *loginURL = [auth loginURLForClientId:kClientId
								declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
											 scopes:@[@"login"]];
        
        [application performSelector:@selector(openURL:)
                          withObject:loginURL afterDelay:0.1];
	}
    
    return YES;
}

// Handle auth callback
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
        
        // Call the token swap service to get a logged in session
        [[SPTAuth defaultInstance]
         handleAuthCallbackWithTriggeredAuthURL:url
         tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapURL]
         callback:^(NSError *error, SPTSession *session) {
             
             if (error != nil) {
                 NSLog(@"*** Auth error: %@", error);
                 return;
             }
             
             // Call the -playUsingSession: method to play a track
             [self enableAudioPlaybackWithSession:session];
             NSLog(@"Successfully Logged in\n");
         }];
        
        return YES;
    }
    
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
