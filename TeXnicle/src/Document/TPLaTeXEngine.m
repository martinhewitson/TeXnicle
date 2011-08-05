//
//  TPLaTeXEngine.m
//  TeXnicle
//
//  Created by Martin Hewitson on 29/05/11.
//  Copyright 2011 bobsoft. All rights reserved.
//

#import "TPLaTeXEngine.h"
#import "ProjectEntity.h"
#import "ConsoleController.h"
#import "externs.h"

NSString * const TPTypesettingCompletedNotification = @"TPTypesettingCompletedNotification";

@implementation TPLaTeXEngine

@synthesize delegate;

+ (TPLaTeXEngine*)engineWithDelegate:(id)aDelegate
{
  return [[[TPLaTeXEngine alloc] initWithDelegate:aDelegate] autorelease];
}

- (id) initWithDelegate:(id)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    [self setupObservers];
  }
  return self;
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
  
  [nc addObserver:self
         selector:@selector(bibTeXOutputAvailable:)
             name:NSFileHandleReadCompletionNotification
           object:bibtexFileHandle];
  
  [nc addObserver:self
         selector:@selector(dvipsOutputAvailable:)
             name:NSFileHandleReadCompletionNotification
           object:dvipsFileHandle];
  
  [nc addObserver:self
         selector:@selector(dvipsTaskFinished:)
             name:NSTaskDidTerminateNotification
           object:dvipsTask];
  
  [nc addObserver:self
         selector:@selector(bibTeXTaskFinished:) 
             name:NSTaskDidTerminateNotification
           object:bibtexTask];
  
  [nc addObserver:self
         selector:@selector(ps2pdfOutputAvailable:) 
             name:NSFileHandleReadCompletionNotification
           object:ps2pdfFileHandle];
  
  [nc addObserver:self
         selector:@selector(ps2pdfTaskFinished:) 
             name:NSTaskDidTerminateNotification
           object:ps2pdfTask];
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
	
	NSString *mainFile = [self engineDocumentToCompile:self];
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
    [bibtexTask setCurrentDirectoryPath:[self engineWorkingDirectory:self]];
		
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

#pragma mark -
#pragma mark ps2pdf Control

- (IBAction) ps2pdf:(id)sender
{
	ConsoleController *console = [ConsoleController sharedConsoleController];
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:OpenConsoleOnTypeset] boolValue]) {
		[console showWindow:self];
		[[console window] makeKeyAndOrderFront:self];
	}
	
	NSString *mainFile = [self engineDocumentToCompile:self];
  mainFile = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"ps"];
	if (mainFile) {
		
		[console message:[NSString stringWithFormat:@"Converting ps file of %@", mainFile]];
		
		
		if (ps2pdfTask) {
      if ([ps2pdfTask isRunning]) {
        [ps2pdfTask terminate];
      }
			[ps2pdfTask release];
			// this must mean that the last run failed
		}
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *ps2pdfpath = [defaults valueForKey:TPPS2PDFPath];
    if (!ps2pdfpath || [ps2pdfpath length]==0) {
      [console error:@"No ps2pdf path specified in the preferences."];
      return;
    }
		[console message:[NSString stringWithFormat:@"running ps2pdf"]];
		
		ps2pdfTask = [[NSTask alloc] init];
		
		[ps2pdfTask setLaunchPath:ps2pdfpath];
    [ps2pdfTask setCurrentDirectoryPath:[self engineWorkingDirectory:self]];
    
		NSArray *arguments;
		arguments = [NSArray arrayWithObjects:mainFile, nil];
		[ps2pdfTask setArguments:arguments];
		
		NSPipe *pipe;
		pipe = [NSPipe pipe];
		[ps2pdfTask setStandardOutput:pipe];
		
		ps2pdfFileHandle = [pipe fileHandleForReading];
		[ps2pdfFileHandle readInBackgroundAndNotify];	
		[ps2pdfTask launch];	
		
	}
	
}

- (void) ps2pdfTaskFinished:(NSNotification*)aNote
{
	if ([aNote object] != ps2pdfTask)
		return;
	
	[ps2pdfTask terminate];
	[ps2pdfTask release];
	ps2pdfTask = nil;
  
  didPS2PDF = YES;
	
  // notify interested parties
  [[NSNotificationCenter defaultCenter] postNotificationName:TPTypesettingCompletedNotification
                                                      object:self
                                                    userInfo:nil];    
}

- (void) ps2pdfOutputAvailable:(NSNotification*)aNote
{	
	if( [aNote object] != ps2pdfFileHandle )
		return;
	
	NSData *data = [[aNote userInfo] 
									objectForKey:NSFileHandleNotificationDataItem];
	NSString *output = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	
	ConsoleController *console = [ConsoleController sharedConsoleController];
	[console appendText:output];	
	
	[output release];
	if( ps2pdfTask && [data length] > 0 )
		[ps2pdfFileHandle readInBackgroundAndNotify];
	
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
	
	NSString *mainFile = [self engineDocumentToCompile:self];
  mainFile = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"dvi"];
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
    [dvipsTask setCurrentDirectoryPath:[self engineWorkingDirectory:self]];
    
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
    
  if ([self engineProjectType:self] == TPEngineCompilerLaTeX) {
    // do ps2pdf
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPShouldRunPS2PDF] boolValue]) {
      [self ps2pdf:self];
    } else {
      // delete the pdf if it's available
      NSString *pdf = [self pdfPath];
      NSFileManager *fm = [NSFileManager defaultManager];
      NSError *error = nil;
      if ([fm fileExistsAtPath:pdf]) {
        [fm removeItemAtPath:pdf error:&error];
        if (error) {
          [NSApp presentError:error];
        }
      }      
    }
  }
	
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

