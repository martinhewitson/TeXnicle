//
//  TPLaTeXEngine.m
//  TeXnicle
//
//  Created by Martin Hewitson on 29/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import "TPLaTeXEngine.h"
#import "ProjectEntity.h"
#import "ConsoleController.h"
#import "externs.h"

NSString * const TPTypesettingCompletedNotification = @"TPTypesettingCompletedNotification";

@implementation TPLaTeXEngine

@synthesize project;


- (id) initWithProject:(ProjectEntity*)aProject
{
  self = [super init];
  if (self) {
    self.project = aProject;
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
    [nc addObserver:self
           selector:@selector(texOutputAvailable:)
               name:NSFileHandleReadCompletionNotification
             object:typesetFileHandle];
    
    [nc addObserver:self
           selector:@selector(taskFinished:) 
               name:NSTaskDidTerminateNotification
             object:typesetTask];
    
    [nc addObserver:self
           selector:@selector(bibTeXOutputAvailable:)
               name:NSFileHandleReadCompletionNotification
             object:bibtexFileHandle];
    
    [nc addObserver:self
           selector:@selector(dvipsOutputAvailable:)
               name:NSFileHandleReadCompletionNotification
             object:dvipsFileHandle];
    
    [nc addObserver:self
           selector:@selector(bibTeXTaskFinished:) 
               name:NSTaskDidTerminateNotification
             object:bibtexTask];
    
  }
  return self;
}

+ (TPLaTeXEngine*) engineWithProject:(ProjectEntity*)aProject
{
  return [[[TPLaTeXEngine alloc] initWithProject:aProject] autorelease];
}

- (void)dealloc
{
  [super dealloc];
}


#pragma mark -
#pragma mark BibTeX Control

- (IBAction) bibtex:(id)sender
{
	ConsoleController *console = [ConsoleController sharedConsoleController];
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:OpenConsoleOnTypeset] boolValue]) {
		[console showWindow:self];
		[[console window] makeKeyAndOrderFront:self];
	}
	
	NSString *mainFile = [[[self.project valueForKey:@"mainFile"] valueForKey:@"pathOnDisk"] stringByDeletingPathExtension];
	if (mainFile) {
		
		[console message:[NSString stringWithFormat:@"Running BibTeX for %@", mainFile]];
		
		
		if (bibtexTask) {
			[bibtexTask terminate];
			[bibtexTask release];
			// this must mean that the last run failed
		}
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *bibtexpath = [defaults valueForKey:TPBibTeXPath]; 
		
		bibtexTask = [[NSTask alloc] init];
    
		[bibtexTask setLaunchPath:bibtexpath];
		[bibtexTask setCurrentDirectoryPath:[project valueForKey:@"folder"]];
		
		NSArray *arguments;
		arguments = [NSArray arrayWithObjects:mainFile, nil];
		[bibtexTask setArguments:arguments];
		
		NSPipe *pipe;
		pipe = [NSPipe pipe];
		[bibtexTask setStandardOutput:pipe];
		
		bibtexFileHandle = [pipe fileHandleForReading];
		[bibtexFileHandle readInBackgroundAndNotify];	
		[bibtexTask launch];	
    
	}
	
}

- (void) bibTeXTaskFinished:(NSNotification*)aNote
{
	if ([aNote object] != bibtexTask)
		return;
	
	[bibtexTask terminate];
	[bibtexTask release];
	bibtexTask = nil;
	
}

- (void) bibTeXOutputAvailable:(NSNotification*)aNote
{	
	if( [aNote object] != bibtexFileHandle )
		return;
	
	NSData *data = [[aNote userInfo] 
									objectForKey:NSFileHandleNotificationDataItem];
	NSString *output = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	ConsoleController *console = [ConsoleController sharedConsoleController];
	[console appendText:output];	
	
	[output release];
	if( bibtexTask && [data length] > 0 )
		[bibtexFileHandle readInBackgroundAndNotify];
	
}


- (BOOL) canBibTeX
{
	if ([project valueForKey:@"mainFile"]) {
		return YES;
	}	
	return NO;	
}


#pragma mark -
#pragma mark dvips Control

