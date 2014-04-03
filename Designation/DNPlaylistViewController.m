//
//  DNPlaylistViewController.m
//  Designation
//
//  Created by Brent Hronk on 4/2/14.
//  Copyright (c) 2014 Hronik. All rights reserved.
//

#import "DNPlaylistViewController.h"
#import "DNMasterViewController.h"

@interface DNPlaylistViewController () {
    SPTSession *_session;
}

@property(strong, atomic) NSMutableArray *snapshotList;
@end

@implementation DNPlaylistViewController

- (void)handleNewSession:(SPTSession *)session
{
    _session = session;
    NSLog(@"handle new session\n");
    [SPTRequest playlistsForUser:session.canonicalUsername withSession:session callback:^(NSError *error, id object) {
        if (nil != error) {
            NSLog(@"*** Auth error: %@\n", error);
            return;
        } else {
            if (nil == self.snapshotList)
                self.snapshotList = [[NSMutableArray alloc] init];
            SPTPlaylistList *list = object;
            NSLog(@"*** List length %d", list.items.count);
            for (SPTPartialPlaylist *partialPlaylist in list.items) {
                [SPTRequest requestItemFromPartialObject:partialPlaylist withSession:session callback:
                 ^(NSError *error, id object) {
                    if (nil != error) {
                        NSLog(@"*** error promoting partial playlist %@\n", error);
                    } else {
                        [self.snapshotList addObject:object];
                        [self.tableView reloadData];
                    }
                }];
            }
        }
    }];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    NSLog(@"playlist init with style\n");
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"playlist view did load %@\n", self);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (nil == self.snapshotList) {
        NSLog(@"num rows = 0\n");
        return 0;
    } else {
        NSLog(@"num rows = %d\n", self.snapshotList.count);
        return self.snapshotList.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell for Row index = %d\n", indexPath.row);
    if (nil != self.snapshotList && indexPath.row < self.snapshotList.count) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];
    
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    
        SPTPlaylistSnapshot *snapshot = self.snapshotList[indexPath.row];
        cell.textLabel.text = snapshot.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", snapshot.tracks.count];
    // Configure the cell...
    
        return cell ;
    } else {
        return nil;
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"playlistToTracksSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DNMasterViewController *dnMasterViewController = segue.destinationViewController;
        [dnMasterViewController showTracks:[self.snapshotList objectAtIndex:indexPath.row] session:_session];
    }
}


@end
