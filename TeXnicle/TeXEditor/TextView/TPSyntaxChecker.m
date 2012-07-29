//
//  TPSyntaxChecker.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPSyntaxChecker.h"
#import "TPSyntaxError.h"
#import "externs.h"

@interface TPSyntaxChecker ()

@end

@implementation TPSyntaxChecker


+ (NSArray*) defaultSyntaxErrors
{
  NSMutableArray *errors = [NSMutableArray array];
  
  NSMutableDictionary *error;
  
  // Warning 1
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@1 forKey:@"code"];
  [error setValue:@"Command terminated with space" forKey:@"message"];
  [errors addObject:error];
  
  // Warning 2
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@2 forKey:@"code"];
  [error setValue:@"Non-breaking space ('~') should have been used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 3
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@3 forKey:@"code"];
  [error setValue:@"You should enclose the previous parenthesis with '{}'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 4
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@4 forKey:@"code"];
  [error setValue:@"Italic correction ('\\/') found in non-italic buffer." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 5
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@5 forKey:@"code"];
  [error setValue:@"Italic correction ('\\/') found more than once." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 6
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@6 forKey:@"code"];
  [error setValue:@"No italic correction ('\\/') found." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 7
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@7 forKey:@"code"];
  [error setValue:@"Accent command 'command' needs use of 'command'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 8
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@8 forKey:@"code"];
  [error setValue:@"Wrong length of dash may have been used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 9
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@9 forKey:@"code"];
  [error setValue:@"'X' expected, found 'Y'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 10
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@10 forKey:@"code"];
  [error setValue:@"Solo 'X' found." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 11
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@11 forKey:@"code"];
  [error setValue:@"You should use '\\ldots' or '\\cdots' to achieve an ellipsis." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 12
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@12 forKey:@"code"];
  [error setValue:@"Interword spacing (‘\\ ’) should perhaps be used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 13
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@13 forKey:@"code"];
  [error setValue:@"Intersentence spacing ('\\@') should perhaps be used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 14
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@14 forKey:@"code"];
  [error setValue:@"Could not find argument for command." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 15
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@15 forKey:@"code"];
  [error setValue:@"No match found for 'X'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 16
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@16 forKey:@"code"];
  [error setValue:@"Mathmode still on at end of LaTeX file." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 17
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@17 forKey:@"code"];
  [error setValue:@"Number of open brackets doesn’t match the number of closing brackets." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 18
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@18 forKey:@"code"];
  [error setValue:@"You should use either `` or '' as an alternative to \"." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 19
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@19 forKey:@"code"];
  [error setValue:@"You should use \"’\" (ASCII 39) instead of \"’\" (ASCII 180)." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 20
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@20 forKey:@"code"];
  [error setValue:@"User-specified pattern found." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 21
  error = [NSMutableDictionary dictionary];
  [error setValue:@NO forKey:@"check"];
  [error setValue:@21 forKey:@"code"];
  [error setValue:@"This command might not be intended." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 22
  error = [NSMutableDictionary dictionary];
  [error setValue:@NO forKey:@"check"];
  [error setValue:@22 forKey:@"code"];
  [error setValue:@"Comment displayed." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 23
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@23 forKey:@"code"];
  [error setValue:@"Either ’’\\,’ or ’\\,’’ will look better." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 24
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@24 forKey:@"code"];
  [error setValue:@"Delete this space to maintain correct pagereferences." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 25
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@25 forKey:@"code"];
  [error setValue:@"You might wish to put this between a pair of ‘{}’." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 26
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@26 forKey:@"code"];
  [error setValue:@"You ought to remove spaces in front of punctuation." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 27
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@27 forKey:@"code"];
  [error setValue:@"Could not execute LaTeX command." forKey:@"message"];
  [errors addObject:error];   

  // Warning 28
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@28 forKey:@"code"];
  [error setValue:@"Don’t use \\/ in front of small punctuation." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 29
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@29 forKey:@"code"];
  [error setValue:@"$\times$ may look prettier here." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 30
  error = [NSMutableDictionary dictionary];
  [error setValue:@NO forKey:@"check"];
  [error setValue:@30 forKey:@"code"];
  [error setValue:@"Multiple spaces detected in output." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 31
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@31 forKey:@"code"];
  [error setValue:@"This text may be ignored." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 32
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@32 forKey:@"code"];
  [error setValue:@"Use ‘ to begin quotation, not ’." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 33
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@33 forKey:@"code"];
  [error setValue:@"Use ’ to end quotation, not ‘." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 34
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@34 forKey:@"code"];
  [error setValue:@"Don’t mix quotes." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 35
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@35 forKey:@"code"];
  [error setValue:@"You should perhaps use ‘cmd’ instead." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 36
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@36 forKey:@"code"];
  [error setValue:@"You should put a space in front of/after parenthesis." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 37
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@37 forKey:@"code"];
  [error setValue:@"You should avoid spaces in front of/after parenthesis." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 38
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@38 forKey:@"code"];
  [error setValue:@"You should not use punctuation in front of/after quotes." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 39
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@39 forKey:@"code"];
  [error setValue:@"Double space found." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 40
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@40 forKey:@"code"];
  [error setValue:@"You should put punctuation outside inner/inside display math mode." forKey:@"message"];
  [errors addObject:error];   

  // Warning 41
  error = [NSMutableDictionary dictionary];
  [error setValue:@NO forKey:@"check"];
  [error setValue:@41 forKey:@"code"];
  [error setValue:@"You ought to not use primitive TeX in LaTeX code." forKey:@"message"];
  [errors addObject:error];   

  // Warning 42
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@42 forKey:@"code"];
  [error setValue:@"You should remove spaces in front of ‘X’." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 43
  error = [NSMutableDictionary dictionary];
  [error setValue:@YES forKey:@"check"];
  [error setValue:@43 forKey:@"code"];
  [error setValue:@"‘X’ is normally not followed by ‘Y’." forKey:@"message"];
  [errors addObject:error];   
  
  return errors;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
}

- (id) initWithDelegate:(id<SyntaxCheckerDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    lacheckTask = nil;
    _taskRunning = NO;
  }
  
  return self;
}

