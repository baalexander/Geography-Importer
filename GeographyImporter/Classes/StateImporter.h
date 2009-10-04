@class AppDelegate;

@interface StateImporter : NSOperation
{
    AppDelegate *delegate_;
    NSManagedObjectContext *managedObjectContext_;
}

@property (nonatomic, assign) AppDelegate *delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithDelegate:(AppDelegate*)delegate;

@end
