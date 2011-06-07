//
//  SmsManager.h
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SmsManager : NSObject {
@private
    NSDate *lastDate;
}

+ (SmsManager *) sharedInstance;
- (NSDate *) getSmsDate;
- (void) checkRoutine;

@property (nonatomic, retain) NSDate *lastDate;

@end
