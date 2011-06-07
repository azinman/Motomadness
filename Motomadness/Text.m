//
//  Text.m
//  Motomadness

#import "Text.h"
#import "ABContactsHelper.h"
#import "ABContact.h"

@implementation Text

@synthesize phoneNumber, authorName, message;

- (id)initWithPhoneNumber:(NSString *)number message:(NSString *)_message;
{
    self = [super init];
    if (self) {
      self.phoneNumber = number;
      self.message = _message;
      self.authorName = [self lookupPhoneNumber:number];
    }
    
    return self;
}

- (void)dealloc {
  self.phoneNumber = nil;
  self.message = nil;
  self.authorName = nil;
  [super dealloc];
}

- (NSString *) lookupPhoneNumber:(NSString *) number {
  if ([number length] < 7) {
    return @"Shortcode";
  }
  NSLog(@"not a shortcode");


  NSString *usNumber = nil;  
  BOOL isForeign = NO;
  if ([number hasPrefix:@"+1"]) {
    usNumber = [number substringFromIndex:2];
  } else if ([number hasPrefix:@"1"]) {
    usNumber = [number substringFromIndex:1];
  } else {
    isForeign = YES;
  }

  ABContact *contact = [ABContactsHelper contactMatchingPhone:isForeign ? number : usNumber];
  if (contact == nil) {
    NSLog(@"No found matching contacts with number: %@", isForeign ? number : usNumber);
    // NSLog(@"contacts db: %@", [ABContactsHelper contacts]);

    if (isForeign) {
      return @"An unknown foreign number";
    } else {
      NSString *areaCode = [usNumber substringWithRange:NSMakeRange(0, 3)];
      return [NSString stringWithFormat:@"An unknown number in the %c %c %c area code",
              [areaCode characterAtIndex:0],
              [areaCode characterAtIndex:1],
              [areaCode characterAtIndex:2]];
    }
  }
  
  NSLog(@"Found matching contact: %@", contact);
  return [contact compositeName];
}

- (NSString *) spokenMessage {
  return [NSString stringWithFormat:@"From %@. %@", self.authorName, self.message];
}

- (NSString *) description {
  return [NSString stringWithFormat:@"[Text, number=%@, message=%@, authorName=%@", phoneNumber, message, authorName];
}

@end
