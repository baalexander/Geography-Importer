#import <CoreData/CoreData.h>


@interface State :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSSet* cities;

@end


@interface State (CoreDataGeneratedAccessors)
- (void)addCitiesObject:(NSManagedObject *)value;
- (void)removeCitiesObject:(NSManagedObject *)value;
- (void)addCities:(NSSet *)value;
- (void)removeCities:(NSSet *)value;

@end

