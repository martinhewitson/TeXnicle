//
//  TPFileMetaData.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/3/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPFileMetadata.h"
#import "TPMetadataOperation.h"
#import "TPSyntaxError.h"
#import "NSString+LaTeX.h"
#import "NSString+SectionsOutline.h"
#import "externs.h"

@interface TPFileMetadata ()

@property (strong) TPSyntaxChecker *checker;
@property (copy) NSString *temporaryFileForSyntaxCheck;

@property (assign) BOOL needsSyntaxCheck;

@property (strong) NSOperationQueue* aQueue;
@property (strong) TPMetadataOperation *currentOperation;

@end

@implementation TPFileMetadata

- (id) initWithParentId:(NSManagedObjectID*)objId extension:(NSString*)ext text:(NSString*)text path:(NSString*)pathOnDisk projectPath:(NSString *)pathRelativeToProject name:(NSString*)aName
{
  self = [super init];
  if (self) {
    self.objId = objId;
    self.extension = ext;
    self.text = text;
    self.pathOnDisk = pathOnDisk;
    self.projectPath = pathRelativeToProject;
    self.aQueue = [[NSOperationQueue alloc] init];
    self.name = aName;
    self.checker = [[TPSyntaxChecker alloc] initWithDelegate:self];
    
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

    [defaults addObserver:self
               forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]
                  options:NSKeyValueObservingOptionNew
                  context:NULL];

    [defaults addObserver:self
               forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    // if the project path has no extension, assume .tex
    if ([self.projectPath length] > 0 && [[self.projectPath pathExtension] length] == 0) {
      self.projectPath = [self.projectPath stringByAppendingPathExtension:@"tex"];
    }

    
  }
  
  return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
											ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]]) {
    self.needsSyntaxCheck = YES;
  } else if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]]) {
    self.needsSyntaxCheck = YES;
  }
}

- (NSString*) description
{
  return [NSString stringWithFormat:@"<%@ %p>: %@, scanned? %d", [self class], self, self.name, self.wasScannedForSections];
}

- (void) tearDown
{
  NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]];
  self.delegate = nil;
  [self.currentOperation cancel];
  self.currentOperation = nil;
  [self.aQueue cancelAllOperations];
}

- (void) notifyOfUpdate
{
  if (self && self.currentOperation) {
    self.needsUpdate = NO;
    self.lastUpdate = [NSDate date];
    self.userNewCommands = self.currentOperation.commands;
    self.citations = self.currentOperation.citations;
    self.labels = self.currentOperation.labels;
    
    [self fileMetadataDidUpdate:self];    
    [self postUpdateNotification];
  }
}

- (void) postUpdateNotification
{
  // send notification of update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:TPFileMetadataUpdatedNotification object:self];
}

- (void) updateMetadata
{
  __block TPFileMetadata *blockSelf = self;
  BOOL doSyntaxCheck = self.needsUpdate | self.needsSyntaxCheck;
  
  if (self.needsUpdate) {
    if ([self.aQueue operationCount] == 0) {
      self.currentOperation = [[TPMetadataOperation alloc] initWithFile:self];
      [self.currentOperation setCompletionBlock:^{
        dispatch_sync(dispatch_get_main_queue(), ^{
          [blockSelf notifyOfUpdate];
          blockSelf = nil;
        });
      }];
      
      [self.aQueue addOperation:self.currentOperation];
    }
  }
  
  if (doSyntaxCheck) {
    //-------------- syntax errors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:TPCheckSyntax] boolValue] == YES) {
      if ([self.extension isEqualToString:@"tex"]) {
        NSString *path = [NSString pathForTemporaryFileWithPrefix:@"chktek"];
        if ([self.text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
          self.temporaryFileForSyntaxCheck = path;
          [self.checker checkSyntaxOfFileAtPath:self.temporaryFileForSyntaxCheck];
        }
      }
    } else {
      // clear errors
      self.syntaxErrors = @[];
      [self postUpdateNotification];
    }
    
    self.needsSyntaxCheck = NO;
  }
  
}

- (void) fileMetadataDidUpdate:(TPFileMetadata *)file
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(fileMetadataDidUpdate:)]) {
    [self.delegate fileMetadataDidUpdate:self];
  }
}

#pragma mark -
#pragma mark Sections

- (NSArray*) generateSectionsForTypes:(NSArray*)templates files:(NSArray*)otherFiles forceUpdate:(BOOL)force
{
  // we have to update all sections for this file because we look for other files included from
  // here, and they might have changed. So, the only case where we don't need to update is if no
  // files have changed. Is that really worth checking?
  
  [self updateSectionsForTypes:templates files:otherFiles forceUpdate:force];
  
  return self.sections;
}


- (void)updateSectionsForTypes:(NSArray*)templates files:(NSArray*)otherFiles forceUpdate:(BOOL)force
{
  // get the parent file and the text to search
  self.sections = [self.text sectionsInStringForTypes:templates existingSections:self.sections inFile:self knownFiles:otherFiles];
}

#pragma mark -
#pragma mark Syntax checking

- (void) cleanup
{
  NSFileManager *fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:self.temporaryFileForSyntaxCheck]) {
    [fm removeItemAtPath:self.temporaryFileForSyntaxCheck error:NULL];
  }
}

- (void)syntaxCheckerCheckFailed:(TPSyntaxChecker*)checker
{
  [self cleanup];
}

- (void)syntaxCheckerCheckDidFinish:(TPSyntaxChecker*)aChecker
{
  [self cleanup];
  self.syntaxErrors = aChecker.errors;
  for (TPSyntaxError *error in self.syntaxErrors) {
    error.file = self;
  }
  [self postUpdateNotification];
}

- (BOOL)syntaxCheckerShouldCheckSyntax:(TPSyntaxChecker*)checker
{
  return YES;
}


@end
