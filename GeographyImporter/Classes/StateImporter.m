#import "StateImporter.h"
#import "AppDelegate.h"


@implementation StateImporter

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
    
    NSString *data = [[NSString alloc] initWithContentsOfFile:[[self delegate] stateFilePath]];
    NSScanner *lineScanner = [NSScanner scannerWithString:data];
    NSString *line = nil;
    
    NSInteger count = 0;
    while ([lineScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&line])
    {
        count++;
        NSLog(@"State count: %d", count);
        NSArray *elements = [line componentsSeparatedByString:@","];
        
        // Create State object
        NSManagedObject *state = [NSEntityDescription insertNewObjectForEntityForName:@"State"
                                                               inManagedObjectContext:[self managedObjectContext]];
        [state setValue:[elements objectAtIndex:1] forKey:@"name"];
        [state setValue:[elements objectAtIndex:2] forKey:@"abbreviation"];

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