- (void) setupObservers
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  [nc addObserver:self
         selector:@selector(texOutputAvailable:)
             name:NSFileHandleReadCompletionNotification
           object:lacheckFileHandle];
  
  [nc addObserver:self
         selector:@selector(taskFinished:) 
             name:NSTaskDidTerminateNotification
           object:lacheckTask];

}

- (NSArray*)argumentsForActiveErrors
{
  NSMutableArray *args = [NSMutableArray array];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *errorCodes = [defaults valueForKey:TPCheckSyntaxErrors];
  
  for (NSDictionary *error in errorCodes) {
    if ([[error valueForKey:@"check"] boolValue]) {
      [args addObject:[NSString stringWithFormat:@"-w%ld", [[error valueForKey:@"code"] integerValue]]];
    }
    else {
      [args addObject:[NSString stringWithFormat:@"-n%ld", [[error valueForKey:@"code"] integerValue]]];
    }
  }
  
  return args;
}

- (void) checkSyntaxOfFileAtPath:(NSString*)aPath
{
//  NSLog(@"Check syntax of %@", aPath);
  
//  if ([lacheckTask isRunning]) {
//    return;
//  }
  
  if (lacheckTask != nil) {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [lacheckTask interrupt];
  }
  
  lacheckTask = [[NSTask alloc] init];    
  pipe = [NSPipe pipe];
  [lacheckTask setStandardOutput:pipe];
  [lacheckTask setStandardError:pipe];    
  lacheckFileHandle = [pipe fileHandleForReading];
  [self setupObservers];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *chktexPath = [defaults valueForKey:TPChkTeXpath];
  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:chktexPath]) {
    self.errors = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syntaxCheckerCheckFailed:)]) {
      [self.delegate syntaxCheckerCheckFailed:self];
      return;
    }
  }
    
  self.output = @"";
//  NSLog(@"Checking %@", aPath);
  
  
	[lacheckTask setLaunchPath:chktexPath];
  [lacheckTask setCurrentDirectoryPath:[aPath stringByDeletingLastPathComponent]];
  
	NSArray *arguments;
	arguments = [NSArray arrayWithArray:[self argumentsForActiveErrors]];
	arguments = [arguments arrayByAddingObject:@"-q"];
  arguments = [arguments arrayByAddingObject:@"--inputfiles=0"];
  arguments = [arguments arrayByAddingObject:aPath];
//  NSLog(@"Args %@", arguments);
	[lacheckTask setArguments:arguments];
	
	[lacheckFileHandle readInBackgroundAndNotify];	
  
  _taskRunning = YES;
	[lacheckTask launch];	  
}

- (void) taskFinished:(NSNotification*)aNote
{
	if ([aNote object] != lacheckTask)
		return;
  	
  _taskRunning = NO;
  
}

- (void) texOutputAvailable:(NSNotification*)aNote
{	
//  NSLog(@"Output available");
  
	if( [aNote object] != lacheckFileHandle )
		return;
	
	NSData *data = [aNote userInfo][NSFileHandleNotificationDataItem];
//  NSLog(@"Got data %@", data);
  NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//  NSLog(@"Got string %@", string);
	self.output = [self.output stringByAppendingString:string];
  
	if( [data length] > 0) {
		[lacheckFileHandle readInBackgroundAndNotify];
  } else {
//    NSLog(@"output: %@", self.output);
    [self createErrors];
    [self syntaxCheckerCheckDidFinish:self];
    lacheckTask = nil;
    _taskRunning = NO;
  }
	
}

- (void) createErrors
{
  NSMutableArray *newErrors = [NSMutableArray array];
  NSArray *errorStrings = [self.output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  for (__strong NSString *errorString in errorStrings) {
    errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([errorString length]>0) {
      TPSyntaxError *error = [[TPSyntaxError alloc] initWithMessageLine:errorString];
      if ([error.line integerValue] != NSNotFound && [error.message length]>0 && [newErrors containsObject:error] == NO) {
        [newErrors addObject:error];
      }
    }
  }
  
  self.errors = newErrors;
}

#pragma mark -
#pragma mark Delegate

- (void)syntaxCheckerCheckFailed:(TPSyntaxChecker*)checker
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(syntaxCheckerCheckFailed:)]) {
    [self.delegate syntaxCheckerCheckFailed:self];
  }
}

- (void)syntaxCheckerCheckDidFinish:(TPSyntaxChecker*)checker
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(syntaxCheckerCheckDidFinish:)]) {
    [self.delegate syntaxCheckerCheckDidFinish:self];
  }
}

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)checker
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(syntaxCheckerShouldCheckSyntax:)]) {
    return [self.delegate syntaxCheckerShouldCheckSyntax:self];
  }
  return NO;
}

@end
