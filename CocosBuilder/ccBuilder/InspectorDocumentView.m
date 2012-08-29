//
//  InspectorDocumentView.m
//  CocosBuilder
//
//  Created by Christy Davis on 8/28/12.
//
//

#import "InspectorDocumentView.h"
#import "InspectorValue.h"
#import "CocosBuilderAppDelegate.h"
#import "InspectorSeparator.h"

@implementation InspectorDocumentView {
    NSMutableDictionary* currentInspectorValues;
    InspectorValue* lastInspectorValue;
    BOOL hideAllToNextSeparator;
    int paneOffset;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        currentInspectorValues = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [currentInspectorValues release];
    [super dealloc];
}

- (void) refreshProperty:(NSString*) name
{
    if (![CocosBuilderAppDelegate appDelegate].selectedNode) return;
    
    InspectorValue* inspectorValue = [currentInspectorValues objectForKey:name];
    if (inspectorValue) {
        [inspectorValue refresh];
    }
}
- (void)removeAllInspectorValues
{
    // Notifiy panes that they will be removed
    for (NSString* key in currentInspectorValues) {
        InspectorValue* v = [currentInspectorValues objectForKey:key];
        [v willBeRemoved];
    }

    // Remove all old inspector panes
    NSArray* panes = [self subviews];
    for (int i = [panes count]-1; i >= 0 ; i--) {
        NSView* pane = [panes objectAtIndex:i];
        [pane removeFromSuperview];
    }
    [currentInspectorValues removeAllObjects];
    
    [self setFrameSize:NSMakeSize(233, 1)];
    paneOffset = 0;
    hideAllToNextSeparator = NO;
}

- (void)addInspectorPropertyOfType:(NSString*)type name:(NSString*)prop displayName:(NSString*)displayName extra:(NSString*)e readOnly:(BOOL)readOnly affectsProps:(NSArray*)affectsProps
{
    NSString* inspectorNibName = [NSString stringWithFormat:@"Inspector%@",type];
    
    // Create inspector
    InspectorValue* inspectorValue = [InspectorValue inspectorOfType:type withSelection:[CocosBuilderAppDelegate appDelegate].selectedNode andPropertyName:prop andDisplayName:displayName andExtra:e];
    lastInspectorValue.inspectorValueBelow = inspectorValue;
    lastInspectorValue = inspectorValue;
    inspectorValue.readOnly = readOnly;
    
    // Save a reference in case it needs to be updated
    if (prop)
    {
        [currentInspectorValues setObject:inspectorValue forKey:prop];
    }
    
    if (affectsProps)
    {
        inspectorValue.affectsProperties = affectsProps;
    }
    
    // Load it's associated view
    [NSBundle loadNibNamed:inspectorNibName owner:inspectorValue];
    NSView* view = inspectorValue.view;
    
    [inspectorValue willBeAdded];
    
    //if its a separator, check to see if it isExpanded, if not set all of the next non-separator InspectorValues to hidden and don't touch the offset
    if ([inspectorValue isKindOfClass:[InspectorSeparator class]]) {
        InspectorSeparator* inspectorSeparator = (InspectorSeparator*)inspectorValue;
        hideAllToNextSeparator = NO;
        if (!inspectorSeparator.isExpanded) {
            hideAllToNextSeparator = YES;
        }
        NSRect frame = [view frame];
        [view setFrame:NSMakeRect(0, paneOffset, frame.size.width, frame.size.height)];
        paneOffset += frame.size.height;
    }
    else {
        if (hideAllToNextSeparator) {
            [view setHidden:YES];
        }
        else {
            NSRect frame = [view frame];
            [view setFrame:NSMakeRect(0, paneOffset, frame.size.width, frame.size.height)];
            paneOffset += frame.size.height;
        }
    }
    
    // Add view to inspector and place it at the bottom
    [self addSubview:view];
    [view setAutoresizingMask:NSViewWidthSizable];
}

- (void)resizeFrameAroundAddedProperties
{
    [self setFrameSize:NSMakeSize([(NSScrollView*)self.superview.superview contentSize].width, paneOffset)];
}

@end
