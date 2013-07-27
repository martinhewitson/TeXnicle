//
//  TPEngine.m
//  TeXnicle
//
//  Created by Martin Hewitson on 24/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
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

#import "TPEngine.h"
#import "ConsoleController.h"
#import "externs.h"
#import "MHFileReader.h"
#import "NSScanner+TeXnicle.h"
#import "NSApplication+SystemVersion.h"
#import "TPTeXLogParser.h"
#import "TPLogItem.h"

@interface TPEngine ()

@property (strong) NSTask *typesetTask;
@property (copy) NSString *mainfileName;
@property (copy) NSString *workingDirectory;
@property (assign) NSInteger compilationsDone;

@end

@implementation TPEngine

- (NSString*)description
{
  return [NSString stringWithFormat:@"%p: %@, %@, %@, [%d]", self, self.name, self.path, self.documentPath, self.builtIn];
}

+ (TPEngine*)engineWithPath:(NSString*)aPath
{
  return [[TPEngine alloc] initWithPath:aPath];
}

- (id)initWithPath:(NSString*)aPath
{
  self = [super init];
  if (self) {
    // Initialization code here.
    self.path = aPath;
    self.name = [[aPath lastPathComponent] stringByDeletingPathExtension];
    self.doBibtex = NO;
    self.doPS2PDF = NO;
    self.nCompile = 1;
    self.openConsole = YES;
    self.builtIn = NO;
    self.compiling = NO;
    self.supportsDoBibtex = NO;
    self.supportsDoPS2PDF = NO;
    self.supportsNCompile = NO;
    
    [self parseEngineFile];
  }
  
  return self;
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.delegate = nil;
  
  [self cancelCompile];
}

- (void) setupObservers
{
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self];
  
  
  [nc addObserver:self
         selector:@selector(texOutputAvailable:)
             name:NSFileHandleReadCompletionNotification
           object:typesetFileHandle];
  
  [nc addObserver:self
         selector:@selector(taskFinished:) 
             name:NSTaskDidTerminateNotification
           object:self.typesetTask];
  
}

- (void) parseEngineFile
{
  MHFileReader *fr = [[MHFileReader alloc] init];
  NSString *str = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:self.path]];
  
  if (str == nil) {
    return;
  }
  
  NSScanner *scanner = [NSScanner scannerWithString:str];

  // support
  NSString *supportString = [scanner stringForTag:@"support"];
  if (supportString) {
    NSArray *opts = [supportString componentsSeparatedByString:@","];
    if ([opts containsObject:@"nCompile"]) {
      self.supportsNCompile = YES;
    }
    if ([opts containsObject:@"doBibtex"]) {
      self.supportsDoBibtex = YES;
    }
    if ([opts containsObject:@"doPS2PDF"]) {
      self.supportsDoPS2PDF = YES;
    }
  }
  
  // image string
  self.imageIncludeString = [scanner stringForTag:@"imageinclude"];
  if (self.imageIncludeString == nil || [self.imageIncludeString length] == 0) {
    self.imageIncludeString = [TPEngine defaultImageIncludeString];
  }
  
}

+ (NSString*)defaultImageIncludeString
{
  NSMutableString *insert = nil;
  insert = [NSMutableString stringWithFormat:@"\\begin{figure}[htbp]\n"];
  [insert appendFormat:@"\\centering\n"];
  [insert appendFormat:@"\\includegraphics[width=0.8\\textwidth]{$PATH$}\n"];
  [insert appendFormat:@"\\caption{My Nice Pasted Figure.}\n"];
  [insert appendFormat:@"\\label{fig:$NAME$}\n"];
  [insert appendFormat:@"\\end{figure}\n"];
  return insert;
}

#pragma mark -
#pragma mark Compiling

- (NSString*)compiledDocumentPath
{
  if (self.documentPath) {
    return [[self.documentPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
  }
  
  return nil;
}

- (void) cancelCompile
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if (self.typesetTask != nil) {
    if ([self.typesetTask isRunning] == YES && procId >= 0) {
      [self.typesetTask terminate];
      procId = -1;
    }
    self.typesetTask = nil;
  }
  
  [self reset];  
  [self compileWasCancelled];
}

- (void) compileWasCancelled
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(compileWasCancelled)]) {
    [self.delegate compileWasCancelled];
  }
}

