//
//  TPProjectTemplateCreator.h
//  TeXnicle
//
//  Created by Martin Hewitson on 14/02/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TPOutlineView;
@class ProjectItemTreeController;
@class ProjectEntity;

@protocol TPProjectTemplateCreateDelegate <NSObject>

- (ProjectEntity*)project;
- (NSManagedObjectContext*)managedObjectContext;

@end

@interface TPProjectTemplateCreator : NSWindowController <NSWindowDelegate> {
@private
  id<TPProjectTemplateCreateDelegate> delegate;
  NSManagedObjectContext *managedObjectContext;
  TPOutlineView *outlineView;
  ProjectItemTreeController *treeController;
  NSTextField *templateNameTextField;
  NSString *suggestedTemplateName;
  NSTextField *templateDescriptionField;
  NSString *suggestedTemplateDescription;
}

@property (assign) id<TPProjectTemplateCreateDelegate> delegate;
@property (assign) NSManagedObjectContext *managedObjectContext;
@property (assign) IBOutlet TPOutlineView *outlineView;
@property (assign) IBOutlet ProjectItemTreeController *treeController;
@property (assign) IBOutlet NSTextField *templateNameTextField;
@property (copy) NSString *suggestedTemplateName;
@property (assign) IBOutlet NSTextField *templateDescriptionField;
@property (copy) NSString *suggestedTemplateDescription;

+ (NSString*) projectTemplatesDirectory;

- (id) initWithDelegate:(id<TPProjectTemplateCreateDelegate>)aDelegate;

- (void)setSuggestedTemplateName:(NSString*)aname;

- (IBAction)selectAllFiles:(id)sender;
- (IBAction)deselectAllFiles:(id)sender;

- (IBAction)cancelCreation:(id)sender;
- (IBAction)createTemplate:(id)sender;

- (void) createTemplateWithName:(NSString*)aName project:(ProjectEntity*)aProject;
- (void) overwriteAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
