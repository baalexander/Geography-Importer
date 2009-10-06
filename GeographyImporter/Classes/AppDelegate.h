#import <Cocoa/Cocoa.h>


/**
 * Handles the selecting and importing actions by the user.
 */
@interface AppDelegate : NSObject 
{
    NSWindow *window_;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
    NSManagedObjectModel *managedObjectModel_;
    NSManagedObjectContext *managedObjectContext_;
    
    BOOL importing_;
    NSString *stateFilePath_;
    NSString *cityFilePath_;
    NSOperationQueue *queue_;
}

@property (nonatomic, retain) IBOutlet NSWindow *window;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign, getter=isImporting) BOOL importing;
@property (nonatomic, retain) NSString *stateFilePath;
@property (nonatomic, retain) NSString *cityFilePath;

- (IBAction)saveAction:(id)sender;
- (IBAction)chooseStateFile:(id)sender;
- (IBAction)chooseCityFile:(id)sender;
- (IBAction)importState:(id)sender;
- (IBAction)importCity:(id)sender;

- (void)mergeChanges:(NSNotification*)notification;
- (void)importDone;

@end
