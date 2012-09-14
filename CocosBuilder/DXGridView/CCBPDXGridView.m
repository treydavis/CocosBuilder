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

@property(nonatomic, assign) GLubyte opacity;

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

@synthesize opacity = _opacity;

-(void) draw
{
    if (self.contentSize.width >= 0 && self.contentSize.height >= 0) {
        if( _opacity != 255 )
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        ccDrawColor4B(255, 255, 255, _opacity);
        ccDrawRect(ccp(0, 0), ccp(self.contentSize.width-1, self.contentSize.height-1));
        ccDrawPoint(self.anchorPointInPoints);
        
        if( _opacity != 255 )
            glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
    }
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