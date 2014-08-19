#import "URLGetController.h"
#import "NetworkManager.h"

#pragma mark * URLGetController

@interface URLGetController () <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readwrite) IBOutlet UIImageView *imageView;
@property (nonatomic, strong, readwrite) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong, readwrite) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readwrite) IBOutlet UIButton *getOrCancelButton;

- (IBAction)getOrCancelAction:(id)sender;
- (IBAction)goBack:(id)sender;


@property (nonatomic, assign, readonly ) BOOL isReceiving;
@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, copy, readwrite) NSString *filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *fileStream;
@property (nonatomic, copy, readwrite) NSString *ftpSite;
@property (nonatomic, copy, readwrite) NSString *username;
@property (nonatomic, copy, readwrite) NSString *password;
@property (nonatomic, copy, readwrite) NSString *port;
@property (nonatomic, copy, readwrite) NSString *directory;
@property (nonatomic, copy, readwrite) NSString *fileName;
@property (nonatomic, copy, readwrite) NSString *ftpSite2;
@property (nonatomic, copy, readwrite) NSString *username2;
@property (nonatomic, copy, readwrite) NSString *password2;
@property (nonatomic, copy, readwrite) NSString *directory2;
@property (nonatomic, copy, readwrite) NSString *fileName2;
@property (nonatomic, copy, readwrite) NSString *currentFtp;
@property (nonatomic, copy, readwrite) NSString *urlText;
@property (nonatomic, assign, readwrite) BOOL hasFailed;

@end

@implementation URLGetController

- (void)receiveDidStart
{
    self.imageView.image = [UIImage imageNamed:@"NoImage.png"];
    self.statusLabel.text = [NSString stringWithFormat:@"Receiving (from %@)", self.currentFtp];
    
    [self.getOrCancelButton setTitle:@"Cancel"
                            forState:UIControlStateNormal];
    
    [self.activityIndicator startAnimating];
    [NetworkManager.sharedInstance didStartNetworkOperation];
}

- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil)
    {
        assert(self.filePath != nil);
        self.imageView.image = [UIImage imageWithContentsOfFile:self.filePath];
        statusString = [NSString stringWithFormat:@"GET succeeded (from %@)", self.currentFtp];
    }
    
    self.statusLabel.text = statusString;
    
    [self.getOrCancelButton setTitle:@"GET Again"
                            forState:UIControlStateNormal];
    
    [self.activityIndicator stopAnimating];
    [NetworkManager.sharedInstance didStopNetworkOperation];
}

- (BOOL)isReceiving
{
    return (self.connection != nil);
}

- (void)startReceive
{
    BOOL success;
    NSURL *url;
    NSURLRequest *request;
    
    assert(self.connection == nil);
    assert(self.fileStream == nil);
    assert(self.filePath == nil);
    
    url = [NetworkManager.sharedInstance smartURLForString:self.urlText];
    success = (url != nil);
    
    if (!success || ![NetworkManager.sharedInstance isImageURL:url])
    {
        if (self.hasFailed == NO)
        {
            if (self.currentFtp == self.ftpSite)
            {
                [self setToFtpSite2];
                self.currentFtp = self.ftpSite2;
            }
            
            else
            {
                [self setToFtpSite1];
                self.currentFtp = self.ftpSite;
            }
        
            url = [NetworkManager.sharedInstance smartURLForString:self.urlText];
            success = (url != nil);
        }
        
        if (!success)
        {
            self.statusLabel.text = @"Invalid URL";
            return;
        }
        
        else if (![NetworkManager.sharedInstance isImageURL:url])
        {
            self.statusLabel.text = @"Can only get images";
            return;
        }
    }
    
    self.filePath = [NetworkManager.sharedInstance pathForTemporaryFileWithPrefix:@"Get"];
    assert(self.filePath != nil);
        
    self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath
                                                        append:NO];
        
    assert(self.fileStream != nil);
        
    [self.fileStream open];

    request = [NSURLRequest requestWithURL:url];
    assert(request != nil);
        
    self.connection = [NSURLConnection connectionWithRequest:request
                                                    delegate:self];
        
    assert(self.connection != nil);
        
    [self receiveDidStart];
}

