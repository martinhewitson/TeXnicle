//
//  TPTemplateEditorView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "TPTemplateEditorView.h"
#import "externs.h"

@implementation TPTemplateEditorView

@synthesize templateCodeView;
@synthesize templateTable;
@synthesize templateArrayController;

- (id)init
{
  self = [super initWithNibName:@"TPTemplateEditorView" bundle:nil];
  if (self) {
    // Initialization code here.
  }
  
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

- (void) awakeFromNib
{
  // Get the templates from the user defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	
	NSFont *font = [NSUnarchiver unarchiveObjectWithData:[defaults valueForKey:TEDocumentFont]];	
	[self.templateCodeView setFont:font];
	
  // observe template table
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(templateSelectionChanged:) 
                                               name:NSTableViewSelectionDidChangeNotification
                                             object:self.templateTable];
  
}

- (void) templateSelectionChanged:(NSNotification*)aNote
{
  NSArray *selectedObjects = [self.templateArrayController selectedObjects];
  if ([selectedObjects count] == 1) {
    [templateCodeView scrollRectToVisible:NSZeroRect];
    [templateCodeView performSelector:@selector(colorVisibleText)
                           withObject:nil
                           afterDelay:0.1];
    [templateCodeView performSelector:@selector(colorWholeDocument)
                           withObject:nil
                           afterDelay:0.2];
  }
}

- (NSDictionary*)selectedTemplate
{
  NSArray *selectedObjects = [self.templateArrayController selectedObjects];
  if ([selectedObjects count] > 0) {
    return [selectedObjects objectAtIndex:0];
  }
  return nil;
}

- (IBAction) addNewTemplate:(id)sender
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSString stringWithFormat:@"New Template %d", [[self.templateArrayController arrangedObjects] count]]
					forKey:@"Name"];
	[dict setValue:@"New empty template" forKey:@"Description"];
	
	[self.templateArrayController insertObject:dict atArrangedObjectIndex:0];
	[self.templateArrayController setSelectionIndex:0];	
}


#pragma mark -
#pragma mark textview delegate



#pragma mark -
#pragma mark table view delegate






@end
