//
//  TPSyntaxChecker.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TPSyntaxChecker;

@protocol SyntaxCheckerDelegate <NSObject>

- (void)syntaxCheckerCheckFailed:(TPSyntaxChecker*)checker;
- (void)syntaxCheckerCheckDidFinish:(TPSyntaxChecker*)checker;

@end

@interface TPSyntaxChecker : NSObject <SyntaxCheckerDelegate> {
@private
	NSTask *lacheckTask;
	NSFileHandle *lacheckFileHandle;
  
  NSString *output;
  NSArray *errors;
  id<SyntaxCheckerDelegate> delegate;
  
  BOOL _taskRunning;
}

@property (assign) id<SyntaxCheckerDelegate> delegate;
@property (copy) NSString *output;
@property (retain) NSArray *errors;

+ (NSArray*) defaultSyntaxErrors;

- (id) initWithDelegate:(id<SyntaxCheckerDelegate>)aDelegate;
- (void) setupObservers;
- (void) checkSyntaxOfFileAtPath:(NSString*)aPath;
- (void) createErrors;
- (NSArray*)argumentsForActiveErrors;

@end