- (BOOL) compileDocumentAtPath:(NSString*)aDocumentPath workingDirectory:(NSString*)workingDir isProject:(BOOL)isProject
{
  if (self.compiling == YES || self.typesetTask != nil) {
    return NO;
  }
  
  self.documentPath = aDocumentPath;
//  NSLog(@"Compiling %@", self.documentPath);
//  NSLog(@"Working dir %@", workingDir);
  
	if (self.openConsole) {
    ConsoleController *console = [ConsoleController sharedConsoleController];
		[console showWindow:self];
		[[console window] makeKeyAndOrderFront:self];
	}
	
	NSString *mainFile = self.documentPath;
  
	if (!mainFile) {
    
		[self enginePostError:@"No main file specified!"];
    
    NSAlert *alert = nil;
    if (isProject) {
      alert = [NSAlert alertWithMessageText:@"No Main File Found."
                              defaultButton:@"OK"
                            alternateButton:nil
                                otherButton:nil
                  informativeTextWithFormat:@"Specify a main file using the context menu on project tree or by using the Project menu."];
    } else {
      alert = [NSAlert alertWithMessageText:@"No Main File Found."
                              defaultButton:@"OK"
                            alternateButton:nil
                                otherButton:nil
                  informativeTextWithFormat:@"No file found for compiling. Perhaps the document wasn't saved?"];
    }
    [alert runModal];
		
		return NO;
	}
	
  [self enginePostMessage:[NSString stringWithFormat:@"Compiling main file:%@", mainFile]];	
  [self enginePostMessage:[NSString stringWithFormat:@"Compiling with %@", self.path]];
  
  self.mainfileName = [mainFile lastPathComponent];
  self.workingDirectory = workingDir;
  
  
  
  [self doRunNumber:0];
	
	return YES;  
}

- (void) doRunNumber:(NSInteger)runNumber
{
  //NSLog(@"Starting task run %ld", runNumber);
  
  [self enginePostMessage:[NSString stringWithFormat:@"[%ld/%ld] Typesetting main file:%@", runNumber, self.nCompile, self.documentPath]];
  
  if (self.typesetTask == nil) {
    self.typesetTask = [[NSTask alloc] init];
    pipe = [NSPipe pipe];
    [self.typesetTask setStandardOutput:pipe];
    [self.typesetTask setStandardError:pipe];
    typesetFileHandle = [pipe fileHandleForReading];
    [self setupObservers];
  }
  
	[self.typesetTask setLaunchPath:self.path];
  [self.typesetTask setCurrentDirectoryPath:self.workingDirectory];
  
  NSArray *arguments = @[self.mainfileName,
                         self.workingDirectory,
                         [NSString stringWithFormat:@"%ld", self.nCompile],
                         [NSString stringWithFormat:@"%d", self.doBibtex],
                         [NSString stringWithFormat:@"%d", self.doPS2PDF],
                         [NSString stringWithFormat:@"%ld", 1+runNumber] // script wants 1-based counting
                         ];
	[self.typesetTask setArguments:arguments];
	
	[typesetFileHandle readInBackgroundAndNotify];
  
  self.compiling = YES;
  procId = [self.typesetTask processIdentifier];
	[self.typesetTask launch];

}

- (void) taskFinished:(NSNotification*)aNote
{
	if ([aNote object] != self.typesetTask)
		return;
  
  //NSLog(@"Task finished %@", [aNote object]);
	
  self.compiling = NO;
	self.compilationsDone += 1;
	
  if (self.compilationsDone < self.nCompile && abortCompile == NO) {
    // go again
    self.typesetTask = nil;
    [self doRunNumber:self.compilationsDone];
  } else {
    // notify interested parties
    //  NSLog(@"Compile finished - informing delegate");
    [self compileDidFinish:!abortCompile];
    
    if (abortCompile) {
      [self enginePostMessage:[NSString stringWithFormat:@"Compile aborted."]];
      return;
    }
    
    [self enginePostMessage:[NSString stringWithFormat:@"Completed build of %@", self.documentPath]];
    
    
    self.typesetTask = nil;
    procId = -1;
  }
}


