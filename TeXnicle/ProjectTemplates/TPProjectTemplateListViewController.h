//
//  TPProjectTemplateListViewController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 21/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPProjectTemplate.h"

@interface TPProjectTemplateListViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource> {
@private
  NSMutableArray *templates;  
  NSTableView *tableView;
}

@property (assign) IBOutlet NSTableView *tableView;
@property (retain) NSMutableArray *templates;

- (void) generateTemplateList;
- (TPProjectTemplate*)selectedTemplate;
- (void) refreshList;

@end
