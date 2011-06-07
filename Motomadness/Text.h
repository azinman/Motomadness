//
//  Text.h
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Text : NSObject {
  NSString *phoneNumber;
  NSString *authorName;
  NSString *message;
}

- (id) initWithPhoneNumber:(NSString *)number message:(NSString *)message;

- (NSString *) lookupPhoneNumber:(NSString *) number;
- (void) speak;

@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *authorName;
@property (nonatomic, retain) NSString *message;


@end