- (void) texOutputAvailable:(NSNotification*)aNote
{	
  
	if( [aNote object] != typesetFileHandle )
		return;
	
//  NSLog(@"texOutputAvailable %@", [aNote object]);
  
	NSData *data = [aNote userInfo][NSFileHandleNotificationDataItem];
	NSString *output = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
  // check if the output contains an error string
  NSDictionary *errors = [TPTeXLogParser errorPhrases];
  NSArray *keys = [errors allKeysForObject:@(TPLogError)];
  
  for (NSString *errorPhrase in keys) {
    NSScanner *scanner = [NSScanner scannerWithString:output];
    NSString *scanned;
    if ([scanner scanUpToString:errorPhrase intoString:&scanned]) {
      NSInteger loc = [scanner scanLocation];
      if (loc < [output length]) {
        [self enginePostError:[output substringFromIndex:[scanner scanLocation]]];
        abortCompile = YES;
      }
    }	
	}
  
	[self enginePostTextForAppending:output];
  
	if([data length] > 0) {
//	if([data length] > 0 && abortCompile == NO) {
		[typesetFileHandle readInBackgroundAndNotify];
  }
	
}

- (void) reset
{
  abortCompile = NO;
  self.compilationsDone = 0;
  self.compiling = NO;
  self.typesetTask = nil;
}

- (void) trashAuxFiles:(BOOL)keepDocument
{
	// build path to the pdf file
  [self enginePostMessage:[NSString stringWithFormat:@"Trashing aux files for %@", [self.documentPath lastPathComponent]]];
  
	NSArray *filesToClear = [[NSUserDefaults standardUserDefaults] valueForKey:TPTrashFiles];
  
  // trash document as well?
  if (keepDocument == NO && [[[NSUserDefaults standardUserDefaults] valueForKey:TPTrashDocumentFileWhenTrashing] boolValue]) {
    if (self.compiledDocumentPath) {
      NSString *ext = [self.compiledDocumentPath pathExtension];
      if (ext != nil) {
        filesToClear = [filesToClear arrayByAddingObject:ext];
      }
    }
  }
  
//  NSLog(@"  deleting %@ for %@", filesToClear, self.documentPath);
  NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	for (NSString *ext in filesToClear) {
		error = nil;
		NSString *file = [self.documentPath stringByAppendingPathExtension:ext];
    if ([fm fileExistsAtPath:file]) {
      if ([fm removeItemAtPath:file error:&error]) {
        [self enginePostMessage:[NSString stringWithFormat:@"Deleted: %@", file]];
      } else {
        [self enginePostMessage:[NSString stringWithFormat:@"Failed to delete: %@ [%@]", file, [error localizedDescription]]];
      } 
    }		
	}
	
  
}

- (void) trashAuxFiles:(NSArray*)fileTypes inDirectory:(NSString*)aDir
{
  NSError *error = nil;
  NSFileManager *fm = [NSFileManager defaultManager];
  NSArray *items = [fm contentsOfDirectoryAtPath:aDir error:&error];
  
}

#pragma mark -
#pragma mark Engine delegate

- (void)compileDidFinish:(BOOL)success
{
//  if (abortCompile) {
//    return;
//  }
  
  // log file notification
  [self performSelector:@selector(postLogfileNotification) withObject:nil afterDelay:1];
  
  if ([[NSApplication sharedApplication] isMountainLion]) {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:@"Typesetting Completed"];
    if (success) {
      [notification setInformativeText:[NSString stringWithFormat:@"Typesetting of %@ with engine %@ completed", [self.documentPath lastPathComponent], self.name]];
    } else {
      [notification setInformativeText:[NSString stringWithFormat:@"Typesetting of %@ with engine %@ failed", [self.documentPath lastPathComponent], self.name]];
    }
    [notification setDeliveryDate:[NSDate date]];
    [notification setSoundName:NSUserNotificationDefaultSoundName];
    
    //Get the default notification center
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    //Scheldule our NSUserNotification
    [center scheduleNotification:notification];
  }
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(compileDidFinish:)]) {
    [self.delegate compileDidFinish:success];
  }  
}

- (void) postLogfileNotification
{
  NSDictionary *dict = @{@"path" : [self.documentPath stringByAppendingPathExtension:@"log"]};
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:TPLogfileAvailableNotification
                    object:self
                  userInfo:dict];
}

- (void)enginePostMessage:(NSString*)someText
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(enginePostMessage:)]) {
    [self.delegate enginePostMessage:someText];
  }
}

- (void)enginePostError:(NSString*)someText
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(enginePostError:)]) {
    [self.delegate enginePostError:someText];
  }
}

- (void)enginePostTextForAppending:(NSString*)someText
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(enginePostTextForAppending:)]) {
    [self.delegate enginePostTextForAppending:someText];
  }
}



@end
