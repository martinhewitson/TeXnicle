//
//  TPProjectTemplateCreator.m
//  TeXnicle
//
//  Created by Martin Hewitson on 14/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//
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

#import "TPProjectTemplateCreator.h"
#import "TPOutlineView.h"
#import "ProjectItemTreeController.h"
#import "NSArray_Extensions.h"
#import "NSTreeController_Extensions.h"
#import "NSTreeNode_Extensions.h"
#import "NSIndexPath_Extensions.h"
#import "MABSupportFolder.h"
#import "ProjectEntity.h"
#import "ProjectEntity+ProjectTemplates.h"

@interface TPProjectTemplateCreator ()

@property (unsafe_unretained) NSManagedObjectContext *managedObjectContext;
@property (unsafe_unretained) IBOutlet TPOutlineView *outlineView;
@property (unsafe_unretained) IBOutlet ProjectItemTreeController *treeController;
@property (unsafe_unretained) IBOutlet NSTextField *templateNameTextField;
@property (unsafe_unretained) IBOutlet NSTextField *templateDescriptionField;

@end

@implementation TPProjectTemplateCreator

+ (NSString*) projectTemplatesDirectory
{
  MABSupportFolder *sf = [MABSupportFolder sharedController];
  return [[sf supportFolder] stringByAppendingPathComponent:@"projectTemplates"];
}

- (id) initWithDelegate:(id<TPProjectTemplateCreateDelegate>)aDelegate
{
  self = [super initWithWindowNibName:@"TPProjectTemplateCreator"];
  if (self) {
    self.delegate = aDelegate;
    if (self.delegate && [self.delegate respondsToSelector:@selector(managedObjectContext)]) {
      self.managedObjectContext = [self.delegate managedObjectContext];
    }
  }
  
  return self;
}

- (void) dealloc
{
  self.delegate = nil;
}

- (void)windowDidLoad
{
  [super windowDidLoad];
  
  // disable stuff on the outline view
  self.outlineView.showMenu = NO;
  self.treeController.dragEnabled = NO;
  
  // select all
  [self selectAllFiles:self];
}

- (IBAction)selectAllFiles:(id)sender
{
	for (NSTreeNode *node in [self.treeController flattenedNodes]) {
    [[node representedObject] setValue:@YES forKey:@"isSelected"];
  }
}

- (IBAction)deselectAllFiles:(id)sender
{
	for (NSTreeNode *node in [self.treeController flattenedNodes]) {
    [[node representedObject] setValue:@NO forKey:@"isSelected"];
  }
}

- (IBAction)cancelCreation:(id)sender
{
  [NSApp endSheet:self.window];
  [self.window orderOut:self];
}

- (IBAction)createTemplate:(id)sender
{  
  // get project template name
  NSString *templateName = [self.templateNameTextField stringValue];

  // create template
  [self createTemplateWithName:templateName project:[self.delegate project]];
  
}

- (void) createTemplateWithName:(NSString*)aName project:(ProjectEntity*)aProject
{
  NSFileManager *fm = [NSFileManager defaultManager];
  
  // path to templates
  NSString *templatesDir = [TPProjectTemplateCreator projectTemplatesDirectory];
  
  // Create directory for templates
  NSError *error = nil;
  [fm createDirectoryAtPath:templatesDir withIntermediateDirectories:YES attributes:nil error:&error];
  if (error != nil) {
    [NSApp presentError:error];
    return;
  }
    
  // check if a template with this name exists
  NSURL *url = [[NSURL fileURLWithPath:[templatesDir stringByAppendingPathComponent:aName]] URLByAppendingPathExtension:@"tpt"];  
  if ([fm fileExistsAtPath:[url path]]) {
    
    // ask the user if they want to overwrite
    NSAlert *alert = [NSAlert alertWithMessageText:@"Template Exists"
                                     defaultButton:@"Cancel"
                                   alternateButton:@"Overwrite"
                                       otherButton:nil
                         informativeTextWithFormat:@"A template with the name \u201c%@\u201d already exists. Overwrite it?", aName];
    
    [alert beginSheetModalForWindow:self.window 
                      modalDelegate:self
                     didEndSelector:@selector(overwriteAlertDidEnd:returnCode:contextInfo:) 
                        contextInfo:(__bridge void *)(url)];
    
  } else {
  
    // create template bundle
    [[self.delegate project] saveTemplateBundleWithName:aName description:self.templateDescriptionField.stringValue toURL:url];
    
    [NSApp endSheet:self.window];
    [self.window orderOut:self];
  }  
  
}

- (void) overwriteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
  if (returnCode == NSAlertDefaultReturn) {
    // do nothing
    return;
  }
  
  // create template bundle
  NSURL *url = (__bridge NSURL*)contextInfo;
  [[self.delegate project] saveTemplateBundleWithName:[self.templateNameTextField stringValue]
                                          description:[self.templateDescriptionField stringValue]
                                                toURL:url];
  
  [NSApp endSheet:self.window];
  [self.window orderOut:self];
}



@end
