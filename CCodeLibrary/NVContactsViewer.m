//  NVContactsViewer.m
//  CCodeLibrary

#import "NVContactsViewer.h"
#import "UserDefaults.h"
#import "NVContactGroupData.h"
@import Contacts;

@interface NVContactsViewer () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic) UITableView *groupsTV, *contactsTV;
@property (nonatomic) UIButton *returnButton, *sendButton, *helpButton, *plusButton;
@property (nonatomic) CGFloat rowHeight, borderWidth, margin;
@property (nonatomic) UIFont *font, *headerFont, *titleFont, *subtitleFont;
@property (nonatomic, copy) NSArray *groups, *systemContacts;
@property (nonatomic, copy) NSArray<NVContact *> *contacts;
@property (nonatomic) UIView *topContainer;
@property (nonatomic) NVContactGroupData *contactsDB;
@property BOOL inAddMode;
@property (nonatomic, copy) NSString *groupHeader;

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
    _inAddMode = NO;
    
    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        _rowHeight = 36.0;
        _borderWidth = 1.5;
        _margin = 8.0;
        _font = [UIFont boldSystemFontOfSize:24.0];
        _headerFont = [UIFont boldSystemFontOfSize:22.0];
        _titleFont = [UIFont boldSystemFontOfSize:18.0];
        _subtitleFont = [UIFont systemFontOfSize:14.0];
    }
    
    else
    {
        _rowHeight = 52.0;
        _borderWidth = 3.0;
        _margin = 16.0;
        _font = [UIFont boldSystemFontOfSize:40.0];
        _headerFont = [UIFont boldSystemFontOfSize:32.0];
        _titleFont = [UIFont boldSystemFontOfSize:24.0];
        _subtitleFont = [UIFont systemFontOfSize:18.0];
    }
    
    _topContainer = UIView.new;
    _topContainer.translatesAutoresizingMaskIntoConstraints = NO;
    _topContainer.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_topContainer];
    _helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _helpButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_topContainer addSubview:_helpButton];
    _helpButton.imageEdgeInsets = UIEdgeInsetsMake((_rowHeight / 12.0), 0.0, (_rowHeight / 12.0), 0.0);
    
    [_helpButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whiteQuestionMark"
                                                                                         ofType:@"png"]]
                 forState:UIControlStateNormal];
    
    [_helpButton addTarget:self
                    action:@selector(helpButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _plusButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_topContainer addSubview:_plusButton];
    
    _plusButton.imageEdgeInsets = UIEdgeInsetsMake((_rowHeight / 6.0), (_rowHeight / 6.0),
                                                   (_rowHeight / 6.0), (_rowHeight / 6.0));
    
    [_plusButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"whitePlus"
                                                                                         ofType:@"png"]]
                 forState:UIControlStateNormal];
    
    [_plusButton addTarget:self
                    action:@selector(plusButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_topContainer addSubview:_returnButton];
    
    [self setupButton:_returnButton
               action:@selector(returnButtonTapped:)
                title:@"< Return"];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_sendButton];
    
    [self setupButton:_sendButton
               action:@selector(sendButtonTapped:)
                title:@"Send to Selected Contacts"];
    
    _groupsTV = UITableView.new;
    [self setupTableView:_groupsTV];
    _groupHeader = @"System Contacts";
    
    [_groupsTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                           animated:NO
                     scrollPosition:UITableViewScrollPositionNone];
    
    _contactsTV = UITableView.new;
    [self setupTableView:_contactsTV];
    [self setupConstraints];
    
    _contactsDB = NVContactGroupData.new;
    [self setGroupListFromDB];
    
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
                NSMutableArray *tempContacts = NSMutableArray.array;
                
                for (CNContact *contact in contacts)
                {
                    for (CNLabeledValue *label in contact.emailAddresses)
                    {
                        NVContact *newContact = NVContact.new;
                        newContact.firstName = contact.givenName;
                        newContact.lastName = contact.familyName;
                        newContact.email = label.value;
                        [tempContacts addObject:newContact];
                    }
                }
                
                [tempContacts sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
                                                     [NSSortDescriptor sortDescriptorWithKey:@"email" ascending:YES]]];
                
                _systemContacts = tempContacts.copy;
                _contacts = _systemContacts.copy;
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
    tableView.allowsSelection = YES;
    tableView.allowsMultipleSelection = (tableView == _contactsTV);
    tableView.allowsSelectionDuringEditing = YES;
    [self.view addSubview:tableView];
}

