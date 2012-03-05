//
//  ProjectEntity+ProjectTemplates.m
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "ProjectEntity+ProjectTemplates.h"
#import "TPProjectTemplateCreator.h"
#import "TPProjectTemplateViewer.h"

@implementation ProjectEntity (ProjectTemplates)

- (void) saveTemplateBundleWithName:(NSString*)aName description:(NSString*)aDescription toURL:(NSURL*)url
{
  TPProjectTemplateViewer *viewer = [[TPProjectTemplateViewer alloc] initWithProject:self name:aName description:aDescription];
  [viewer makeWindowControllers];
  [viewer showWindows];
    
  [viewer saveToURL:url ofType:@"tpt" forSaveOperation:NSSaveAsOperation completionHandler:^(NSError *errorOrNil) {
    // write package contents
    [viewer savePackageContentsFromProject];
    [viewer readFileTreeFromURL:[viewer fileURL]];
  }];
  
}

@end
