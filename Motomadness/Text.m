//
//  Text.m
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import "Text.h"

@interface VSSpeechSynthesizer
  - (void) startSpeakingString:(NSString *)str;
@end

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
  [super dealloc];
  self.phoneNumber = nil;
  self.authorName = nil;
  self.message = nil;
}

- (NSString *) lookupPhoneNumber:(NSString *) number {
  if ([number length] > 5) {
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
  VSSpeechSynthesizer *synth = [[NSClassFromString(@"VSSpeechSynthesizer") new]autorelease];
  [synth startSpeakingString:[NSString stringWithFormat:@"From %@. %@", self.authorName, self.message]];
}

- (NSString *) description {
  return [NSString stringWithFormat:@"[Text, number=%@, message=%@, authorName=%@", phoneNumber, message, authorName];
}

@end
