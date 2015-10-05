    //
//  RootViewController.m
//  TopSongs
//
//  Created by Hidayathulla on 9/25/13.
//  Copyright (c) 2013 Individual. All rights reserved.
//

#import "RootViewController.h"
#import "AppRecord.h"
#import "TopSongsAppDelegate.h"
#import "IconDownloader.h"
#import "TopSongsConstant.h"
#import "TopSongsUtil.h"
#import "DetailViewController.h"
#import "ParseOperation.h"

#define kCustomRowCount 5


@interface RootViewController () <UIScrollViewDelegate>
    // the set of IconDownloader objects for each app
    @property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
    // the queue to run our "ParseOperation"
    @property (nonatomic, strong) NSOperationQueue *queue;
    // RSS feed network connection to the App Store
    @property (nonatomic, strong) NSURLConnection *appListFeedConnection;
    @property (nonatomic, strong) NSMutableData *appListData;

@end

@implementation RootViewController{
     DetailViewController *detailVC;
     UIView *headerView;
     UILabel *headerLabel;
}
static const float TABLE_HEADER_HEIGHT = 40.0;

@synthesize customTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
     self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    customTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view setBackgroundColor:[TopSongsUtil colorWithHex:BODY_COLOR]];
    [self setTableViewProperties:customTableView];
    customTableView.tableFooterView = [[UIView alloc] init];
   
    [self.view addSubview:customTableView];
    [self setup];
}

// To set all required table view properties
-(void) setTableViewProperties : (UITableView *) tableView {
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

- (BOOL)shouldAutorotate {
    
    customTableView.frame = self.view.bounds;
    headerView.frame = CGRectMake(0,0,customTableView.frame.size.width,40);
    headerLabel.frame = CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height);
    return YES;
}

#pragma mark - UITableViewDataSource

// -------------------------------------------------------------------------------
//	tableView:numberOfRowsInSection:
//  Customize the number of rows in the table view.
// -------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSUInteger count = [self.entries count];
	
	// if there's no data yet, return enough rows to fill the screen
    if (count == 0)
	{
        return kCustomRowCount;
    }
    return count;
}

// To lazy load top 10 songs
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	static NSString *CellIdentifier = @"LazyTableCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    NSUInteger nodeCount = [self.entries count];
   	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PlaceholderCellIdentifier];
        }
        cell.detailTextLabel.text = @"Loading…";
		return cell;
    }
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
        
		cell.textLabel.text = appRecord.songTitle;
        cell.detailTextLabel.text = appRecord.artist;
		
        // Only load cached images; defer new downloads until scrolling ends
        if (!appRecord.songIcon)
        {
            if (tableView.dragging == NO && tableView.decelerating == NO)
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            cell.imageView.image = appRecord.songIcon;
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,TABLE_HEADER_HEIGHT)];
    [headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"TitleBGImage.png"]]];
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.font = [UIFont fontWithName:TITLE_FONT size:TITLE_FONT_SIZE];
    [headerLabel setTextColor:[UIColor whiteColor]];
    headerLabel.text = @"Top Songs";
    [headerView addSubview:headerLabel];
    
    return headerView;
    
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  TABLE_HEADER_HEIGHT;
}

// To handle Individual cell (Album song) selected by user
- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
    // Get cell textLabel string to use in new view controller title
    NSString *ituneURL = appRecord.appURLString;
    
    // Set title indicating what row/section was tapped
    // present it modally (not necessary, but sometimes looks better then pushing it onto the stack - depending on your App)
    detailVC = [[DetailViewController alloc]init];
    [detailVC setSongTitle:appRecord.songTitle];
    [detailVC setIconURL:appRecord.songURLString];
    [detailVC setItuneURL:ituneURL];
    
   
  /*  [self transitionFromViewController:detailVC toViewController:detailVC duration:0.5 options:UIViewAnimationOptionCurveLinear animations:^(){
        
    }completion:^(BOOL finished){
        
    }];*/
    
    TopSongsAppDelegate *appDelegate = (TopSongsAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate transitionToViewController:detailVC
                             withTransition:UIViewAnimationOptionTransitionFlipFromRight];
    
}

    #pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        [iconDownloader setCompletionHandler:^{
            
            UITableViewCell *cell = [customTableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.imageView.image = appRecord.songIcon;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [customTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            
            if (!appRecord.songIcon)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


// Network
- (void) setup {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:TopSongsFeed]];
    self.appListFeedConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(self.appListFeedConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//
#pragma mark - NSURLConnectionDelegate methods

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.appListData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.appListData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NETWORK_CONNECTIVITY_FAILURE
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [TopSongsUtil alertPopup:noConnectionError];
       
    }
	else
	{
        // otherwise handle the error generically
        [TopSongsUtil alertPopup:error];
    }
    
    self.appListFeedConnection = nil;
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.appListFeedConnection = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // create the queue to run our ParseOperation
    self.queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the RSS feed data
    // so that the UI is not blocked
    ParseOperation *parser = [[ParseOperation alloc] initWithData:self.appListData];
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [TopSongsUtil alertPopup:parseError];
        });
    };
    
    ParseOperation *weakParser = parser;
    parser.completionBlock = ^(void) {
        if (weakParser.appRecordList) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.entries = weakParser.appRecordList;
                
                // tell our table view to reload its data, now that parsing has completed
                [self.customTableView reloadData];
            });
        }
        self.queue = nil;
    };
    
    [self.queue addOperation:parser]; // this will start the "ParseOperation"
    
    // ownership of appListData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    self.appListData = nil;
}


@end
