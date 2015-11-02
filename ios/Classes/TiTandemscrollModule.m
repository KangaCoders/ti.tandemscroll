/**
 * Titanium Tandem Scroll Module
 *
 * Appcelerator Titanium is Copyright (c) 2009-2012 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiTandemscrollModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiTandemscrollModule

#pragma mark Internal

// this is generated for your module, please do not change it
 -(id)moduleGUID
 {
     return @"f7f041db-989f-47c9-b009-7977a59497a2";
 }

// this is generated for your module, please do not change it
 -(NSString*)moduleId
 {
   return @"ti.tandemscroll";
}

#pragma mark Cleanup

-(void)unbindScrollViews
{
    if (scrollViews) {
        for (TiUIScrollViewProxy* proxy in scrollViews) {
            [proxy forgetSelf];
        }
        RELEASE_TO_NIL(scrollViews);
    }
}

-(void)unbindVerticalScrollViews
{
    if (scrollViewsVertically) {
        for (TiUIScrollViewProxy* proxy in scrollViewsVertically) {
            [proxy forgetSelf];
        }
        RELEASE_TO_NIL(scrollViewsVertically);
    }
}

-(void)unbindHorizontalScrollViews
{
    if (scrollViewsHorizontally) {
        for (TiUIScrollViewProxy* proxy in scrollViewsHorizontally) {
            [proxy forgetSelf];
        }
        RELEASE_TO_NIL(scrollViewsHorizontally);
    }
}

-(void)dealloc
{
	[self unbindScrollViews];
	[super dealloc];
}

-(UIScrollView*)toScrollView:(id)view
{
    UIScrollView* scrollView = nil;
    if ([view respondsToSelector:@selector(scrollView)]) {
        scrollView = [view scrollView];
    }
    else if ([view respondsToSelector:@selector(scrollview)]) {
        scrollView = [view scrollview];
    }
    return scrollView;
}

#pragma Public APIs

-(void)lockTogether:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);

    // controllingScrollView = nil;

    [self unbindScrollViews];
    scrollViews = [[NSMutableArray alloc] initWithCapacity:[args count]];

    for (TiViewProxy* proxy in args) {
        [proxy rememberSelf];
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        if(controllingScrollView != nil){
            controllingScrollView = scroll;
        }
        scroll.delegate = self;
        [scrollViews addObject:proxy];
    }
}

-(void)lockTogetherHorizontally:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);

    // controllingScrollView = nil;

    [self unbindHorizontalScrollViews];
    scrollViewsHorizontally = [[NSMutableArray alloc] initWithCapacity:[args count]];

    for (TiViewProxy* proxy in args) {
        [proxy rememberSelf];
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        scroll.delegate = self;
        [scrollViewsHorizontally addObject:proxy];
    }
}

-(void)lockTogetherVertically:(id)args
{
    ENSURE_SINGLE_ARG(args, NSArray);

    // controllingScrollView = nil;

    [self unbindVerticalScrollViews];
    scrollViewsVertically = [[NSMutableArray alloc] initWithCapacity:[args count]];

    for (TiViewProxy* proxy in args) {
        [proxy rememberSelf];
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        scroll.delegate = self;
        [scrollViewsVertically addObject:proxy];
    }
}

#pragma UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    controllingScrollView = scrollView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView != controllingScrollView)
        return;

    for (TiViewProxy* proxy in scrollViews)
    {
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        if (scroll == controllingScrollView)
        {
            return;
        }
        [scroll setZoomScale:scrollView.zoomScale animated:NO];
    }

    for (TiViewProxy* proxy in scrollViewsVertically)
    {
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        if (scroll == controllingScrollView)
        {
            return;
        }
        [scroll setZoomScale:scrollView.zoomScale animated:NO];
    }

    for (TiViewProxy* proxy in scrollViewsHorizontally)
    {
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        if (scroll == controllingScrollView)
        {
            return;
        }
        [scroll setZoomScale:scrollView.zoomScale animated:NO];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return scrollView.subviews[0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // We only care about scroll events from the view that is actually being dragged by the user.
    if (scrollView != controllingScrollView)
        return;

    for (TiViewProxy* proxy in scrollViews)
    {
        // Skip the view that is actually scrolling,
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        if (scroll == controllingScrollView)
        {
            CGPoint offset = [scrollView contentOffset];
            [proxy fireEvent:@"scroll" withObject:[NSDictionary dictionaryWithObjectsAndKeys:
               NUMFLOAT(offset.x),@"x",
               NUMFLOAT(offset.y),@"y",
               NUMBOOL([scrollView isDecelerating]),@"decelerating",
               NUMBOOL([scrollView isDragging]),@"dragging", nil]];
            continue;
        }

        // Scroll proportionally.
        [scroll setZoomScale:scrollView.zoomScale animated:NO];
        [scroll setContentOffset:CGPointMake(scrollView.contentOffset.x * scroll.contentSize.width / scrollView.contentSize.width,
         scrollView.contentOffset.y * scroll.contentSize.height / scrollView.contentSize.height) animated:NO];
    }
    for (TiViewProxy* proxy in scrollViewsVertically)
    {
        // Skip the view that is actually scrolling,
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        if (scroll == controllingScrollView)
        {
            CGPoint offset = [scrollView contentOffset];
            [proxy fireEvent:@"scroll" withObject:[NSDictionary dictionaryWithObjectsAndKeys:
               NUMFLOAT(offset.x),@"x",
               NUMFLOAT(offset.y),@"y",
               NUMBOOL([scrollView isDecelerating]),@"decelerating",
               NUMBOOL([scrollView isDragging]),@"dragging", nil]];
            continue;
        }

        // Scroll proportionally.
        [scroll setZoomScale:scrollView.zoomScale animated:NO];
        [scroll setContentOffset:CGPointMake(scroll.contentOffset.x,
         scrollView.contentOffset.y * scroll.contentSize.height / scrollView.contentSize.height) animated:NO];
    }
    for (TiViewProxy* proxy in scrollViewsHorizontally)
    {
        // Skip the view that is actually scrolling,
        id view = proxy.view;
        UIScrollView* scroll = [self toScrollView:view];
        if (scroll == controllingScrollView)
        {
            CGPoint offset = [scrollView contentOffset];
            [proxy fireEvent:@"scroll" withObject:[NSDictionary dictionaryWithObjectsAndKeys:
               NUMFLOAT(offset.x),@"x",
               NUMFLOAT(offset.y),@"y",
               NUMBOOL([scrollView isDecelerating]),@"decelerating",
               NUMBOOL([scrollView isDragging]),@"dragging", nil]];
            continue;
        }

        // Scroll proportionally.
        [scroll setZoomScale:scrollView.zoomScale animated:NO];
        [scroll setContentOffset:CGPointMake(scrollView.contentOffset.x * scroll.contentSize.width / scrollView.contentSize.width,
         scroll.contentOffset.y) animated:NO];
    }
}

@end
