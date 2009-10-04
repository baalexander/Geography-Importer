#import "AppDelegate.h"

#import "StateImporter.h"
#import "CityImporter.h"


@interface AppDelegate ()
@property (nonatomic, retain, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readwrite) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSOperationQueue *queue;
@end


@implementation AppDelegate

@synthesize window = window_;
@synthesize managedObjectContext = managedObjectContext_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize stateFilePath = stateFilePath_;
@synthesize cityFilePath = cityFilePath_;
@synthesize importing = importing_;
@synthesize queue = queue_;

- (void)dealloc
{
    [window_ release];
    [managedObjectContext_ release];
    [persistentStoreCoordinator_ release];
    [managedObjectModel_ release];
	
    [super dealloc];
}

- (NSString *)applicationSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();

    return [basePath stringByAppendingPathComponent:@"GeographyImporter"];
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel_ == nil)
    {
        [self setManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
    }

    return managedObjectModel_;
}


- (NSPersistentStoreCoordinator *) persistentStoreCoordinator
{
    if (persistentStoreCoordinator_ == nil)
    {
        NSManagedObjectModel *mom = [self managedObjectModel];
        if (!mom)
        {
            NSAssert(NO, @"Managed object model is nil");
            NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);

            return nil;
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *applicationSupportDirectory = [self applicationSupportDirectory];
        NSError *error = nil;
        
        if (![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL])
        {
            if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error])
            {
                NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory, error]));
                NSLog(@"Error creating application support directory at %@ : %@", applicationSupportDirectory, error);
                
                return nil;
            }
        }
        
        NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent:@"Geography.sqlite"]];
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        [self setPersistentStoreCoordinator:persistentStoreCoordinator];
        [persistentStoreCoordinator release];

        if (![[self persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil 
                                                                       URL:url 
                                                                   options:nil 
                                                                     error:&error])
        {
            [[NSApplication sharedApplication] presentError:error];
            [persistentStoreCoordinator_ release], persistentStoreCoordinator_ = nil;

            return nil;
        }
    }

    return persistentStoreCoordinator_;
}

- (NSManagedObjectContext *) managedObjectContext
{
    if (managedObjectContext_ == nil)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (!coordinator)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
            [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
            NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            [[NSApplication sharedApplication] presentError:error];

            return nil;
        }

        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [self setManagedObjectContext:managedObjectContext];
        [managedObjectContext release];
        
        [[self managedObjectContext] setPersistentStoreCoordinator:coordinator];    
    }
    
    return managedObjectContext_;
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}


- (IBAction) saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing])
    {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)chooseStateFile:(id)sender;
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel beginSheetForDirectory:nil 
                                 file:nil 
                                types:[NSArray arrayWithObject:@"csv"] 
                       modalForWindow:[self window] 
                        modalDelegate:self 
                       didEndSelector:@selector(stateFileOpenDidEnd:returnCode:context:) 
                          contextInfo:nil];
}

- (void)stateFileOpenDidEnd:(NSOpenPanel*)openPanel returnCode:(NSInteger)code context:(void*)context 
{
    if (code == NSCancelButton)
    {
        return;
    }
    
    [self setStateFilePath:[openPanel filename]];
}

- (IBAction)chooseCityFile:(id)sender;
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel beginSheetForDirectory:nil 
                                 file:nil 
                                types:[NSArray arrayWithObject:@"csv"] 
                       modalForWindow:[self window] 
                        modalDelegate:self 
                       didEndSelector:@selector(cityFileOpenDidEnd:returnCode:context:) 
                          contextInfo:nil];
}

- (void)cityFileOpenDidEnd:(NSOpenPanel*)openPanel returnCode:(NSInteger)code context:(void*)context 
{
    if (code == NSCancelButton)
    {
        return;
    }
    
    [self setCityFilePath:[openPanel filename]];
}

- (IBAction)importState:(id)sender;
{
    StateImporter *importer = [[StateImporter alloc] initWithDelegate:self];
    [importer setManagedObjectContext:[self managedObjectContext]];
    
    if ([self queue] == nil)
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self setQueue:queue];
        [queue release];
    }
    
    [[self queue] addOperation:importer];
    [self setImporting:YES];
    [importer release];
}

- (IBAction)importCity:(id)sender;
{
    CityImporter *importer = [[CityImporter alloc] initWithDelegate:self];
    [importer setManagedObjectContext:[self managedObjectContext]];
    
    if ([self queue] == nil)
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [self setQueue:queue];
        [queue release];
    }
    
    [[self queue] addOperation:importer];
    [self setImporting:YES];
    [importer release];
}

- (void)mergeChanges:(NSNotification*)notification
{
    NSAssert([NSThread mainThread], @"Not on the main thread");
    [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}

- (void)importDone
{
    [self setImporting:NO];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if ([self managedObjectContext] == nil)
    {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing])
    {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);

        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges])
    {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error])
    {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn)
        {
            return NSTerminateCancel;
        }

    }

    return NSTerminateNow;
}

@end
