  //
  //  UpLoadPictureViewController.m
  //  docImageApp
  //
  //  Created by 侯建政 on 8/6/14.
  //  Copyright (c) 2014 jianzheng. All rights reserved.
  //

#import "THContactPickerViewController.h"
#import <AddressBook/AddressBook.h>
#import "THContact.h"
#import "AIMTableViewIndexBar.h"
#import "pinyin.h"

@interface THContactPickerViewController ()<UITextFieldDelegate,AIMTableViewIndexBarDelegate>
{
  __weak IBOutlet AIMTableViewIndexBar    *indexBar;
  __weak IBOutlet UITableView             *plainTableView;
  NSArray *sections;
  NSMutableArray *allDataArr;
}
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) UIBarButtonItem *rightbarButton;
@property (nonatomic, strong) UIBarButtonItem *leftbarButton;
@property (nonatomic, strong) UITextField *tf;
@property (nonatomic, strong) NSMutableArray *contactFristNameArray;
@property (nonatomic, strong) NSMutableArray *allDataArr;
@end

//#define kKeyboardHeight 216.0
#define kKeyboardHeight 0.0

@implementation THContactPickerViewController
@synthesize rightbarButton,leftbarButton;
@synthesize tf;
@synthesize contactFristNameArray,allDataArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Select Contacts (0)";
        
        CFErrorRef error;
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    }
    return self;
}
- (void)dissView
{
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)viewDidLoad
{
  [super viewDidLoad];
    //indexBar.delegate = self;
  allDataArr = [[NSMutableArray alloc] init];
  contactFristNameArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    //    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(removeAllContacts:)];
  self.view.backgroundColor = [UIColor whiteColor];
  rightbarButton = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
  rightbarButton.enabled = FALSE;
  
  leftbarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dissView)];
  
  self.navigationItem.rightBarButtonItem = rightbarButton;
  self.navigationItem.leftBarButtonItem = leftbarButton;
  
  self.navigationItem.title = @"Share";
  
  UILabel *lbl = [[UILabel alloc] init];
  lbl.frame = CGRectMake(5, NavgationHeight+5, 30, 20);
  lbl.backgroundColor = [UIColor whiteColor];
  lbl.textColor = [UIColor grayColor];
  lbl.text = @"To:";
  
  tf = [[UITextField alloc] initWithFrame:CGRectMake(30, NavgationHeight+5, 280, 20)];
  tf.font = [UIFont systemFontOfSize:17.0];
  tf.backgroundColor = [UIColor whiteColor];
  tf.delegate = self;
  tf.adjustsFontSizeToFitWidth = YES;
  tf.borderStyle = UITextBorderStyleNone;
    //[tf addTarget:self action:@selector(updateLabel:) forControlEvents:UIControlEventEditingChanged];
  [self.view addSubview:lbl];
  [self.view addSubview:tf];
  
    // Fill the rest of the view with the table view
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavgationHeight+30, self.view.frame.size.width, self.view.frame.size.height-30 - kKeyboardHeight-NavgationHeight) style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  
  [self.tableView registerNib:[UINib nibWithNibName:@"THContactPickerTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
  
  [self.view addSubview:self.tableView];
  
  ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
    if (granted) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self getContactsFromAddressBook];
      });
    } else {
        // TODO: Show alert
    }
  });
}
-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableArray alloc]init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [[NSMutableArray alloc] init];
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
          
            // Get email
          ABMultiValueRef emailRef = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
          contact.emailArr = [self getEmailProperty:emailRef];
          if(emailRef) {
            CFRelease(emailRef);
          }
          if (contact.emailArr.count == 0) {
            continue;
          }else if(contact.emailArr.count > 1)
          {
            for (int i = 0; i< contact.emailArr.count; i++) {
              THContact *conttemp = [[THContact alloc] init];
              
              conttemp.email = [contact.emailArr objectAtIndex:i];
              
              conttemp.recordId = ABRecordGetRecordID(contactPerson);
              
                // Get first and last names
              NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
              NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
              
                // Set Contact properties
              conttemp.firstName = firstName;
              conttemp.lastName = lastName;
              
              
              
                //            // Get mobile number
                //            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                //            contact.phone = [self getMobilePhoneProperty:phonesRef];
                //            if(phonesRef) {
                //                CFRelease(phonesRef);
                //            }
              
                // Get image if it exists
              NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
              conttemp.image = [UIImage imageWithData:imgData];
              if (!conttemp.image) {
                conttemp.image = [UIImage imageNamed:@"icon-avatar-60x60"];
              }
              [mutableContacts addObject:conttemp];
            }
            
          }else
          {
            contact.email = [contact.emailArr objectAtIndex:0];
            
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
              // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
              // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            
            
              //            // Get mobile number
              //            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
              //            contact.phone = [self getMobilePhoneProperty:phonesRef];
              //            if(phonesRef) {
              //                CFRelease(phonesRef);
              //            }
            
              // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
              contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
            }
            [mutableContacts addObject:contact];
          }
          
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        self.contacts = [NSArray arrayWithArray:mutableContacts];
        self.selectedContacts = [NSMutableArray array];
        [self creatAdressData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}

- (void) refreshContacts
{
    for (THContact* contact in self.contacts)
    {
        [self refreshContact: contact];
    }
    [self.tableView reloadData];
}

