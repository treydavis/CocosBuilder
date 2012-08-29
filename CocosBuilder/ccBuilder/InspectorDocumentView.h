//
//  InspectorDocumentView.h
//  CocosBuilder
//
//  Created by Christy Davis on 8/28/12.
//
//

#import "NSFlippedView.h"

@interface InspectorDocumentView : NSFlippedView

- (void)refreshProperty:(NSString*)name;
- (void)removeAllInspectorValues;
- (void)addInspectorPropertyOfType:(NSString*)type name:(NSString*)prop displayName:(NSString*)displayName extra:(NSString*)e readOnly:(BOOL)readOnly affectsProps:(NSArray*)affectsProps;
- (void)finishedAddingInspectorProperties;

@end
