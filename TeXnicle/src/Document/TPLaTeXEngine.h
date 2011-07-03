//
//  TPLaTeXEngine.h
//  TeXnicle
//
//  Created by Martin Hewitson on 29/05/11.
//  Copyright 2011 AEI Hannover . All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const TPTypesettingCompletedNotification;

@class ProjectEntity;

@interface TPLaTeXEngine : NSObject {
@private
    
	// Typesetting
	NSTask *typesetTask;
	NSFileHandle *typesetFileHandle;
	BOOL openPDFAfterBuild;
	int compilationsDone;
	BOOL abortCompile;
	
	// BibTeX
	NSTask *bibtexTask;
	NSFileHandle *bibtexFileHandle;
	
	// dvips
	NSTask *dvipsTask;
	NSFileHandle *dvipsFileHandle;
  
  ProjectEntity *project;
}

@property (assign) ProjectEntity *project;

- (id) initWithProject:(ProjectEntity*)aProject;
+ (TPLaTeXEngine*) engineWithProject:(ProjectEntity*)aProject;

- (void) reset;
- (BOOL) build;

@end