- (void) refreshContact:(THContact*)contact
{
    
    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
    contact.recordId = ABRecordGetRecordID(contactPerson);
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    // Set Contact properties
    contact.firstName = firstName;
    contact.lastName = lastName;
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    contact.phone = [self getMobilePhoneProperty:phonesRef];
    if(phonesRef) {
        CFRelease(phonesRef);
    }
    
    // Get image if it exists
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
    contact.image = [UIImage imageWithData:imgData];
    if (!contact.image) {
        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
    }
}
- (NSMutableArray *)getEmailProperty:(ABMultiValueRef)emailRef
{
  NSMutableArray *arr = [[NSMutableArray alloc] init];
  for (int i=0; i < ABMultiValueGetCount(emailRef); i++) {
    CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(emailRef, i);
    
    if(currentPhoneValue) {
      [arr addObject:(__bridge NSString *)currentPhoneValue];
    }
    
    if(currentPhoneValue) {
      CFRelease(currentPhoneValue);
    }
  }
  return arr;
}
- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContacts];
    });
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        topOffset = self.topLayoutGuide.length;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Delegate and Datasource functions
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
  if (self.allDataArr.count > 0) {
    NSMutableArray *indices = [[NSMutableArray alloc] init];
		for (int i = 0; i < 27; i++)
			if ([[self.allDataArr objectAtIndex:i] count])
				[indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
      //[indices addObject:@"\ue057"]; // <-- using emoji
		return indices;
  }else
    return nil;
  
}
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
			if ([[self.allDataArr objectAtIndex:section] count] == 0) return nil;
		return [NSString stringWithFormat:@"%@", [[ALPHA substringFromIndex:section] substringToIndex:1]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (self.allDataArr.count > 0) {
    return 27;
  }else
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.allDataArr.count > 0) {
    return [[self.allDataArr objectAtIndex:section] count];
  }else
    return 0;
}

- (CGFloat)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the desired contact from the filteredContacts array
    THContact *contact = [[self.allDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    // Initialize the table view cell
    NSString *cellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Get the UI elements in the cell;
    UILabel *contactNameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *mobilePhoneNumberLabel = (UILabel *)[cell viewWithTag:102];
    UIImageView *contactImage = (UIImageView *)[cell viewWithTag:103];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    
    // Assign values to to US elements
    contactNameLabel.text = [contact fullName];
    mobilePhoneNumberLabel.text = contact.email;
    if(contact.image) {
        contactImage.image = contact.image;
    }
    contactImage.layer.masksToBounds = YES;
    contactImage.layer.cornerRadius = 20;
    
    // Set the checked state for the contact selection checkbox
    UIImage *image;
    if ([self.selectedContacts containsObject:[[self.allDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]]){
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    } else {
        //cell.accessoryType = UITableViewCellAccessoryNone;
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    }
    checkboxImageView.image = image;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Hide Keyboard
  
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if (self.allDataArr.count == 0) {
    return;
  }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // This uses the custom cellView
    // Set the custom imageView
    THContact *user = [[self.allDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    
    if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
        //cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedContacts removeObject:user];
        // Set checkbox to "unselected"
        image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    } else {
        [self.selectedContacts addObject:user];
        image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
    }
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        rightbarButton.enabled = TRUE;
    }
    else
    {
        rightbarButton.enabled = FALSE;
    }
    
    // Update window title
    self.title = [NSString stringWithFormat:@"添加 (%lu)", (unsigned long)self.selectedContacts.count];
    
    // Set checkbox image
    checkboxImageView.image = image;
      // Refresh the tableview
    [self.tableView reloadData];
}

#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", @"firstName", textViewText, @"lastName", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}
- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    
    NSUInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        rightbarButton.enabled = TRUE;
    }
    else
    {
        rightbarButton.enabled = FALSE;
    }
    
    // Set unchecked image
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    checkboxImageView.image = image;
    
    // Update window title
     self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
}

- (void)removeAllContacts:(id)sender
{
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.tableView reloadData];
}
#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}

-(void)creatAdressData{
	[contactFristNameArray removeAllObjects];
  for (int i = 0; i < 27; i++)
    [self.allDataArr addObject:[NSMutableArray array]];
	for(THContact *contact in self.contacts)
	{
     NSString *sectionName;
    NSString *name;
    NSUInteger firstLetter = 0;
      if([contact.firstName length] > 0)
      {
			sectionName = contact.firstName;
      }
		else if([contact.lastName length] > 0)
    {
			sectionName = contact.lastName;
    }else
    {
      firstLetter = 26;
    }
    
    if (sectionName.length > 0) {
      name = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([sectionName characterAtIndex:0])] uppercaseString];
        //[self.contactNameDic setObject:string forKey:sectionName];
      firstLetter = [ALPHA rangeOfString:[name substringToIndex:1]].location;
    }
		if (firstLetter != NSNotFound)
      [[self.allDataArr objectAtIndex:firstLetter] addObject:contact];
	}
  [self.tableView reloadData];
}

// This opens the apple contact details view: ABPersonViewController
//TODO: make a THContactPickerDetailViewController
- (IBAction)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);

    
    [self.navigationController pushViewController:view animated:YES];
}

// TODO: send contact object
- (void)done:(id)sender
{
  NSLog(@"%@",self.selectedContacts);
  NSMutableArray *mutArr = [[NSMutableArray alloc] init];
  for (THContact* contact in self.selectedContacts)
  {
    if (contact.email.length > 0) {
      [mutArr addObject:contact.email];
    }
  }
  [self.delegate selectEmailValue:mutArr];
  [self dissView];
  
}
#pragma mark - AIMTableViewIndexBarDelegate

- (void)tableViewIndexBar:(AIMTableViewIndexBar *)indexBar didSelectSectionAtIndex:(NSInteger)index{
  if ([plainTableView numberOfSections] > index && index > -1){   // for safety, should always be YES
    [plainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
  }
}


@end
