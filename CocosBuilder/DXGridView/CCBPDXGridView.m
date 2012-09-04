//
//  CCBPDXGridView.m
//  CocosBuilder
//
//  Created by Christy Davis on 8/30/12.
//
//

#import "CCBPDXGridView.h"
#import "cocos2d.h"

@interface DXGridViewCell : CCNode
@end

@implementation DXGridViewCell

- (id)init
{
    self = [super init];
    if (self) {
        self.anchorPoint = CGPointMake(0.5f, 0.5f);
    }
    return self;
}

-(void) draw
{
    [super draw];
    ccDrawRect(ccp(0, 0), ccp(self.contentSize.width, self.contentSize.height));
    ccDrawPoint(self.anchorPointInPoints);
}

@end

@implementation CCBPDXGridView

- (id)init
{
    self = [super init];
    if (self) {
        self.dataSource = self;
    }
    return self;
}

- (void)setCellSize:(CGSize)cellSize
{
    super.cellSize = cellSize;
    [self reloadData];
}

- (CCNode*)gridView:(DXGridView*)gridView cellAtIndexPath:(NSIndexPath*)indexPath
{
    DXGridViewCell* cell = [[DXGridViewCell alloc] init];
    cell.contentSize = self.cellSize;
    return cell;
}

@end