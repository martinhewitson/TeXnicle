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

extern NSString * const TPTeXLogViewDidSelectItemNotification;

@class TPTeXLogViewController;

@protocol TPTeXLogViewDelegate <NSObject>

@optional
- (BOOL)texlogview:(TPTeXLogViewController*)logview shouldShowEntriesForFile:(NSString*)aFile;
- (void)texlogview:(TPTeXLogViewController*)logview didSelectLogItem:(TPLogItem*)aLog;

@end

@interface TPTeXLogViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate, TPTeXLogViewDelegate>

@property (assign) id<TPTeXLogViewDelegate> delegate;
@property (nonatomic, strong) TPParsedLog *log;

- (id) initWithParsedLog:(TPParsedLog*)log;
- (id) initWithParsedLog:(TPParsedLog*)log delegate:(id<TPTeXLogViewDelegate>)aDelegate;

- (void) reload;

@end
