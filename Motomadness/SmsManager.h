//
//  SmsManager.h
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface VSSpeechSynthesizer : NSObject 
+ (id)availableLanguageCodes; 
+ (BOOL)isSystemSpeaking; 
- (id)startSpeakingString:(id)string; 
- (id)startSpeakingString:(id)string toURL:(id)url; 
- (id)startSpeakingString:(id)string toURL:(id)url withLanguageCode:(id)code; 
- (float)rate;             // default rate: 1 
- (id)setRate:(float)rate; 
- (float)pitch;           // default pitch: 0.5
- (id)setPitch:(float)pitch; 
- (float)volume;       // default volume: 0.8
- (id)setVolume:(float)volume; 
@end

@interface SmsManager : NSObject {
@private
  NSDate *lastDate;
  int lastRowId;
  VSSpeechSynthesizer *synth;
}

+ (SmsManager *) sharedInstance;
- (NSDate *) getSmsDate;
- (void) checkRoutine;
- (sqlite3 *) openDb;
- (int) getLastRowId;
- (NSMutableArray *) getLatestTexts;

@property (nonatomic, retain) NSDate *lastDate;

@end