- (void)setupConstraints
{
    [_topContainer constrainLeadingToAnchor:self.view.leadingAnchor];
    [_topContainer constrainTopToAnchor:self.view.topAnchor];
    [_topContainer constrainTrailingToAnchor:self.view.trailingAnchor];
    [_topContainer constrainHeightToConstant:(_rowHeight * 1.25)];
    [_returnButton constrainLeadingToAnchor:_topContainer.leadingAnchor constant:_margin];
    [_returnButton constrainTopToAnchor:_topContainer.topAnchor constant:(_margin * 0.375)];
    [_groupsTV constrainLeadingToAnchor:self.view.leadingAnchor constant:_margin];
    [_groupsTV constrainTopToAnchor:_topContainer.bottomAnchor constant:(_margin * 0.375)];
    [_contactsTV constrainTopToAnchor:_groupsTV.topAnchor];
    [_contactsTV constrainLeadingToAnchor:_groupsTV.trailingAnchor constant:_margin];
    [_contactsTV constrainTrailingToAnchor:self.view.trailingAnchor constant:-_margin];
    [_contactsTV constrainWidthToAnchor:_groupsTV.widthAnchor];
    [_sendButton constrainTopToAnchor:_contactsTV.bottomAnchor constant:(_margin * 0.375)];
    [_sendButton constrainCenterXToAnchor:self.view.centerXAnchor];
    [_sendButton constrainBottomToAnchor:self.view.bottomAnchor constant:(-_margin * 0.375)];
    [_sendButton constrainHeightToConstant:(_rowHeight * 1.25)];
    [_groupsTV constrainBottomToAnchor:_contactsTV.bottomAnchor];
    [_helpButton constrainTrailingToAnchor:_topContainer.trailingAnchor constant:(-_margin * 0.375)];
    [_helpButton constrainTopToAnchor:_topContainer.topAnchor];
    [_helpButton constrainBottomToAnchor:_topContainer.bottomAnchor];
    [_helpButton constrainWidthToConstant:(_rowHeight * 1.25)];
    [_plusButton constrainTrailingToAnchor:_helpButton.leadingAnchor constant:(-_margin * 0.375)];
    [_plusButton constrainTopToAnchor:_topContainer.topAnchor];
    [_plusButton constrainBottomToAnchor:_topContainer.bottomAnchor];
    [_plusButton constrainWidthToConstant:(_rowHeight * 1.25)];
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
         headerLabel.text = _groupHeader;
    
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
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.font = _subtitleFont;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    UIView *selectedView = UIView.new;
    selectedView.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.2];
    cell.multipleSelectionBackgroundView = selectedView;
    cell.selectedBackgroundView = selectedView;
    
    if ([cell.textLabel.text isEqualToString:@"Create New Group"])
    {
        cell.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        cell.textLabel.textColor = UIColor.darkGrayColor;
        cell.layer.borderWidth = 0.0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    else
    {
        cell.backgroundColor = UIColor.whiteColor;
        cell.textLabel.textColor = UIColor.blackColor;
        cell.layer.borderColor = UIColor.blackColor.CGColor;
        cell.layer.borderWidth = (_borderWidth * 0.4);
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _groupsTV)
    {
        if ([tableView.indexPathForSelectedRow isEqual:indexPath])
        {
            if (_inAddMode)
                [self deselectGroup];
            
            else
            {
                UITableViewCell *cell = [_groupsTV cellForRowAtIndexPath:indexPath];
                
                if (![cell.textLabel.text isEqualToString:@"Create New Group"])
                {
                    if (_contactsTV.indexPathsForSelectedRows.count < _contacts.count)
                        [self selectAllContacts];
                    
                    else
                        [self deselectAllContacts];
                }
            }
            
            return nil;
        }
        
        else if (indexPath.row == 0 && _inAddMode)
            return nil;
    }

    return indexPath;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _groupsTV && !_inAddMode)
    {
        [self deselectAllContacts];
        UITableViewCell *cell = [_groupsTV cellForRowAtIndexPath:indexPath];
        [cell setHighlighted:YES animated:NO];
        _groupHeader = cell.textLabel.text;
        
        if ([_groupHeader isEqualToString:@"System Contacts"])
            _contacts = _systemContacts.copy;
        
        else
            _contacts = [_contactsDB getContactsArrayInContactGroup:_groupHeader];
        
        [_contactsTV reloadData];
    }
}

- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_groupsTV cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:NO animated:NO];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _contactsTV)
    {
        if ([_groupHeader isEqualToString:@"System Contacts"])
            return UITableViewCellEditingStyleNone;
        
        else
            return UITableViewCellEditingStyleDelete;
    }
    
    else if (indexPath.row > 0)
        return UITableViewCellEditingStyleDelete;
    
    
    else
        return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _contactsTV)
    {
        NVContact *contact = _contacts[indexPath.row];
        
        [_contactsDB removeEmail:contact.email
                       firstName:contact.firstName
                        lastName:contact.lastName
                fromContactGroup:_groupHeader];
        
        _contacts = [_contactsDB getContactsArrayInContactGroup:_groupHeader];
        [_contactsTV reloadData];
        
        if (!_contacts.count)
        {
            [_contactsDB removeContactGroup:_groupHeader];
            [self setGroupListFromDB];
            [_groupsTV reloadData];
            [self resetSelectedGroup];
        }
    }
    
    else
    {
        [_contactsDB removeContactGroup:_groups[indexPath.row]];
        [self setGroupListFromDB];
        [_groupsTV reloadData];
        [self resetSelectedGroup];
    }
}

- (void)tableView:(UITableView *)tableView
didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _groupsTV)
        [self resetSelectedGroup];
}

- (void)returnButtonTapped:(UIButton *)button
{
    [_delegate contactsViewerDidReturn:self];
}

- (void)sendButtonTapped:(UIButton *)button
{
    NSMutableArray *emails = NSMutableArray.array;
    
    for (NSIndexPath *path in _contactsTV.indexPathsForSelectedRows)
    {
        UITableViewCell *cell = [_contactsTV cellForRowAtIndexPath:path];
        [emails addObject:cell.detailTextLabel.text];
    }
    
    [_delegate contactsViewer:self didReturnEmails:emails.copy];
}

