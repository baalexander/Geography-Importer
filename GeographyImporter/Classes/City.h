#import <CoreData/CoreData.h>

@class State;

@interface City :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) State * state;

@end



