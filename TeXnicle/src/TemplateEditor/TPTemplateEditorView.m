//
//  TPTemplateEditorView.m
//  TeXnicle
//
//  Created by Martin Hewitson on 28/1/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPTemplateEditorView.h"
#import "externs.h"

@implementation TPTemplateEditorView

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
    [self.templateCodeView scrollRectToVisible:NSZeroRect];
    [self.templateCodeView performSelector:@selector(colorVisibleText)
                                withObject:nil
                                afterDelay:0.1];
    [self.templateCodeView performSelector:@selector(colorWholeDocument)
                                withObject:nil
                                afterDelay:0.2];
  }
}

- (NSDictionary*)selectedTemplate
{
  NSArray *selectedObjects = [self.templateArrayController selectedObjects];
  if ([selectedObjects count] > 0) {
    return selectedObjects[0];
  }
  return nil;
}

- (IBAction) addNewTemplate:(id)sender
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSString stringWithFormat:@"New Template %lu", [[self.templateArrayController arrangedObjects] count]]
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
