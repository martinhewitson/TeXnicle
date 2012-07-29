//
// Taken from http://www.cocoadev.com/index.pl?NotificationsAcrossThreads
//


#import "NSNotificationAdditions.h"
#import <pthread.h>

@implementation NSNotificationCenter (NSNotificationCenterAdditions)
- (void) postNotificationOnMainThread:(NSNotification *) notification {
	if( pthread_main_np() ) return [self postNotification:notification];
	[self postNotificationOnMainThread:notification waitUntilDone:NO];
}

- (void) postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait {
	if( pthread_main_np() ) return [self postNotification:notification];
	[[self class] performSelectorOnMainThread:@selector( _postNotification: ) withObject:notification waitUntilDone:wait];
}

+ (void) _postNotification:(NSNotification *) notification {
	[[self defaultCenter] postNotification:notification];
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object {
	if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:nil];
	[self postNotificationOnMainThreadWithName:name object:object userInfo:nil waitUntilDone:NO];
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo {
	if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:userInfo];
	[self postNotificationOnMainThreadWithName:name object:object userInfo:userInfo waitUntilDone:NO];
}

- (void) postNotificationOnMainThreadWithName:(NSString *) name object:(id) object userInfo:(NSDictionary *) userInfo waitUntilDone:(BOOL) wait {
	if( pthread_main_np() ) return [self postNotificationName:name object:object userInfo:userInfo];

	NSMutableDictionary *info = [[NSMutableDictionary allocWithZone:nil] initWithCapacity:3];
	if( name ) info[@"name"] = name;
	if( object ) info[@"object"] = object;
	if( userInfo ) info[@"userInfo"] = userInfo;

	[[self class] performSelectorOnMainThread:@selector( _postNotificationName: ) withObject:info waitUntilDone:wait];

}

+ (void) _postNotificationName:(NSDictionary *) info {
	NSString *name = info[@"name"];
	id object = info[@"object"];
	NSDictionary *userInfo = info[@"userInfo"];

	[[self defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}
@end
