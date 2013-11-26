//
//  TPTeXLogViewController.h
//  TestLogParser
//
//  Created by Martin Hewitson on 24/6/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPLogItem.h"
#import "TPParsedLog.h"
#import "TPTeXLogViewController.h"
#import "HHValidatedButton.h"

extern NSString * const TPTeXLogViewDidSelectItemNotification;

@class TPTeXLogViewController;

@protocol TPTeXLogViewDelegate <NSObject>

@optional
- (BOOL)texlogview:(TPTeXLogViewController*)logview shouldShowEntriesForFile:(NSString*)aFile;
- (void)texlogview:(TPTeXLogViewController*)logview didSelectLogItem:(TPLogItem*)aLog;
- (void)shouldShowInfoItems:(BOOL)state;
- (void)shouldShowWarningItems:(BOOL)state;
- (void)shouldShowErrorItems:(BOOL)state;

@end

@interface TPTeXLogViewController : NSViewController <NSUserInterfaceValidations, NSOutlineViewDataSource, NSOutlineViewDelegate, TPTeXLogViewDelegate>

@property (assign) id<TPTeXLogViewDelegate> delegate;
@property (nonatomic, strong) TPParsedLog *log;

- (id) initWithParsedLog:(TPParsedLog*)log;
- (id) initWithParsedLog:(TPParsedLog*)log delegate:(id<TPTeXLogViewDelegate>)aDelegate;

- (void) reload;

- (void) showLogInfoItems:(BOOL)state;
- (void) showLogWarningItems:(BOOL)state;
- (void) showLogErrorItems:(BOOL)state;

@end
