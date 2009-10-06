@class AppDelegate;

/**
 * Imports a list of cities into Core Data.
 */
@interface CityImporter : NSOperation
{
    AppDelegate *delegate_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, assign) AppDelegate *delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithDelegate:(AppDelegate*)delegate;

@end
