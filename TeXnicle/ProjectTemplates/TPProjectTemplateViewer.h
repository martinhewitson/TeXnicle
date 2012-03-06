//
//  TPProjectTemplateViewer.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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
  NSOutlineView *outlineView;
  TeXEditorViewController *texEditorViewController;
  NSView *texEditorContainer;
  
  NSView *leftView;
  NSView *rightView;
  
  NSView *projectNameView;
  NSTextField *projectNameField;
  
  NSString *templateName;
  NSString *templateDescription;
  NSTextField *templateDescriptionDisplay;
  
  TPTemplateItem *selectedItem;
  
  id<TPProjectTemplateViewerDelegate> delegate;
}

@property (assign) id<TPProjectTemplateViewerDelegate> delegate;
@property (retain) ProjectEntity *project;
@property (retain) NSManagedObjectContext *managedObjectContext;
@property (retain) TPTemplateDirectory *root;
@property (assign) IBOutlet NSTextField *templateDescriptionDisplay;
@property (assign) IBOutlet NSOutlineView *outlineView;
@property (assign) IBOutlet NSView *projectNameView;
@property (assign) IBOutlet NSTextField *projectNameField;
@property (copy) NSString *templateName;
@property (copy) NSString *templateDescription;

@property (assign) IBOutlet NSView *leftView;
@property (assign) IBOutlet NSView *rightView;

@property (retain) TeXEditorViewController *texEditorViewController;
@property (assign) IBOutlet NSView *texEditorContainer;

- (id)initWithProject:(ProjectEntity*)aProject name:(NSString*)aName description:(NSString*)aDescription;
- (BOOL) savePackageContentsFromProject;
- (void) readFileTreeFromURL:(NSURL*)absoluteURL;

- (TPTemplateFile*)selectedFile;
- (IBAction)createNewProject:(id)sender;
- (NSFileWrapper*)wrapperForItem:(TPTemplateItem*)item;
- (void) commitCurrentTextViewContents;

@end
