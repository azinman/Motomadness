//
//  SmsManager.m
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.

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
    synth = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
    if (synth == nil) {
      NSLog(@"Could not create voice synthesizer");
    } else {
      NSLog(@"saying hello");
      [synth setVolume:1];
      [synth startSpeakingString:@"Hello there! Moto madness is on"];
    }
  }
  
  return self;
}

// MAIN LOOP ---------------------------------------------------------------------------------------
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
        NSString *spokenMessage = [text spokenMessage];
        NSLog(@"speaking %@", spokenMessage);
        if (synth == nil) {
          NSLog(@"Could not create voice synthesizer");
        } else {
          [synth startSpeakingString:spokenMessage];
        }
      }
    }
    [texts release];
  }
  [self performSelector:@selector(checkRoutine) withObject:nil afterDelay:3.0];
}
// END MAIN LOOP -----------------------------------------------------------------------------------
                      

- (NSDate *) getSmsDate {
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:@"/private/var/mobile/Library/SMS/sms.db" error:nil];
  return [[[attributes objectForKey:@"NSFileModificationDate"] retain] autorelease];
}

- (sqlite3 *) openDb {
  sqlite3 *db = NULL;
  int ret;
  if ((ret = sqlite3_open_v2("/private/var/mobile/Library/SMS/sms.db", &db, 
                       SQLITE_OPEN_READONLY, NULL)) != SQLITE_OK) {
    NSLog(@"Trouble opening sms db; error code %s", sqlite3_errmsg(db));
    return nil;
  };
  NSLog(@"opened db");
  return db;
}

- (int) getLastRowId {
  sqlite3 *db = [self openDb];
  if (db == nil) return -1;
  const char *sql = "select rowid from message order by rowid desc limit 1";
  sqlite3_stmt *compiledStatement = nil;
  if (sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL) != SQLITE_OK) {
    NSLog(@"Could not prepare sql statement for some reason: error %s for sql: %s", sqlite3_errmsg(db), sql);
    compiledStatement = nil;
    goto err;
  }
  if (sqlite3_step(compiledStatement) != SQLITE_ROW) {
    NSLog(@"Could not step through sqlite row for last row id: error %s", sqlite3_errmsg(db));
    goto err;
  }
  
  int rowId = sqlite3_column_int(compiledStatement, 0);
  sqlite3_finalize(compiledStatement);
  sqlite3_close(db);
  NSLog(@"latest row id is %d", rowId);
  return rowId;
  
err:
  if (compiledStatement != nil) sqlite3_finalize(compiledStatement);
  sqlite3_close(db);
  return -1;
}

- (NSMutableArray *) getLatestTexts {
  sqlite3 *db = [self openDb];
  const char *sql = "select rowid, address, text, flags, group_id from message where rowid > ? order by rowid";
  sqlite3_stmt *compiledStatement = nil;
  if (sqlite3_prepare_v2(db, sql, -1, &compiledStatement, NULL) != SQLITE_OK) {
    NSLog(@"Could not prepare sql statement for some reason: error %s for sql %s", sqlite3_errmsg(db), sql);
    compiledStatement = nil;
    goto err;
  }
  if (sqlite3_bind_int(compiledStatement, 1, lastRowId) != SQLITE_OK) {
    NSLog(@"Could not bind rowid %d for some reason: error %s", lastRowId, sqlite3_errmsg(db));
    goto err;
  }
  NSMutableArray *texts = [[NSMutableArray arrayWithCapacity:10] retain];
  
  while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
    lastRowId = sqlite3_column_int(compiledStatement, 0);
    const char *_number = sqlite3_column_text(compiledStatement, 1);
    NSString *number = [NSString stringWithCString:_number encoding:NSUTF8StringEncoding];
    const char *_message = sqlite3_column_text(compiledStatement, 2);
    NSString *message = [NSString stringWithCString:_message encoding:NSUTF8StringEncoding];
    int flags = sqlite3_column_int(compiledStatement, 3);
    int group_id = sqlite3_column_int(compiledStatement, 4);
    Text *text = [[[Text alloc] initWithPhoneNumber:number message:message] autorelease];
    NSLog(@"Created text: %@", text);
    [texts addObject:text];
  }
  
  sqlite3_finalize(compiledStatement);
  sqlite3_close(db);
  return [texts autorelease];
  
err:
  if (compiledStatement != nil) sqlite3_finalize(compiledStatement);
  sqlite3_close(db);
  return nil;
}

- (void)dealloc
{
  [super dealloc];
}

@end
