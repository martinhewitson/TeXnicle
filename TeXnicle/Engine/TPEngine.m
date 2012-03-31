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
//  DISCLAIMED. IN NO EVENT SHALL DAN WOOD, MIKE ABDULLAH OR KARELIA SOFTWARE BE LIABLE FOR ANY
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

@implementation TPEngine

@synthesize path;
@synthesize script;
@synthesize name;
@synthesize documentPath;

@synthesize doBibtex;
@synthesize doPS2PDF;
@synthesize nCompile;
@synthesize supportsDoBibtex;
@synthesize supportsDoPS2PDF;
@synthesize supportsNCompile;

@synthesize imageIncludeString;

@synthesize openConsole;

@synthesize builtIn;
@synthesize compiling;

@synthesize delegate;

- (NSString*)description
{
  return [NSString stringWithFormat:@"%p: %@, %@, %@, [%d]", self, self.name, self.path, self.documentPath, self.builtIn];
}

+ (TPEngine*)engineWithPath:(NSString*)aPath
{
  return [[[TPEngine alloc] initWithPath:aPath] autorelease];
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

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.delegate = nil;
  
  [typesetTask release];
  
  [super dealloc];
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
           object:typesetTask];
  
}

- (void) parseEngineFile
{
  MHFileReader *fr = [[[MHFileReader alloc] init] autorelease];
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

- (BOOL) compileDocumentAtPath:(NSString*)aDocumentPath workingDirectory:(NSString*)workingDir isProject:(BOOL)isProject
{
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
  
  if (typesetTask == nil) {
    typesetTask = [[NSTask alloc] init];
    pipe = [NSPipe pipe];
    [typesetTask setStandardOutput:pipe];
    [typesetTask setStandardError:pipe];    
    typesetFileHandle = [pipe fileHandleForReading];    
    [self setupObservers];    
  }
  
	[typesetTask setLaunchPath:self.path];
  [typesetTask setCurrentDirectoryPath:workingDir];
    
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects:
               [mainFile lastPathComponent], 
               workingDir, 
               [NSString stringWithFormat:@"%d", self.nCompile], 
               [NSString stringWithFormat:@"%d", self.doBibtex], 
               [NSString stringWithFormat:@"%d", self.doPS2PDF], 
               nil];
	[typesetTask setArguments:arguments];
	
	[typesetFileHandle readInBackgroundAndNotify];	
  
  self.compiling = YES;
	[typesetTask launch];	
	
	return YES;  
}

- (void) taskFinished:(NSNotification*)aNote
{
//  NSLog(@"Task finished %@", [aNote object]);
	if ([aNote object] != typesetTask)
		return;
	
  self.compiling = NO;
	compilationsDone++;
	
  // notify interested parties
//  NSLog(@"Compile finished - informing delegate");
  [self.delegate compileDidFinish:!abortCompile];
  
	if (abortCompile) {
    [self enginePostMessage:[NSString stringWithFormat:@"Compile aborted."]];
		return;
	}
	
  [self enginePostMessage:[NSString stringWithFormat:@"Completed build of %@", self.documentPath]];
  
  [typesetTask release];
  typesetTask = nil;
}

- (void) texOutputAvailable:(NSNotification*)aNote
{	
  
	if( [aNote object] != typesetFileHandle )
		return;
	
//  NSLog(@"texOutputAvailable %@", [aNote object]);
  
	NSData *data = [[aNote userInfo] objectForKey:NSFileHandleNotificationDataItem];
	NSString *output = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	
	NSScanner *scanner = [NSScanner scannerWithString:output];
	NSString *scanned;
	if ([scanner scanUpToString:@"LaTeX Error:" intoString:&scanned]) {
		NSInteger loc = [scanner scanLocation];
		if (loc < [output length]) {
      [self enginePostError:[output substringFromIndex:[scanner scanLocation]]];
			abortCompile = YES;
		}
	}	
	
	[self enginePostTextForAppending:output];
  
	if([data length] > 0 ) {
		[typesetFileHandle readInBackgroundAndNotify];
  }
	
}

- (void) reset
{
  abortCompile = NO;
  compilationsDone = 0;
  self.compiling = NO;
}

- (void) trashAuxFiles
{
	// build path to the pdf file
  [self enginePostMessage:[NSString stringWithFormat:@"Trashing aux files for %@", [self.documentPath lastPathComponent]]];
  
	NSArray *filesToClear = [[NSUserDefaults standardUserDefaults] valueForKey:TPTrashFiles];
  
  // trash document as well?
  if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPTrashDocumentFileWhenTrashing] boolValue]) {
    if (self.compiledDocumentPath) {
      filesToClear = [filesToClear arrayByAddingObject:[self.compiledDocumentPath pathExtension]];
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

#pragma mark -
#pragma mark Engine delegate

- (void)compileDidFinish:(BOOL)success
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(compileDidFinish:)]) {
    [self.delegate compileDidFinish:success];
  }
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
