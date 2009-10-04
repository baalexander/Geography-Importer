#import "CityImporter.h"
#import "AppDelegate.h"


@implementation CityImporter

@synthesize delegate = delegate_;
@synthesize managedObjectContext = managedObjectContext_;


- (id)initWithDelegate:(AppDelegate *)delegate;
{
    if ((self = [super init]))
    {
        [self setDelegate:delegate];
    }
    
    return self;
}

- (void)dealloc
{
    [managedObjectContext_ release];
    
    [super dealloc];
}

- (void)contextDidSave:(NSNotification*)notification 
{
    [[self delegate] performSelectorOnMainThread:@selector(mergeChanges:) 
                                      withObject:notification 
                                   waitUntilDone:NO];
}

- (void)main
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(contextDidSave:) 
                                                 name:NSManagedObjectContextDidSaveNotification 
                                               object:[self managedObjectContext]];
    
    NSString *data = [[NSString alloc] initWithContentsOfFile:[[self delegate] cityFilePath]];
    NSScanner *lineScanner = [NSScanner scannerWithString:data];
    NSString *line = nil;
    
    NSInteger count = 0;
    while ([lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line])
    {
        count++;
        NSLog(@"City count: %d", count);
        NSArray *elements = [line componentsSeparatedByString:@","];
        
        // Create City object
        NSManagedObject *city = [NSEntityDescription insertNewObjectForEntityForName:@"City" 
                                                              inManagedObjectContext:[self managedObjectContext]];
        [city setValue:[elements objectAtIndex:0] forKey:@"name"];
        
        // Select state object that city belongs to
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"State" inManagedObjectContext:[self managedObjectContext]];
        [fetchRequest setEntity:entity];
        NSError *error = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", [elements objectAtIndex:1]];
        [fetchRequest setPredicate:predicate];
        NSManagedObject *state = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:&error] objectAtIndex:0];
        [fetchRequest release];
        [city setValue:state forKey:@"state"];  
        
        // Saves context every x iterations
        if (count % 100 == 0)
        {
            NSError *error = nil;
            if (![[self managedObjectContext] save:&error])
            {
                [NSApp presentError:error];
            }      
        }
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error])
    {
        [NSApp presentError:error];
    }  
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSManagedObjectContextDidSaveNotification 
                                                  object:[self managedObjectContext]];
    
    [data release];
    [[self delegate] importDone];
}

@end
