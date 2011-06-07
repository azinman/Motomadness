//
//  Text.h
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface Text : NSObject {
  NSString *phoneNumber;
  NSString *authorName;
  NSString *message;
  VSSpeechSynthesizer *synth;
}

- (id) initWithPhoneNumber:(NSString *)number message:(NSString *)message;

- (NSString *) lookupPhoneNumber:(NSString *) number;
- (void) speak;

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *message;

@end
