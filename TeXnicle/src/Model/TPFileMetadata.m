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
    [self triggerSyntaxCheck];
  } else if ([keyPath hasPrefix:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]]) {
    [self triggerSyntaxCheck];
  }
}

- (void) triggerSyntaxCheck
{
  if (self.needsSyntaxCheck == YES) {
    // delay until we syntax checking is finished
    [self performSelector:@selector(triggerSyntaxCheck) withObject:nil afterDelay:1];
  } else {
    self.needsSyntaxCheck = YES;
  }
}


- (NSString*) description
{
  return [NSString stringWithFormat:@"<%@ %p>: %@, scanned? %d, needsUpdate? %d", [self class], self, self.name, self.wasScannedForSections, self.needsUpdate];
}

- (void) tearDown
{
#if TEAR_DOWN
  NSLog(@"Tear down %@", self);
#endif
  NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntaxErrors]];
  [defaults removeObserver:self forKeyPath:[NSString stringWithFormat:@"values.%@", TPCheckSyntax]];
  self.delegate = nil;
  [self.currentOperation cancel];
  self.currentOperation = nil;
  [self.aQueue cancelAllOperations];
  [self.checker tearDown];
}

- (void) notifyOfUpdate
{
  if (self && self.currentOperation) {
    self.needsUpdate = NO;
    self.lastUpdate = [NSDate date];
    self.userNewCommands = self.currentOperation.commands;
    self.userNewEnvironments = self.currentOperation.environments;
    self.citations = self.currentOperation.citations;
    self.labels = self.currentOperation.labels;
    
    [self postUpdateNotification];
  }
}

- (void) postUpdateNotification
{
  [self fileMetadataDidUpdate:self];
  
  // send notification of update
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:TPFileMetadataUpdatedNotification object:self];
}

- (void) updateMetadata
{
  __block TPFileMetadata *blockSelf = self;  
  if (self.needsUpdate) {
    //NSLog(@"   updating %@", self);
    if ([self.aQueue operationCount] == 0) {
      self.currentOperation = [[TPMetadataOperation alloc] initWithFile:self];
      [self.currentOperation setCompletionBlock:^{
        //NSLog(@"operation completed for %@", blockSelf);
        dispatch_sync(dispatch_get_main_queue(), ^{
          [blockSelf notifyOfUpdate];
          blockSelf = nil;
        });
      }];
      
      self.needsUpdate = NO;
      [self.aQueue addOperation:self.currentOperation];
    } else {
      self.needsUpdate = NO;
      [self notifyOfUpdate];
    }
  }
  
  if (self.needsSyntaxCheck) {
    
    //-------------- syntax errors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:TPCheckSyntax] boolValue] == YES) {
      if ([self.extension isEqualToString:@"tex"]) {
        NSString *path = [NSString pathForTemporaryFileWithPrefix:@"chktek"];
        if ([self.text writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL]) {
          self.temporaryFileForSyntaxCheck = path;
          self.needsSyntaxCheck = NO;
          [self.checker checkSyntaxOfFileAtPath:self.temporaryFileForSyntaxCheck];
        } 
      } else {
        // clear errors
        self.syntaxErrors = @[];
        self.needsSyntaxCheck = NO;
        [self postUpdateNotification];
      }
    } else {
      // clear errors
      self.syntaxErrors = @[];
      self.needsSyntaxCheck = NO;
      [self postUpdateNotification];
    }    
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
  [self postUpdateNotification];
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