- (void) trashAuxFiles
{
	// build path to the pdf file
	NSString *mainFile = [self engineDocumentToCompile:self];
  [[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Trashing aux files for %@", [mainFile lastPathComponent]]];
//  NSLog(@"Trashing for %@", mainFile);
  
	NSArray *filesToClear = [[NSUserDefaults standardUserDefaults] valueForKey:TPTrashFiles];
  
  // trash document as well?
  if ([[[NSUserDefaults standardUserDefaults] valueForKey:TPTrashDocumentFileWhenTrashing] boolValue]) {
    NSString *docPath = [self compiledDocumentPath];
    if (docPath) {
      filesToClear = [filesToClear arrayByAddingObject:[[self compiledDocumentPath] pathExtension]];
    }
  }
  
//  NSLog(@"  deleting %@", filesToClear);
  NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	for (NSString *ext in filesToClear) {
		error = nil;
		NSString *file = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
    if ([fm fileExistsAtPath:file]) {
      if ([fm removeItemAtPath:file error:&error]) {
        [[ConsoleController sharedConsoleController] message:[NSString stringWithFormat:@"Deleted: %@", file]];
      } else {
        [[ConsoleController sharedConsoleController] error:[NSString stringWithFormat:@"Failed to delete: %@ [%@]", file, [error localizedDescription]]];
      } 
    }		
	}		
}

- (void) reset
{
  abortCompile = NO;
  compilationsDone = 0;
  didPS2PDF = NO;
}

- (NSString*)pdfPath
{
  NSString *path = [self compiledDocumentPath];
  return [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
}


- (NSString*)compiledDocumentPath
{
	// build path to the pdf file
	NSString *mainFile = [self engineDocumentToCompile:self]; 
  NSString *docFile = nil;
  
  TPEngineCompiler projectType = [self engineProjectType:self];
  //    NSString *projectType = [self.project valueForKey:@"type"];
  if (projectType == TPEngineCompilerPDFLaTeX) {
    docFile = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
  } else {
    if (didPS2PDF) {
      docFile = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
    } else {
      docFile = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"ps"];
    }
  } 
  
  // check if the pdf exists
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:docFile]) {
    return docFile;
  }
  
  return nil;
}

- (BOOL) build
{
  
	ConsoleController *console = [ConsoleController sharedConsoleController];
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:OpenConsoleOnTypeset] boolValue]) {
		[console showWindow:self];
		[[console window] makeKeyAndOrderFront:self];
	}
	
	NSString *mainFile = [self engineDocumentToCompile:self];
	NSString *pdfFile = [[mainFile stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
  
	if (!mainFile) {
    
		//NSLog(@"Specify a main file!");
		[console error:@"No main file specified!"];	
		
    NSAlert *alert = nil;
    if ([self engineDocumentIsProject:self]) {
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
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSString *texpath;
  
  TPEngineCompiler projectType = [self engineProjectType:self];
  if (projectType == TPEngineCompilerPDFLaTeX) {
    texpath = [defaults valueForKey:TPPDFLatexPath]; 
  } else if (projectType == TPEngineCompilerLaTeX) {
    texpath = [defaults valueForKey:TPLatexPath]; 
  } else {
    return NO;
  }
  
  [console message:[NSString stringWithFormat:@"Compiling with %@", texpath]];
	
	typesetTask = [[NSTask alloc] init];
	
	[typesetTask setLaunchPath:texpath];
  [typesetTask setCurrentDirectoryPath:[self engineWorkingDirectory:self]];
  
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
      ([self engineProjectType:self] == TPEngineCompilerLaTeX)) {
    // do dvips
    [self dvips:self];
  }
  
	if (compilationsDone < nCompile) {
		[self build];
	} else {
		ConsoleController *console = [ConsoleController sharedConsoleController];
		NSString *mainFile = [self engineDocumentToCompile:self];
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

#pragma mark -
#pragma mark Delegate

- (NSString*) engineDocumentToCompile:(TPLaTeXEngine*)anEngine
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(engineDocumentToCompile:)]) {
    return [self.delegate engineDocumentToCompile:self];
  }
  return nil;
}

- (NSString*) engineWorkingDirectory:(TPLaTeXEngine*)anEngine
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(engineWorkingDirectory:)]) {
    return [self.delegate engineWorkingDirectory:self];
  }
  return nil;
}

- (BOOL) engineCanBibTeX:(TPLaTeXEngine*)anEngine
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(engineCanBibTeX:)]) {
    return [self.delegate engineCanBibTeX:self];
  }
  return NO;
}

- (TPEngineCompiler) engineProjectType:(TPLaTeXEngine*)anEngine
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(engineProjectType:)]) {
    return [self.delegate engineProjectType:self];
  }
  return TPEngineCompilerPDFLaTeX;
}

- (BOOL) engineDocumentIsProject:(TPLaTeXEngine*)anEngine 
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(engineDocumentIsProject:)]) {
    return [self.delegate engineDocumentIsProject:self];
  }
  return NO;
}

@end
