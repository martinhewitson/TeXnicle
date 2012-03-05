//
//  ProjectEntity+ProjectTemplates.h
//  TeXnicle
//
//  Created by Martin Hewitson on 15/2/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
//

#import "ProjectEntity.h"

@interface ProjectEntity (ProjectTemplates)

- (void) saveTemplateBundleWithName:(NSString*)aName description:(NSString*)aDescription toURL:(NSURL*)url;



@end
