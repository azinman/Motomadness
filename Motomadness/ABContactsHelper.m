/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ABContactsHelper.h"

static NSMutableDictionary *contactsByScrubbedPhone = nil;

@implementation ABContactsHelper
/*
 Note: You cannot CFRelease the addressbook after ABAddressBookCreate();
 */
+ (ABAddressBookRef) addressBook
{
	return ABAddressBookCreate();
}

+ (NSArray *) contacts
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *thePeople = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:thePeople.count];
	for (id person in thePeople)
		[array addObject:[ABContact contactWithRecord:(ABRecordRef)person]];
	[thePeople release];
	return array;
}

+ (int) contactsCount
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	return ABAddressBookGetPersonCount(addressBook);
}

+ (int) contactsWithImageCount
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *peopleArray = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	int ncount = 0;
	for (id person in peopleArray) if (ABPersonHasImageData(person)) ncount++;
	[peopleArray release];
	return ncount;
}

+ (int) contactsWithoutImageCount
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *peopleArray = (NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
	int ncount = 0;
	for (id person in peopleArray) if (!ABPersonHasImageData(person)) ncount++;
	[peopleArray release];
	return ncount;
}

// Groups
+ (int) numberOfGroups
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *groups = (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook);
	int ncount = groups.count;
	[groups release];
	return ncount;
}

+ (NSArray *) groups
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *groups = (NSArray *)ABAddressBookCopyArrayOfAllGroups(addressBook);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:groups.count];
	for (id group in groups)
		[array addObject:[ABGroup groupWithRecord:(ABRecordRef)group]];
	[groups release];
	return array;
}

// Sorting
+ (BOOL) firstNameSorting
{
	return (ABPersonGetCompositeNameFormat() == kABPersonCompositeNameFormatFirstNameFirst);
}

#pragma mark Contact Management

// Thanks to Eridius for suggestions re: error
+ (BOOL) addContact: (ABContact *) aContact withError: (NSError **) error
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	if (!ABAddressBookAddRecord(addressBook, aContact.record, (CFErrorRef *) error)) return NO;
	return ABAddressBookSave(addressBook, (CFErrorRef *) error);
}

+ (BOOL) addGroup: (ABGroup *) aGroup withError: (NSError **) error
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	if (!ABAddressBookAddRecord(addressBook, aGroup.record, (CFErrorRef *) error)) return NO;
	return ABAddressBookSave(addressBook, (CFErrorRef *) error);
}

+ (NSArray *) contactsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	return [contacts filteredArrayUsingPredicate:pred];
}

+ (NSArray *) contactsMatchingName: (NSString *) fname andName: (NSString *) lname
{
	NSPredicate *pred;
	NSArray *contacts = [ABContactsHelper contacts];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", fname, fname, fname, fname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	pred = [NSPredicate predicateWithFormat:@"firstname contains[cd] %@ OR lastname contains[cd] %@ OR nickname contains[cd] %@ OR middlename contains[cd] %@", lname, lname, lname, lname];
	contacts = [contacts filteredArrayUsingPredicate:pred];
	return contacts;
}

+ (NSString *) scrubPhoneNumber:(NSString *) number {
  NSString *digits = [[[[[number stringByReplacingOccurrencesOfString:@" " withString:@""]
                                 stringByReplacingOccurrencesOfString:@"(" withString:@""] 
                                 stringByReplacingOccurrencesOfString:@")" withString:@""] 
                                 stringByReplacingOccurrencesOfString:@"+" withString:@""] 
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""];
  if ([digits hasPrefix:@"1"]) {
    return [digits substringFromIndex:1];
  } else {
    return digits;
  }
} 

+ (NSDictionary *) contactsByPhoneDictionary {
  if (contactsByScrubbedPhone == nil) {
    NSArray *contacts = [ABContactsHelper contacts];
    contactsByScrubbedPhone = [[NSMutableDictionary dictionaryWithCapacity:[contacts count]] retain];
    for (ABContact *contact in contacts) {
      for (NSString *contactNumber in contact.phoneArray) {
        if ([contactNumber length] < 5) continue;
        NSString *scrubbedNumber = [ABContactsHelper scrubPhoneNumber:contactNumber];
        [contactsByScrubbedPhone setObject:contact forKey:scrubbedNumber];
      }
    }
  }
  return contactsByScrubbedPhone;
}

+ (ABContact *) contactMatchingPhone: (NSString *) number
{
  NSString *scrubbedNumber = [ABContactsHelper scrubPhoneNumber:number];
  return [[ABContactsHelper contactsByPhoneDictionary] objectForKey:scrubbedNumber];
}

+ (NSArray *) groupsMatchingName: (NSString *) fname
{
	NSPredicate *pred;
	NSArray *groups = [ABContactsHelper groups];
	pred = [NSPredicate predicateWithFormat:@"name contains[cd] %@ ", fname];
	return [groups filteredArrayUsingPredicate:pred];
}
@end