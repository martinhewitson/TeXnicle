//
//  TPProjectTemplateListViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 21/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

- (void) dealloc
{
  self.templates = nil;
  [super dealloc];
}

- (void) generateTemplateList
{
  [self.templates removeAllObjects];
  NSString *templatesDir = [TPProjectTemplateCreator projectTemplatesDirectory];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *contents = [fm contentsOfDirectoryAtPath:templatesDir error:&error];
  if (error) {
    [NSApp presentError:error];
    return;
  }
  
  for (NSString *path in contents) {
    NSString *filepath = [templatesDir stringByAppendingPathComponent:path];
    error = nil;
    NSDictionary *attrs = [fm attributesOfItemAtPath:filepath error:&error];
    if ([[attrs fileType] isEqualToString:NSFileTypeDirectory] && [[path pathExtension] isEqualToString:@"tpt"]) {
      TPProjectTemplate *t = [[[TPProjectTemplate alloc] initWithPath:filepath] autorelease];
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