- (IBAction) dvips:(id)sender
{
	ConsoleController *console = [ConsoleController sharedConsoleController];
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:OpenConsoleOnTypeset] boolValue]) {
		[console showWindow:self];
		[[console window] makeKeyAndOrderFront:self];
	}
	
	NSString *mainFile = [[[[self project] valueForKey:@"mainFile"] valueForKey:@"pathOnDisk"] stringByDeletingPathExtension];
	if (mainFile) {
		
		[console message:[NSString stringWithFormat:@"Converting dvi file of %@", mainFile]];
		
		
		if (dvipsTask) {
			[dvipsTask terminate];
			[dvipsTask release];
			// this must mean that the last run failed
		}
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *dvipspath = [defaults valueForKey:TPDvipsPath];
		[console message:[NSString stringWithFormat:@"running dvips"]];
		
		dvipsTask = [[NSTask alloc] init];
		
		[dvipsTask setLaunchPath:dvipspath];
		[dvipsTask setCurrentDirectoryPath:[project valueForKey:@"folder"]];
		
		NSArray *arguments;
		arguments = [NSArray arrayWithObjects:@"-quiet ", mainFile, nil];
		[dvipsTask setArguments:arguments];
		
		NSPipe *pipe;
		pipe = [NSPipe pipe];
		[dvipsTask setStandardOutput:pipe];
		
		dvipsFileHandle = [pipe fileHandleForReading];
		[dvipsFileHandle readInBackgroundAndNotify];	
		[dvipsTask launch];	
		
	}
	
}

- (void) dvipsTaskFinished:(NSNotification*)aNote
{
	if ([aNote object] != dvipsTask)
		return;
	
	[dvipsTask terminate];
	[dvipsTask release];
	dvipsTask = nil;
	
}

- (void) dvipsOutputAvailable:(NSNotification*)aNote
{	
	if( [aNote object] != dvipsFileHandle )
		return;
	
	NSData *data = [[aNote userInfo] 
									objectForKey:NSFileHandleNotificationDataItem];
	NSString *output = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	ConsoleController *console = [ConsoleController sharedConsoleController];
	[console appendText:output];	
	
	[output release];
	if( dvipsTask && [data length] > 0 )
		[dvipsFileHandle readInBackgroundAndNotify];
	
}

#pragma mark -
#pragma mark LaTeX Control


- (void) reset
{
  compilationsDone = 0;
}

- (BOOL) build
{
  
	ConsoleController *console = [ConsoleController sharedConsoleController];
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:OpenConsoleOnTypeset] boolValue]) {
		[console showWindow:self];
		[[console window] makeKeyAndOrderFront:self];
	}
	
	NSString *mainFile = [[[self project] valueForKey:@"mainFile"] valueForKey:@"pathOnDisk"];
	NSString *pdfFile = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
  
	if (!mainFile) {
		//NSLog(@"Specify a main file!");
		[console error:@"No main file specified!"];	
		
		NSAlert *alert = [NSAlert alertWithMessageText:@"No Main File Specified."
																		 defaultButton:@"OK"
																	 alternateButton:nil
																			 otherButton:nil
												 informativeTextWithFormat:@"Specify a main TeX file using the context menu on project tree or\nby using the Project menu."];
		
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
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *projectType = [[self project] valueForKey:@"type"];
  
	NSString *texpath;
	if ([projectType isEqual:@"pdflatex"]) {
		texpath = [defaults valueForKey:TPPDFLatexPath]; 
	} else if ([projectType isEqual:@"latex"]) {
		texpath = [defaults valueForKey:TPLatexPath]; 
	} else {
		return NO;
	}
  [console message:[NSString stringWithFormat:@"Compiling with %@", texpath]];
	
	typesetTask = [[NSTask alloc] init];
	
	[typesetTask setLaunchPath:texpath];
	[typesetTask setCurrentDirectoryPath:[project valueForKey:@"folder"]];
	NSArray *arguments;
	arguments = [NSArray arrayWithObjects:@"-file-line-error", @"-interaction=nonstopmode",  mainFile, nil];
	[typesetTask setArguments:arguments];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[typesetTask setStandardOutput:pipe];
	
	typesetFileHandle = [pipe fileHandleForReading];
	[typesetFileHandle readInBackgroundAndNotify];	
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
	compilationsDone++;
	
	if (abortCompile) {
		ConsoleController *console = [ConsoleController sharedConsoleController];
		[console message:[NSString stringWithFormat:@"Compile aborted."]];
		return;
	}
	
	// we have done at least one pdflatex task, so now we can do a bibtex if requested
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (compilationsDone == 1 && 
			[[defaults valueForKey:BibTeXDuringTypeset] boolValue]) {
		[self bibtex:self];		
	}
	
	NSUInteger nCompile = [[[NSUserDefaults standardUserDefaults] valueForKey:TPNRunsPDFLatex] intValue];
	
	if (compilationsDone == nCompile && 
			([[[self project] valueForKey:@"type"] isEqual:@"latex"])) {
		// do dvips
		[self dvips:self];
	}
  
	if (compilationsDone < nCompile) {
		[self build];
	} else {
		ConsoleController *console = [ConsoleController sharedConsoleController];
		NSString *mainFile = [[[self project] valueForKey:@"mainFile"] valueForKey:@"pathOnDisk"];
		[console message:[NSString stringWithFormat:@"Completed build of %@", mainFile]];
		
    // notify interested parties
    [[NSNotificationCenter defaultCenter] postNotificationName:TPTypesettingCompletedNotification
                                                        object:self
                                                      userInfo:nil];    
	}
	
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


@end
