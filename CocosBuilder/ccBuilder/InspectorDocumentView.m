/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
- (void)removeAllProperties
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
