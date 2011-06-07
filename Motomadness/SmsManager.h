//
//  SmsManager.h
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SmsManager : NSObject {
@private
  NSDate *lastDate;
  int lastRowId;
}

+ (SmsManager *) sharedInstance;
- (NSDate *) getSmsDate;
- (void) checkRoutine;
- (sqlite3 *) openDb;
- (int) getLastRowId;
- (NSMutableArray *) getLatestTexts;

@property (nonatomic, retain) NSDate *lastDate;

@end
