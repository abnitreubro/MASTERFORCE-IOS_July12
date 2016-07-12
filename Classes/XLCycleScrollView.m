








//
//  XLCycleScrollView.m
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import "XLCycleScrollView.h"

@implementation XLCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;

- (void)dealloc
{
    [_scrollView release];
    //[_pageControl release];
    [_curViews release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        
        //_scrollView.minimumZoomScale = 1;
        //_scrollView.maximumZoomScale = 5;
        
        [self addSubview:_scrollView];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 30;
        rect.size.height = 30;
        //_pageControl = [[UIPageControl alloc] initWithFrame:rect];
        //_pageControl.userInteractionEnabled = NO;
        
        //[self addSubview:_pageControl];
        
        _curPage = 0;
    }
    return self;
}

- (void)setDataource:(id<XLCycleScrollViewDatasource>)datasource
{
    NSLog(@"setDataource 0000");
    _datasource = datasource;
    [self reloadData];
}
-(void)delLoadData{
    //NSLog(@"delLoadData 0000");
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0) {
        [_delegate currentPage:_curPage];
        //NSLog(@"_totalPages == 0");
        NSArray *subViews = [_scrollView subviews];
        if([subViews count] != 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        return;
    }
    
    
    
    if (_curPage==_totalPages) {
        
        _curPage-=1;
        [_delegate currentPage:_curPage];
    }else{
        [_delegate currentPage:_curPage];
    }
    
    NSLog(@"tessssssss  _totalPages=%d _curPage=%d",_totalPages,_curPage);
    [self loadData];
}

- (void)reloadData
{
    // NSLog(@"reloadData 0000");
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0) {
        //NSLog(@"_totalPages == 0");
        NSArray *subViews = [_scrollView subviews];
        if([subViews count] != 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        return;
    }
    
    //_pageControl.numberOfPages = _totalPages;
    [self loadData];
}

- (void)loadData
{
    // NSLog(@"loadData 0000");
    //_pageControl.currentPage = _curPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:_curPage];
    
    for (int i = 0; i < 3; i++) {
        UIView *v = [_curViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        [singleTap release];
        v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}

- (void)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:_curPage-1];
    int last = [self validPageValue:_curPage+1];
    // NSLog(@"pre=%d cur=%d last=%d",pre,_curPage,last);
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource pageAtIndex:pre]];
    [_curViews addObject:[_datasource pageAtIndex:page]];
    [_curViews addObject:[_datasource pageAtIndex:last]];
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages) value = 0;
    
    return value;
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

//- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
//{
//    if (index == _curPage) {
//        [_curViews replaceObjectAtIndex:1 withObject:view];
//        for (int i = 0; i < 3; i++) {
//            UIView *v = [_curViews objectAtIndex:i];
//            v.userInteractionEnabled = YES;
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                        action:@selector(handleTap:)];
//            [v addGestureRecognizer:singleTap];
//            [singleTap release];
//            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
//            [_scrollView addSubview:v];
//        }
//    }
//}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int x = aScrollView.contentOffset.x;
    
    //往下翻一张
    if(x >= (2*self.frame.size.width)) {
        _curPage = [self validPageValue:_curPage+1];
        [self loadData];
        if ([_delegate respondsToSelector:@selector(currentPage:)])
        {
            [_delegate currentPage:_curPage];
        }
    }
    
    //往上翻
    if(x <= 0) {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
        if ([_delegate respondsToSelector:@selector(currentPage:)])
        {
            [_delegate currentPage:_curPage];
        }
    }
}
-(void)nextPage{
    _curPage = [self validPageValue:_curPage+1];
    [self loadData];
    if ([_delegate respondsToSelector:@selector(currentPage:)])
    {
        [_delegate currentPage:_curPage];
    }
}
-(void)previousPage{
    _curPage = [self validPageValue:_curPage-1];
    [self loadData];
    if ([_delegate respondsToSelector:@selector(currentPage:)])
    {
        [_delegate currentPage:_curPage];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    //    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    
}

////设置放大缩小的视图，要是uiscrollview的subview
//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
//{
//    NSLog(@"viewForZoomingInScrollView");
//    return [_curViews objectAtIndex:1];
//}
////完成放大缩小时调用
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale;
//{
//    //testImageView.frame=CGRectMake(50,0,100,400);
//    NSLog(@"scale between minimum and maximum. called after any 'bounce' animations");
//}// scale between minimum and maximum. called after any 'bounce' animations

@end