- (void)stopReceiveWithStatus:(NSString *)statusString
{
    if (self.connection != nil)
    {
        [self.connection cancel];
        self.connection = nil;
    }
    
    if (self.fileStream != nil)
    {
        [self.fileStream close];
        self.fileStream = nil;
    }
    
    [self receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (void)connection:(NSURLConnection *)theConnection
didReceiveResponse:(NSURLResponse *)response
{
    #pragma unused(theConnection)
    #pragma unused(response)

    assert(theConnection == self.connection);
    assert(response != nil);
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)data
{
    #pragma unused(theConnection)
    NSUInteger dataLength;
    const uint8_t *dataBytes;
    NSInteger bytesWritten;
    NSUInteger bytesWrittenSoFar;

    assert(theConnection == self.connection);
    
    dataLength = data.length;
    dataBytes  = data.bytes;

    bytesWrittenSoFar = 0;
    
    do
    {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar]
                                    maxLength:dataLength - bytesWrittenSoFar];
        
        assert(bytesWritten != 0);
        
        if (bytesWritten <= 0)
        {
            [self stopReceiveWithStatus:@"File write error"];
            break;
        }
        
        else
            bytesWrittenSoFar += (NSUInteger) bytesWritten;
    }
    
    while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)theConnection
  didFailWithError:(NSError *)error
{
    #pragma unused(theConnection)
    #pragma unused(error)
    assert(theConnection == self.connection);
    
    if (self.hasFailed == NO)
    {
        [self stopReceiveWithStatus:nil];
        
        if (self.currentFtp == self.ftpSite)
        {
            [self setToFtpSite2];
            self.currentFtp = self.ftpSite2;
            self.statusLabel.text = [NSString stringWithFormat:@"Receiving (from %@)", self.currentFtp];
            self.hasFailed = YES;
            [self startReceive];
        }
        
        else
        {
            [self setToFtpSite1];
            self.currentFtp = self.ftpSite;
            self.statusLabel.text = [NSString stringWithFormat:@"Receiving (from %@)", self.currentFtp];
            self.hasFailed = YES;
            [self startReceive];
        }
    }
    
    else
    {
        [self stopReceiveWithStatus:@"Connection failed"];
        self.currentFtp = self.ftpSite;
        self.hasFailed = NO;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    #pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self stopReceiveWithStatus:nil];
}

- (IBAction)getOrCancelAction:(id)sender
{
    #pragma unused(sender)
    if (self.isReceiving)
        [self stopReceiveWithStatus:@"Cancelled"];
    
    else
        [self startReceive];
}

- (IBAction)goBack:(id)sender
{
    #pragma unused(sender)
    if (self.isReceiving)
        [self stopReceiveWithStatus:@"Cancelled"];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    assert(self.imageView != nil);
    assert(self.statusLabel != nil);
    assert(self.activityIndicator != nil);
    assert(self.getOrCancelButton != nil);
    
    self.activityIndicator.hidden = YES;
    self.statusLabel.text = @"Tap GET to download image";
    
    [self.getOrCancelButton setTitle:@"GET"
                            forState:UIControlStateNormal];
    
    self.ftpSite = @"gssidata.com";
    self.username = @"GSSiData";
    self.password = @"GSSi";
    self.port = @"14147";
    self.directory = @"GSSi";
    self.fileName = @"RiteHomeLogo.png";
    
    self.ftpSite2 = @"thmgis.com";
    self.username2 = @"waypoint";
    self.password2 = @"pointway4*";
    self.directory2 = @"GSSi";
    self.fileName2 = @"GSSiLogo.png";
    
    self.currentFtp = [UserDefaults.defaults stringForKey:@"CurrentFtp"];
    self.hasFailed = NO;
    
    if (self.currentFtp == self.ftpSite2)
        [self setToFtpSite2];
    
    else
        [self setToFtpSite1];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [UserDefaults.defaults saveString:self.currentFtp
                               forKey:@"CurrentFtp"];
}

- (void)setToFtpSite1
{
    self.urlText = [NSString stringWithFormat:@"%@:%@@%@:%@/%@/%@", self.username, self.password, self.ftpSite, self.port, self.directory, self.fileName];
}

- (void)setToFtpSite2
{
    self.urlText = [NSString stringWithFormat:@"%@:%@@%@/%@/%@", self.username2, self.password2, self.ftpSite2, self.directory2, self.fileName2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    self.imageView = nil;
    self.statusLabel = nil;
    self.activityIndicator = nil;
    self.getOrCancelButton = nil;
}

- (void)dealloc
{
    [self stopReceiveWithStatus:@"Stopped"];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end