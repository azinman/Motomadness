//
//  SmsManager.m
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import "SmsManager.h"
#import "Text.h"

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
    lastRowId = [self getLastRowId];
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
    NSMutableArray *texts = [[self getLatestTexts] retain];
    if (texts == nil) {
      NSLog(@"could not get texts.. ignoring");
    } else {
      for (Text *text in texts) {
        NSLog(@"speaking %@", text);
        [text speak];
      }
    }
    [texts release];
  }
  [self performSelector:@selector(checkRoutine) withObject:nil afterDelay:3.0];
}
                      

- (NSDate *) getSmsDate {
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:@"/private/var/mobile/Library/SMS/sms.db" error:nil];
  return [[[attributes objectForKey:@"NSFileModificationDate"] retain] autorelease];
}

- (sqlite3 *) openDb {
  sqlite3 *db = NULL;
  if (!sqlite3_open_v2("/private/var/mobile/Library/SMS/sms.db", &db, 
                       SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX, NULL)) {
    NSLog(@"Trouble opening sms db");
    return nil;
  };
  return db;
}

- (int) getLastRowId {
  sqlite3 *db = [self openDb];
  if (db == nil) return -1;
  const char *sql = "select rowid from message order by rowid desc limit 1";
  sqlite3_stmt *compiledStatement;
  int ret;
  if ((ret = sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL)) != SQLITE_OK) {
    NSLog(@"Could not prepare sql statement for some reason: error %d for sql %s", ret, sql);
    goto err;
  }
  if ((ret = sqlite3_step(compiledStatement)) != SQLITE_ROW) {
    NSLog(@"Could not step through sqlite row for last row id: error %d", ret);
    goto err;
  }
  
  int rowId = sqlite3_column_int(compiledStatement, 1);
  sqlite3_close(db);
  return rowId;
  
err:
  sqlite3_close(db);
  return -1;
}

- (NSMutableArray *) getLatestTexts {
  sqlite3 *db = [self openDb];
  const char *sql = "select rowid, address, text, flags, group_id from message where rowid > ? order by rowid";
  sqlite3_stmt *compiledStatement;
  int ret;
  if ((ret = sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL)) != SQLITE_OK) {
    NSLog(@"Could not prepare sql statement for some reason: error %d for sql %s", ret, sql);
    goto err;
  }
  if ((ret = sqlite3_bind_int(compiledStatement, 1, lastRowId)) != SQLITE_OK) {
    NSLog(@"Could not bind rowid %d for some reason: error %d", lastRowId, ret);
    goto err;
  }
  NSMutableArray *texts = [[NSMutableArray arrayWithCapacity:10] retain];
  
  while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
    lastRowId = sqlite3_column_int(compiledStatement, 1);
    const char *_number = sqlite3_column_text(compiledStatement, 2);
    NSString *number = [NSString stringWithCString:_number encoding:NSUTF8StringEncoding];
    const char *_message = sqlite3_column_text(compiledStatement, 3);
    NSString *message = [NSString stringWithCString:_message encoding:NSUTF8StringEncoding];
    int flags = sqlite3_column_int(compiledStatement, 4);
    int group_id = sqlite3_column_int(compiledStatement, 5);
    Text *text = [[[Text alloc] initWithPhoneNumber:number message:message] autorelease];
    NSLog(@"Created text: %@", text);
    [texts addObject:text];
  }
  
  sqlite3_close(db);
  return [texts autorelease];
  
err:
  sqlite3_close(db);
  return nil;
}


- (void)dealloc
{
    [super dealloc];
}

@end
