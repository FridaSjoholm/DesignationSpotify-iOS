//
//  DNMasterViewController.m
//  Designation
//
//  Created by Brent Hronk on 4/2/14.
//  Copyright (c) 2014 Hronik. All rights reserved.
//

#import "DNMasterViewController.h"

#import "DNDetailViewController.h"
#import <libkern/OSAtomic.h>

@interface DNMasterViewController () {
    NSMutableArray *_objects;
    SPTSession *_session;
    SPTPlaylistSnapshot *_snapshot;
    int count;
    NSLock *lock;
}
@end

@implementation DNMasterViewController

- (void)showTracks:(SPTPlaylistSnapshot *)snapshot session:(SPTSession *)session
{
    _session = session;
    _snapshot = snapshot;
    lock = [[NSLock alloc] init];
    _objects = [[NSMutableArray alloc] init];
    count = 0;
    for (int i = 0; i < snapshot.tracks.count; i++) {
        [_objects addObject:[NSNull null]];
        SPTPartialTrack *partialTrack = snapshot.tracks[i];
        [SPTRequest requestItemFromPartialObject:partialTrack withSession:session callback:
         ^(NSError *error, id object) {
             if (nil != error) {
                 NSLog(@"*** error promoting partial track %@\n", error);
             } else {
                 NSLog(@"fetched track\n");
                 [_objects replaceObjectAtIndex:i withObject:object];
                 [lock lock];
                 count++;
                 if (count == snapshot.tracks.count) {
                     [lock unlock];
                     NSLog(@"reload data\n");
                     [self.tableView reloadData];
                 } else {
                     [lock unlock];
                 }
             }
         }];
    }
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DNDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
//    if (!_objects) {
//        _objects = [[NSMutableArray alloc] init];
//    }
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (count != _objects.count)
        return 0;
    else
        return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    SPTTrack *track = _objects[indexPath.row];
    cell.textLabel.text = track.name;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_objects removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        SPTTrack *track = _objects[indexPath.row];
        [self.detailViewController setTrack:track index:indexPath.row snapshot:_snapshot session:_session];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        SPTTrack *track = _objects[indexPath.row];
        [[segue destinationViewController] setTrack:track index:indexPath.row snapshot:_snapshot session:_session];
    }
}

@end
