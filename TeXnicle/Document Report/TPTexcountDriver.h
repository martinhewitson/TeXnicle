//
//  TPTexcountDriver.h
//  TeXnicle
//
//  Created by Martin Hewitson on 18/2/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPTexcountDriver;

@protocol TexcountDriverDelegate <NSObject>

- (void)texcountRunFailed:(TPTexcountDriver*)texcount;
- (void)texcountRunDidFinish:(TPTexcountDriver*)texcount;
- (BOOL)texcountShouldGenerateWordFreq:(TPTexcountDriver*)texcount;
- (BOOL)texcountShouldGenerateStats:(TPTexcountDriver*)texcount;
- (BOOL)texcountShouldIncludeAllFiles:(TPTexcountDriver*)texcount;

@end

@interface TPTexcountDriver : NSObject <TexcountDriverDelegate> {
@private
	NSTask *texcountTask;
	NSFileHandle *outputHandle;
  NSFileHandle *inputHandle;
  NSPipe *outpipe;
  NSPipe *inpipe;
  BOOL _taskRunning;
}

@property (unsafe_unretained) id<TexcountDriverDelegate> delegate;
@property (copy) NSString *output;


- (id) initWithDelegate:(id<TexcountDriverDelegate>)aDelegate;
- (void) setupObservers;
- (void) countWordsInTexFile:(NSString*)someText;



@end
