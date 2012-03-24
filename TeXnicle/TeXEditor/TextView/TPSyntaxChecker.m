//
//  TPSyntaxChecker.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/03/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPSyntaxChecker.h"
#import "TPSyntaxError.h"
#import "externs.h"

@implementation TPSyntaxChecker

@synthesize output;
@synthesize errors;
@synthesize delegate;

+ (NSArray*) defaultSyntaxErrors
{
  NSMutableArray *errors = [NSMutableArray array];
  
  NSMutableDictionary *error;
  
  // Warning 1
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:1] forKey:@"code"];
  [error setValue:@"Command terminated with space" forKey:@"message"];
  [errors addObject:error];
  
  // Warning 2
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:2] forKey:@"code"];
  [error setValue:@"Non-breaking space ('~') should have been used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 3
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:3] forKey:@"code"];
  [error setValue:@"You should enclose the previous parenthesis with '{}'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 4
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:4] forKey:@"code"];
  [error setValue:@"Italic correction ('\\/') found in non-italic buffer." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 5
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:5] forKey:@"code"];
  [error setValue:@"Italic correction ('\\/') found more than once." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 6
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:6] forKey:@"code"];
  [error setValue:@"No italic correction ('\\/') found." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 7
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:7] forKey:@"code"];
  [error setValue:@"Accent command 'command' needs use of 'command'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 8
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:8] forKey:@"code"];
  [error setValue:@"Wrong length of dash may have been used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 9
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:9] forKey:@"code"];
  [error setValue:@"'X' expected, found 'Y'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 10
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:10] forKey:@"code"];
  [error setValue:@"Solo 'X' found." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 11
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:11] forKey:@"code"];
  [error setValue:@"You should use '\\ldots' or '\\cdots' to achieve an ellipsis." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 12
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:12] forKey:@"code"];
  [error setValue:@"Interword spacing (‘\\ ’) should perhaps be used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 13
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:13] forKey:@"code"];
  [error setValue:@"Intersentence spacing ('\\@') should perhaps be used." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 14
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:14] forKey:@"code"];
  [error setValue:@"Could not find argument for command." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 15
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:15] forKey:@"code"];
  [error setValue:@"No match found for 'X'." forKey:@"message"];
  [errors addObject:error];
  
  // Warning 16
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:16] forKey:@"code"];
  [error setValue:@"Mathmode still on at end of LaTeX file." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 17
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:17] forKey:@"code"];
  [error setValue:@"Number of open brackets doesn’t match the number of closing brackets." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 18
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:18] forKey:@"code"];
  [error setValue:@"You should use either `` or '' as an alternative to \"." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 19
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:19] forKey:@"code"];
  [error setValue:@"You should use \"’\" (ASCII 39) instead of \"’\" (ASCII 180)." forKey:@"message"];
  [errors addObject:error];  
  
  // Warning 20
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:20] forKey:@"code"];
  [error setValue:@"User-specified pattern found." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 21
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:NO] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:21] forKey:@"code"];
  [error setValue:@"This command might not be intended." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 22
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:NO] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:22] forKey:@"code"];
  [error setValue:@"Comment displayed." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 23
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:23] forKey:@"code"];
  [error setValue:@"Either ’’\\,’ or ’\\,’’ will look better." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 24
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:24] forKey:@"code"];
  [error setValue:@"Delete this space to maintain correct pagereferences." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 25
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:25] forKey:@"code"];
  [error setValue:@"You might wish to put this between a pair of ‘{}’." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 26
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:26] forKey:@"code"];
  [error setValue:@"You ought to remove spaces in front of punctuation." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 27
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:27] forKey:@"code"];
  [error setValue:@"Could not execute LaTeX command." forKey:@"message"];
  [errors addObject:error];   

  // Warning 28
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:28] forKey:@"code"];
  [error setValue:@"Don’t use \\/ in front of small punctuation." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 29
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:29] forKey:@"code"];
  [error setValue:@"$\times$ may look prettier here." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 30
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:NO] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:30] forKey:@"code"];
  [error setValue:@"Multiple spaces detected in output." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 31
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:31] forKey:@"code"];
  [error setValue:@"This text may be ignored." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 32
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:32] forKey:@"code"];
  [error setValue:@"Use ‘ to begin quotation, not ’." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 33
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:33] forKey:@"code"];
  [error setValue:@"Use ’ to end quotation, not ‘." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 34
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:34] forKey:@"code"];
  [error setValue:@"Don’t mix quotes." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 35
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:35] forKey:@"code"];
  [error setValue:@"You should perhaps use ‘cmd’ instead." forKey:@"message"];
  [errors addObject:error]; 
  
  // Warning 36
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:36] forKey:@"code"];
  [error setValue:@"You should put a space in front of/after parenthesis." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 37
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:37] forKey:@"code"];
  [error setValue:@"You should avoid spaces in front of/after parenthesis." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 38
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:38] forKey:@"code"];
  [error setValue:@"You should not use punctuation in front of/after quotes." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 39
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:39] forKey:@"code"];
  [error setValue:@"Double space found." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 40
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:40] forKey:@"code"];
  [error setValue:@"You should put punctuation outside inner/inside display math mode." forKey:@"message"];
  [errors addObject:error];   

  // Warning 41
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:NO] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:41] forKey:@"code"];
  [error setValue:@"You ought to not use primitive TeX in LaTeX code." forKey:@"message"];
  [errors addObject:error];   

  // Warning 42
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:42] forKey:@"code"];
  [error setValue:@"You should remove spaces in front of ‘X’." forKey:@"message"];
  [errors addObject:error];   
  
  // Warning 43
  error = [NSMutableDictionary dictionary];
  [error setValue:[NSNumber numberWithBool:YES] forKey:@"check"];
  [error setValue:[NSNumber numberWithInteger:43] forKey:@"code"];
  [error setValue:@"‘X’ is normally not followed by ‘Y’." forKey:@"message"];
  [errors addObject:error];   
  
  return errors;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.errors = nil;
  [super dealloc];
}

