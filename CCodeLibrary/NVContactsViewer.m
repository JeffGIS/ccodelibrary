//  NVContactsViewer.m
//  CCodeLibrary

#import "NVContactsViewer.h"
#import "UserDefaults.h"
#import "NVContactGroupData.h"
@import Contacts;

@interface NVContactsViewer () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) UITableView *groupsTV, *contactsTV;
@property (nonatomic) UIButton *returnButton, *sendButton;
@property (nonatomic) CGFloat rowHeight, borderWidth, margin;
@property (nonatomic) UIFont *font, *headerFont, *titleFont, *subtitleFont;
@property (nonatomic) NSArray *groups;
@property (nonatomic) NSArray<NVContact *> *contacts;

@end

@implementation NVContactsViewer

+ (instancetype)contactsViewerWithDelegate:(id)delegate
{
    if (!delegate)
    {
        NSLog(@"NVContactsViewer ERROR:Cannot set delegate to nil");
        return nil;
    }
    
    NVContactsViewer *contacts = NVContactsViewer.new;
    contacts.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    contacts.delegate = delegate;
    return contacts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = UserDefaults.defaults.appleBlue;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _rowHeight = 36.0;
        _borderWidth = 1.5;
        _margin = 12.0;
        _font = [UIFont boldSystemFontOfSize:28.0];
        _headerFont = [UIFont boldSystemFontOfSize:22.0];
        _titleFont = [UIFont boldSystemFontOfSize:18.0];
        _subtitleFont = [UIFont systemFontOfSize:14.0];
    }
    
    else
    {
        _rowHeight = 52.0;
        _borderWidth = 3.0;
        _margin = 20.0;
        _font = [UIFont boldSystemFontOfSize:40.0];
        _headerFont = [UIFont boldSystemFontOfSize:32.0];
        _titleFont = [UIFont boldSystemFontOfSize:24.0];
        _subtitleFont = [UIFont systemFontOfSize:18.0];
    }
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setupButton:_returnButton action:@selector(returnButtonTapped:)
                title:@"< Return"];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setupButton:_sendButton action:@selector(sendButtonTapped:)
                title:@"Send to Selected Contacts"];
    
    _groupsTV = UITableView.new;
    [self setupTableView:_groupsTV];
    _contactsTV = UITableView.new;
    [self setupTableView:_contactsTV];
    [self setupConstraints];
    
    NVContactGroupData *nvcgd = NVContactGroupData.new;
    NSMutableArray *tempGroups = nvcgd.getContactGroupsArray.mutableCopy;
    [tempGroups insertObject:@"All Contacts" atIndex:0];
    _groups = tempGroups.copy;
    _contacts = nvcgd.getContactsArray;
    
    CNContactStore *store = CNContactStore.new;
    
    [store requestAccessForEntityType:CNEntityTypeContacts
                    completionHandler:^(BOOL granted, NSError * _Nullable error)
    {
        if (granted == YES)
        {
            NSArray *keys = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactEmailAddressesKey];
            NSString *containerId = store.defaultContainerIdentifier;
            NSPredicate *predicate = [CNContact predicateForContactsInContainerWithIdentifier:containerId];
            NSError *error = nil;
            
            NSArray *contacts = [store unifiedContactsMatchingPredicate:predicate
                                                            keysToFetch:keys
                                                                  error:&error];
            
            if (error)
                NSLog(@"ERROR fetching contacts: %@", error);
            
            else
            {
                NSMutableArray *tempGroups = _contacts.mutableCopy;
                
                for (CNContact *contact in contacts)
                {
                    NVContact *newContact = NVContact.new;
                    newContact.firstName = contact.givenName;
                    newContact.lastName = contact.familyName;
                    
                    for (CNLabeledValue *label in contact.emailAddresses)
                    {
                        newContact.email = label.value;
                        [tempGroups addObject:newContact];
                    }
                }
                
                _contacts = tempGroups.copy;
            }
        }        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupButton:(UIButton *)button
             action:(SEL)action
              title:(NSString *)title
{
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.titleLabel.font = _font;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [button setTitleColor:UIColor.lightGrayColor forState:UIControlStateHighlighted];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)setupTableView:(UITableView *)tableView
{
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = UIColor.grayColor;
    tableView.bounces = YES;
    tableView.layer.borderColor = UIColor.blackColor.CGColor;
    tableView.layer.borderWidth = _borderWidth;
    tableView.rowHeight = _rowHeight;
    tableView.sectionHeaderHeight = _rowHeight;
    tableView.delaysContentTouches = NO;
    tableView.separatorColor = UIColor.clearColor;
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.allowsSelection = YES;
    tableView.allowsMultipleSelection = (tableView == _contactsTV);
    [self.view addSubview:tableView];
}

- (void)setupConstraints
{
    [_returnButton constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
    [_returnButton constrainTopToAnchor:self.view.topAnchor];
    [_sendButton constrainCenterXToAnchor:self.view.centerXAnchor];
    [_sendButton constrainBottomToAnchor:self.view.bottomAnchor constant:-_margin];
    [_groupsTV constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
    [_groupsTV constrainTopToAnchor:_returnButton.bottomAnchor constant:_margin];
    [_groupsTV constrainBottomToAnchor:_sendButton.topAnchor constant:-_margin];
    [_contactsTV constrainTopToAnchor:_returnButton.bottomAnchor constant:_margin];
    [_contactsTV constrainLeadingToAnchor:_groupsTV.trailingAnchor constant:_margin];
    [_contactsTV constrainTrailingToAnchor:self.view.trailingAnchor constant:-_margin];
    [_contactsTV constrainBottomToAnchor:_sendButton.topAnchor constant:-_margin];
    [_contactsTV constrainWidthToAnchor:_groupsTV.widthAnchor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _groupsTV)
        return _groups.count;
    
    else
        return _contacts.count;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = UIView.new;
    headerView.backgroundColor = UIColor.blackColor;
    UILabel *headerLabel = UILabel.new;
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerLabel.font = _headerFont;
    headerLabel.textColor = UIColor.whiteColor;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    
    if (tableView == _groupsTV)
        headerLabel.text = @"Groups";
    
    else
        headerLabel.text = @"Contacts";
    
    [headerView addSubview:headerLabel];
    [headerLabel constrainToView:headerView leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CustomCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    if (tableView == _groupsTV)
        cell.textLabel.text = _groups[indexPath.row];
    
    else
    {
        NVContact *contact = _contacts[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        cell.detailTextLabel.text = contact.email;
    }
    
    cell.textLabel.font = _titleFont;
    cell.detailTextLabel.font = _subtitleFont;
    UIView *selectedView = UIView.new;
    selectedView.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.2];
    cell.multipleSelectionBackgroundView = selectedView;
    cell.selectedBackgroundView = selectedView;
    cell.layer.borderColor = UIColor.blackColor.CGColor;
    cell.layer.borderWidth = (_borderWidth * 0.4);
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _groupsTV && [tableView.indexPathForSelectedRow isEqual:indexPath])
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        for (int i = 0; i < [_contactsTV numberOfRowsInSection:0]; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [_contactsTV deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        return nil;
    }

    return indexPath;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _groupsTV)
    {
        for (int i = 0; i < [_contactsTV numberOfRowsInSection:0]; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [_contactsTV selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)returnButtonTapped:(UIButton *)button
{
    [_delegate contactsViewerDidReturn:self];
}

- (void)sendButtonTapped:(UIButton *)button
{
    [_delegate contactsViewer:self
              didReturnEmails:[UserDefaults.defaults arrayForKey:@"DefaultRecipients"]];
}

@end
