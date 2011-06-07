//
//  Text.m
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import "Text.h"

@implementation Text

@synthesize phoneNumber, authorName, message;

- (id)initWithPhoneNumber:(NSString *)number message:(NSString *)_message;
{
    self = [super init];
    if (self) {
      self.phoneNumber = number;
      self.message = _message;
      self.authorName = [self lookupPhoneNumber:number];
      synth = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
      if (synth == nil) {
        NSLog(@"Could not create voice synthesizer");
      } else {
        [synth startSpeakingString:@"Hello there! Motomadness is on"];
      }
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
  if ([number length] < 5) {
    return @"Shortcode";
  }
  NSLog(@"not a shortcode");
  
  if ([number hasPrefix:@"+"]) {
    NSString *areaCode = [number substringWithRange:NSMakeRange(1, 3)];
    return [NSString stringWithFormat:@"Unknown from %@ area code", areaCode];
  }
  
  NSString *areaCode = [number substringWithRange:NSMakeRange(0, 3)];
  return [NSString stringWithFormat:@"Unknown from %@ area code", areaCode];
}

- (void) speak {
  if (synth == nil) {
    NSLog(@"Could not create voice synthesizer");
    return;
  }
  NSString *spokenMessage = [NSString stringWithFormat:@"From %@. %@", self.authorName, self.message];
  NSLog(@"spoken message: %@", spokenMessage);
  [synth startSpeakingString:spokenMessage];
}

- (NSString *) description {
  return [NSString stringWithFormat:@"[Text, number=%@, message=%@, authorName=%@", phoneNumber, message, authorName];
}

@end
