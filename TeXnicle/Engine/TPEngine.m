//
//  TPEngine.m
//  TeXnicle
//
//  Created by Martin Hewitson on 24/08/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPEngine.h"
#import "ConsoleController.h"
#import "externs.h"



@implementation TPEngine

@synthesize path;
@synthesize script;
@synthesize name;
@synthesize documentPath;

@synthesize doBibtex;
@synthesize doPS2PDF;
@synthesize nCompile;
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
    [self setupObservers];    
  }
  
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void) setupObservers
{
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  [nc addObserver:self
         selector:@selector(texOutputAvailable:)
             name:NSFileHandleReadCompletionNotification
           object:typesetFileHandle];
  
  [nc addObserver:self
         selector:@selector(taskFinished:) 
             name:NSTaskDidTerminateNotification
           object:typesetTask];
  
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
  
	ConsoleController *console = [ConsoleController sharedConsoleController];
	if (self.openConsole) {
		[console showWindow:self];
		[[console window] makeKeyAndOrderFront:self];
	}
	
	NSString *mainFile = self.documentPath;
	NSString *pdfFile = [self compiledDocumentPath];
  
	if (!mainFile) {
    
		//NSLog(@"Specify a main file!");
		[console error:@"No main file specified!"];	
		
    NSAlert *alert = nil;
    if (isProject) {
      alert = [NSAlert alertWithMessageText:@"No Main File Found."
                              defaultButton:@"OK"
                            alternateButton:nil
                                otherButton:nil
                  informativeTextWithFormat:@"Specify a main TeX file using the context menu on project tree or by using the Project menu."];
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
	
	[console message:[NSString stringWithFormat:@"Compiling main file:%@", mainFile]];
  
	
	if (typesetTask) {
		[typesetTask terminate];
		[typesetTask release];		
		// this must mean that the last run failed
	}
	
	// check if the pdf exists
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:pdfFile]) {
		NSError *error = nil;
		[fm removeItemAtPath:pdfFile
									 error:&error];
		if (error) {
			[NSApp presentError:error];
		}
	}		
	
  [console message:[NSString stringWithFormat:@"Compiling with %@", self.path]];
//	NSLog(@"Compiling with %@", self.path);
	typesetTask = [[NSTask alloc] init];
	
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
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[typesetTask setStandardOutput:pipe];
	
	typesetFileHandle = [pipe fileHandleForReading];
	[typesetFileHandle readInBackgroundAndNotify];	
  self.compiling = YES;
	[typesetTask launch];	
	
	return YES;  
}

- (void) taskFinished:(NSNotification*)aNote
{
	if ([aNote object] != typesetTask)
		return;
	
	[typesetTask terminate];
	[typesetTask release];
	typesetTask = nil;
  self.compiling = NO;
	compilationsDone++;
	
	if (abortCompile) {
		ConsoleController *console = [ConsoleController sharedConsoleController];
		[console message:[NSString stringWithFormat:@"Compile aborted."]];
		return;
	}
	
  ConsoleController *console = [ConsoleController sharedConsoleController];
  [console message:[NSString stringWithFormat:@"Completed build of %@", self.documentPath]];
  
  // notify interested parties
  [self.delegate compileDidFinish:!abortCompile];
}

- (void) texOutputAvailable:(NSNotification*)aNote
{	
	if( [aNote object] != typesetFileHandle )
		return;
	
	NSData *data = [[aNote userInfo] 
									objectForKey:NSFileHandleNotificationDataItem];
	NSString *output = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	ConsoleController *console = [ConsoleController sharedConsoleController];
	
	NSScanner *scanner = [NSScanner scannerWithString:output];
	NSString *scanned;
	if ([scanner scanUpToString:@"LaTeX Error:" intoString:&scanned]) {
		NSInteger loc = [scanner scanLocation];
		if (loc < [output length]) {
			[console error:[output substringFromIndex:[scanner scanLocation]]];
			abortCompile = YES;
		}
	}	
	
	[console appendText:output];	
	
	[output release];
	if( typesetTask && [data length] > 0 )
		[typesetFileHandle readInBackgroundAndNotify];
	
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
  [[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Trashing aux files for %@", [self.documentPath lastPathComponent]]];
  
	NSArray *filesToClear = [[NSUserDefaults standardUserDefaults] valueForKey:TPTrashFiles];
  
  // trash document as well?
  if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPTrashDocumentFileWhenTrashing] boolValue]) {
    if (self.compiledDocumentPath) {
      filesToClear = [filesToClear arrayByAddingObject:[self.compiledDocumentPath pathExtension]];
    }
  }
  
  //  NSLog(@"  deleting %@", filesToClear);
  NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	for (NSString *ext in filesToClear) {
		error = nil;
		NSString *file = [[self.documentPath stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
    if ([fm fileExistsAtPath:file]) {
      if ([fm removeItemAtPath:file error:&error]) {
        [[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Deleted: %@", file]];
      } else {
        [[ConsoleController sharedConsoleController] error:[NSString stringWithFormat:@"Failed to delete: %@ [%@]", file, [error localizedDescription]]];
      } 
    }		
	}		
}

@end
