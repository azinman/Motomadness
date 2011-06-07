//
//  MotomadnessAppDelegate.h
//  Motomadness
//
//  Created by Aaron Zinman on 6/6/11.
//  Copyright 2011 MIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MotomadnessViewController;

@interface MotomadnessAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet MotomadnessViewController *viewController;

@end
