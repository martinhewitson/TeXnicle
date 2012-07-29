//
//  TPProjectTemplateViewer.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
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

#import <Cocoa/Cocoa.h>
#import "ProjectEntity.h"
#import "TPTemplateDirectory.h"
#import "TPTemplateFile.h"
#import "TeXEditorViewController.h"

@class TPProjectTemplateViewer;

@protocol TPProjectTemplateViewerDelegate <NSObject>

-(void)templateViewer:(TPProjectTemplateViewer*)viewer didCreateProject:(id)doc;
-(void)templateViewerDidCancelProjectCreation:(TPProjectTemplateViewer*)viewer;

@end

@interface TPProjectTemplateViewer : NSDocument <NSTextViewDelegate, NSSplitViewDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource> {
@private
  ProjectEntity *project;
  NSManagedObjectContext *managedObjectContext;
  TPTemplateDirectory *root;
  NSOutlineView *__unsafe_unretained outlineView;
  TeXEditorViewController *texEditorViewController;
  NSView *__unsafe_unretained texEditorContainer;
  
  NSView *__unsafe_unretained leftView;
  NSView *__unsafe_unretained rightView;
  
  NSView *__unsafe_unretained projectNameView;
  NSTextField *__unsafe_unretained projectNameField;
  
  NSString *templateName;
  NSString *templateDescription;
  NSTextField *__unsafe_unretained templateDescriptionDisplay;
  
  TPTemplateItem *selectedItem;
  
  id<TPProjectTemplateViewerDelegate> __unsafe_unretained delegate;
}

@property (unsafe_unretained) id<TPProjectTemplateViewerDelegate> delegate;
@property (strong) ProjectEntity *project;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (strong) TPTemplateDirectory *root;
@property (unsafe_unretained) IBOutlet NSTextField *templateDescriptionDisplay;
@property (unsafe_unretained) IBOutlet NSOutlineView *outlineView;
@property (unsafe_unretained) IBOutlet NSView *projectNameView;
@property (unsafe_unretained) IBOutlet NSTextField *projectNameField;
@property (copy) NSString *templateName;
@property (copy) NSString *templateDescription;

@property (unsafe_unretained) IBOutlet NSView *leftView;
@property (unsafe_unretained) IBOutlet NSView *rightView;

@property (strong) TeXEditorViewController *texEditorViewController;
@property (unsafe_unretained) IBOutlet NSView *texEditorContainer;

- (id)initWithProject:(ProjectEntity*)aProject name:(NSString*)aName description:(NSString*)aDescription;
- (BOOL) savePackageContentsFromProject;
- (void) readFileTreeFromURL:(NSURL*)absoluteURL;

- (TPTemplateFile*)selectedFile;
- (IBAction)createNewProject:(id)sender;
- (NSFileWrapper*)wrapperForItem:(TPTemplateItem*)item;
- (void) commitCurrentTextViewContents;

@end
