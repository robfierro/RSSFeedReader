//
//  MasterViewController.m
//  RSS Feed Reader
//
//  Created by Roberto Fierro Martinez on 7/19/15.
//  Copyright (c) 2015 Roberto Fierro Martinez. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LoadingView.h"
#import "RSSParser.h"
#import "RSSFeedTableViewCell.h"
#include <stdlib.h>

typedef NS_ENUM (NSInteger, RSSFeedItemImageType){
    RSSFeedItemImageTypeDescription,
    RSSFeedItemImageTypeContent
};

@interface MasterViewController ()

@property (nonatomic, assign, getter=isRssFeedRequestSucceeded) BOOL rssFeedRequestSucceeded;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *rssFeedItems;


@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // Show loading view
    [[LoadingView sharedLoadingView] showWithMessage:@"Loading RRS Feeds for you! Please wait!"];
    
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
//
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    
    // Get the feeds
    [self readRSSFeed];
}

#pragma mark RSS Feed methods

- (void)readRSSFeed {
    
    NSLog(@"Loading RSS Feed...");
    
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://news.google.com/?output=rss"]];
    
    [RSSParser parseRSSFeedForRequest:req success:^(NSArray *rssFeedItems) {
        
        NSLog(@"RSS Feed: Found %lu RSS Items", (unsigned long)[rssFeedItems count]);
        self.rssFeedItems = rssFeedItems;
        self.rssFeedRequestSucceeded = YES;
        [self.tableView reloadData];
        [[LoadingView sharedLoadingView] dismiss];
        
    } failure:^(NSError *error) {
        
        NSLog(@"RSS Feed Error! : %@", [error localizedDescription]);
        NSString *errorString = [NSString stringWithFormat:@"Oops!! %@... try again later :)", [error localizedDescription]];
        self.rssFeedRequestSucceeded = NO;
        [self showError:errorString];
        
    }];
}

- (void)showError:(NSString *)errorString {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        [[LoadingView sharedLoadingView] dismiss];
    
    }];
    
    [alertController addAction:alertAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(NSString *)urlStringForImageType:(RSSFeedItemImageType)imageType InRSSItem:(RSSItem *)rssItem {
    
    NSArray *imagesFromItemArray = nil;
    
    switch (imageType) {
        case RSSFeedItemImageTypeDescription:
            imagesFromItemArray = [rssItem imagesFromItemDescription];
            break;
        case RSSFeedItemImageTypeContent:
            imagesFromItemArray = [rssItem imagesFromContent];
            break;
        default:
            break;
    }
    
    NSString *urlString = nil;
    
    int count = (int)[imagesFromItemArray count];
    
    if (imagesFromItemArray == nil && count > 0) {
        int randomIndex = arc4random_uniform(count);
        urlString = [imagesFromItemArray objectAtIndex:randomIndex];
    }
    
    return urlString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
        
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self isRssFeedRequestSucceeded]) {
        return 1;
    }
    
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self isRssFeedRequestSucceeded]) {
        return [self.rssFeedItems count];
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RSSFeedTableViewCell *cell = (RSSFeedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"RSSFeedTableViewCellIdentifier" forIndexPath:indexPath];
    
    if ([self isRssFeedRequestSucceeded]) {
        
        RSSItem *rssItem = [self.rssFeedItems objectAtIndex:[indexPath row]];
        [self configureCell:cell usingRSSFeedItem:rssItem];
        
    } else {
        
        NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self configureCell:cell usingManagedObject:managedObject];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(RSSFeedTableViewCell *)cell usingRSSFeedItem:(RSSItem *)rssItem {
    
    cell.titleLabel.text = [self titleFromRSSItem:rssItem];
    cell.sourceLabel.text = [self sourceFromRSSItem:rssItem];
    cell.descriptionLabel.text = [self descriptionFromRSSItem:rssItem];
    
    
    //cell.textLabel.text = rssItem.title;
    NSLog(@"RSS Feed title \n%@\n\n", rssItem.title );
    NSLog(@"RSS Feed description \n%@\n\n", rssItem.itemDescription );
    NSLog(@"RSS Feed content \n%@\n\n", rssItem.content );
    NSLog(@"RSS Feed link \n%@\n\n\n\n", rssItem.link );
    NSLog(@"RSS Feed author \n%@\n\n\n\n", rssItem.author );
    
    
    
    
//    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

- (NSString *)titleFromRSSItem:(RSSItem *)rssItem {
    
    NSString *title = [[rssItem.title componentsSeparatedByString:@"-"] firstObject];
    return [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)sourceFromRSSItem:(RSSItem *)rssItem {
    
    NSString *source = [[rssItem.title componentsSeparatedByString:@"-"] lastObject];
    return [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)descriptionFromRSSItem:(RSSItem *)rssItem {
    
    //
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[rssItem.itemDescription dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    NSString *description = [[attributedString string] stringByReplacingOccurrencesOfString:[self titleFromRSSItem:rssItem] withString:@""];
    
    NSLog(@"RSS Feed description string \n%@\n\n\n\n", description);
    
    description = [description stringByReplacingOccurrencesOfString:[self sourceFromRSSItem:rssItem] withString:@""];
    
    NSLog(@"RSS Feed description string \n%@\n\n\n\n", description);
    
    description = [[description componentsSeparatedByString:@"..."] firstObject];
    
    NSLog(@"RSS Feed description string \n%@\n\n\n\n", description);
    
    return [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)configureCell:(RSSFeedTableViewCell *)cell usingManagedObject:(NSManagedObject *)managedObject {
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RSSFeed" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"feedTitle" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView beginUpdates];
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
//{
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        default:
//            return;
//    }
//}
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath
//{
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    [self.tableView endUpdates];
//}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
