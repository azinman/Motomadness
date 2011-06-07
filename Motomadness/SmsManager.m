//
//  SmsManager.m
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import "SmsManager.h"

static SmsManager *sharedSingleton;

@implementation SmsManager

@synthesize lastDate;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[SmsManager alloc] init];
    }
}

+ (SmsManager *) sharedInstance {
    return sharedSingleton;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.lastDate = [self getSmsDate];
        [self checkRoutine];
    }
    
    return self;
}

- (void) checkRoutine {
    NSLog(@"checking...");
    NSDate *newDate = [self getSmsDate];
    if ([newDate isEqualToDate:lastDate]) {
        NSLog(@"nothing.");
    } else {
        NSLog(@"NEW TEXT!!!!!!!!!!!!!!!!!!!!!!!!");
        self.lastDate = newDate;
    }
    [self performSelector:@selector(checkRoutine) withObject:nil afterDelay:3.0];
}
                      

- (NSDate *) getSmsDate {
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:@"/private/var/mobile/Library/SMS/sms.db" error:nil];
  return [[[attributes objectForKey:@"NSFileModificationDate"] retain] autorelease];
}


- (void)dealloc
{
    [super dealloc];
}

@end