- (id) initWithDelegate:(id<SyntaxCheckerDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    
    self.delegate = aDelegate;
    
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
      [args addObject:[NSString stringWithFormat:@"-w%d", [[error valueForKey:@"code"] integerValue]]];
    }
    else {
      [args addObject:[NSString stringWithFormat:@"-n%d", [[error valueForKey:@"code"] integerValue]]];
    }
  }
  
  return args;
}

- (void) checkSyntaxOfFileAtPath:(NSString*)aPath
{
  if (_taskRunning) {
    return;
  }
  
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
    
  if (lacheckTask) {
		[lacheckTask terminate];
		[lacheckTask release];		
    lacheckTask = nil;
		// this must mean that the last run failed
	}

  self.output = @"";
//  NSLog(@"Checking %@", aPath);
  
	lacheckTask = [[NSTask alloc] init];
  
	[lacheckTask setLaunchPath:chktexPath];
  [lacheckTask setCurrentDirectoryPath:[aPath stringByDeletingLastPathComponent]];
  
	NSArray *arguments;
	arguments = [NSArray arrayWithArray:[self argumentsForActiveErrors]];
	arguments = [arguments arrayByAddingObject:@"-q"];
  arguments = [arguments arrayByAddingObject:@"--inputfiles=0"];
  arguments = [arguments arrayByAddingObject:aPath];
//  NSLog(@"Args %@", arguments);
	[lacheckTask setArguments:arguments];
	
	NSPipe *pipe = [NSPipe pipe];
	[lacheckTask setStandardOutput:pipe];
  [lacheckTask setStandardError:pipe];
	
	lacheckFileHandle = [pipe fileHandleForReading];
	[lacheckFileHandle readInBackgroundAndNotify];	
  
	[self setupObservers];
	[lacheckTask launch];	  
  _taskRunning = YES;
}

- (void) taskFinished:(NSNotification*)aNote
{
//  NSLog(@"Task finished, %@", aNote);
  
	if ([aNote object] != lacheckTask)
		return;
	
  _taskRunning = NO;
	[lacheckTask release];
	lacheckTask = nil;
  
}



- (void) texOutputAvailable:(NSNotification*)aNote
{	
//  NSLog(@"Output available %@", aNote);
  
	if( [aNote object] != lacheckFileHandle )
		return;
	
	NSData *data = [[aNote userInfo] objectForKey:NSFileHandleNotificationDataItem];
//  NSLog(@"Got data %@", data);
  NSString *string = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//  NSLog(@"Got string %@", string);
	self.output = [self.output stringByAppendingString:string];
  [string release];
  
	if( [data length] > 0) {
		[lacheckFileHandle readInBackgroundAndNotify];
  } else {
//    NSLog(@"output: %@", self.output);
    [self createErrors];
    [self syntaxCheckerCheckDidFinish:self];
  }
	
}

- (void) createErrors
{
  NSMutableArray *newErrors = [NSMutableArray array];
  NSArray *errorStrings = [self.output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  for (NSString *errorString in errorStrings) {
    errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([errorString length]>0) {
      TPSyntaxError *error = [TPSyntaxError errorWithMessageLine:errorString];
      if ([error.line integerValue] != NSNotFound && [error.message length]>0) {
        [newErrors addObject:error];
      }
    }
  }
  
  self.errors = newErrors;
}

- (void)syntaxCheckerCheckDidFinish:(TPSyntaxChecker*)checker
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(syntaxCheckerCheckDidFinish:)]) {
    [self.delegate syntaxCheckerCheckDidFinish:self];
  }
}

@end
