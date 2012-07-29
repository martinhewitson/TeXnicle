//
//  TPProjectTemplateListViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/2/12.
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

#import "TPProjectTemplateListViewController.h"
#import "TPProjectTemplateCreator.h"

@interface TPProjectTemplateListViewController ()

@end

@implementation TPProjectTemplateListViewController

@synthesize templates;
@synthesize tableView;


- (id)init
{
  self = [super initWithNibName:@"TPProjectTemplateListViewController" bundle:nil];
  if (self) {
    // Initialization code here.
    self.templates = [NSMutableArray array];
    [self generateTemplateList];
  }
  
  return self;
}


- (void) generateTemplateList
{
  [self.templates removeAllObjects];
  NSString *templatesDir = [TPProjectTemplateCreator projectTemplatesDirectory];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *contents = [fm contentsOfDirectoryAtPath:templatesDir error:&error];
  if (contents == nil) {
    [NSApp presentError:error];
    return;
  }
  
  for (NSString *path in contents) {
    NSString *filepath = [templatesDir stringByAppendingPathComponent:path];
    error = nil;
    NSDictionary *attrs = [fm attributesOfItemAtPath:filepath error:&error];
    if ([[attrs fileType] isEqualToString:NSFileTypeDirectory] && [[path pathExtension] isEqualToString:@"tpt"]) {
      TPProjectTemplate *t = [[TPProjectTemplate alloc] initWithPath:filepath];
      [self.templates addObject:t];
    }
  }
}

- (TPProjectTemplate*)selectedTemplate
{
  NSInteger row = [self.tableView selectedRow];
  if (row >=0 && row < [self.templates count]) {
    return [self.templates objectAtIndex:row];
  }
  return nil;
}

- (void) refreshList
{
  [self generateTemplateList];
  [self.tableView reloadData];
}

#pragma mark -
#pragma mark Tableview data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
  return [self.templates count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
  if (row < [self.templates count]) {
    TPProjectTemplate *template = [self.templates objectAtIndex:row];
    if ([[tableColumn identifier] isEqualToString:@"NameColumn"]) {
      return template.name;
    } else if ([[tableColumn identifier] isEqualToString:@"DescriptionColumn"]) {
      return template.description;
    } else {
      // nothing
      return nil;
    }
  }
  
  return nil;
}

#pragma mark -
#pragma mark Tableview delegate

@end