- (void)plusButtonTapped:(UIButton *)button
{
    _inAddMode = !_inAddMode;
    
    if (_inAddMode)
    {
        _plusButton.backgroundColor = UIColor.greenColor;
        _groupsTV.layer.borderColor = UIColor.greenColor.CGColor;
        _contactsTV.layer.borderColor = UIColor.greenColor.CGColor;
        [self deselectAllContacts];
        [self setGroupListFromDB];
        [_groupsTV reloadData];
    }
    
    else
    {
        _plusButton.backgroundColor = UIColor.clearColor;
        _groupsTV.layer.borderColor = UIColor.blackColor.CGColor;
        _contactsTV.layer.borderColor = UIColor.blackColor.CGColor;
        
        if (_groupsTV.indexPathForSelectedRow && _contactsTV.indexPathsForSelectedRows.count)
        {
            UITableViewCell *cell = [_groupsTV cellForRowAtIndexPath:_groupsTV.indexPathForSelectedRow];
            NSString *group = cell.textLabel.text.copy;
            
            if ([group isEqualToString:@"Create New Group"])
            {
                UITextField *textField = UITextField.new;
                textField.translatesAutoresizingMaskIntoConstraints = NO;
                textField.delegate = self;
                cell.textLabel.text = @"";
                cell.textLabel.textColor = UIColor.blackColor;
                cell.backgroundColor = UIColor.whiteColor;
                textField.font = cell.textLabel.font;
                textField.textColor = UIColor.blackColor;
                textField.textAlignment = NSTextAlignmentCenter;
                textField.backgroundColor = UIColor.clearColor;
                textField.placeholder = @"Enter Group Name";
                [cell.contentView addSubview:textField];
                [textField constrainToView:cell.contentView leading:0.0 trailing:0.0 top:0.0 bottom:0.0];
                [textField becomeFirstResponder];
            }
            
            else for (NSIndexPath *indexPath in _contactsTV.indexPathsForSelectedRows)
            {
                NVContact *contact = _contacts[indexPath.row];
                
                [_contactsDB addEmail:contact.email
                            firstName:contact.firstName
                             lastName:contact.lastName
                       toContactGroup:group];
                
                [self setGroupListFromDB];
                [_groupsTV reloadData];
                _contacts = [_contactsDB getContactsArrayInContactGroup:group];
                [_contactsTV reloadData];
                [self deselectAllContacts];
                NSInteger row = [_groups indexOfObject:group];
                
                [_groupsTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                                       animated:NO
                                 scrollPosition:UITableViewScrollPositionNone];
            }
        }
        
        else
        {
            [self deselectGroup];
            [self deselectAllContacts];
            [self setGroupListFromDB];
            [_groupsTV reloadData];
            
            NSInteger row = [_groups indexOfObject:_groupHeader];
            
            [_groupsTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                                   animated:NO
                             scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length)
    {
        for (NSIndexPath *indexPath in _contactsTV.indexPathsForSelectedRows)
        {
            NVContact *contact = _contacts[indexPath.row];
            
            [_contactsDB addEmail:contact.email
                        firstName:contact.firstName
                         lastName:contact.lastName
                   toContactGroup:textField.text];
        }
    }
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setGroupListFromDB];
    [_groupsTV reloadData];
    [self deselectAllContacts];
    
    if (textField.text.length)
    {
        _contacts = [_contactsDB getContactsArrayInContactGroup:textField.text];
        [_contactsTV reloadData];
        NSInteger row = [_groups indexOfObject:textField.text];
        
        [_groupsTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                               animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
    
    else
    {
        NSInteger row = [_groups indexOfObject:_groupHeader];
        
        [_groupsTV selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]
                               animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
    
    [textField removeFromSuperview];
}

- (void)deselectAllContacts
{
    for (int i = 0; i < [_contactsTV numberOfRowsInSection:0]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_contactsTV deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)selectAllContacts
{
    for (int i = 0; i < [_contactsTV numberOfRowsInSection:0]; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_contactsTV selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)deselectGroup
{
    [_groupsTV deselectRowAtIndexPath:_groupsTV.indexPathForSelectedRow animated:NO];
}

- (void)resetSelectedGroup
{
    [self deselectGroup];
    
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [_groupsTV selectRowAtIndexPath:index
                           animated:NO
                     scrollPosition:UITableViewScrollPositionNone];
    
    [self tableView:_groupsTV didSelectRowAtIndexPath:index];
    _groupHeader = @"System Contacts";
    _contacts = _systemContacts.copy;
    [_contactsTV reloadData];
}

- (void)setGroupListFromDB
{
    NSMutableArray *tempGroups = _contactsDB.getContactGroupsArray.mutableCopy;
    [tempGroups insertObject:@"System Contacts" atIndex:0];
    
    if (_inAddMode)
        [tempGroups addObject:@"Create New Group"];
    
    else
        [tempGroups removeObject:@"Create New Group"];
    
    _groups = tempGroups.copy;
}

- (void)helpButtonTapped:(UIButton *)button
{
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"Contacts"
                                                       ofType:@"pdf"];
    
    NVWebView *nvwv = [NVWebView showWebViewInView:self.view
                                    showFileAtPath:filePath
                                          delegate:nil];
#pragma unused(nvwv)
}

@end
