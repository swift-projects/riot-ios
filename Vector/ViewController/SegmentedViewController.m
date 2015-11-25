/*
 Copyright 2015 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "SegmentedViewController.h"

@interface SegmentedViewController ()
{
    // list of displayed UIViewControllers
    NSArray* viewControllers;
    
    // list of NSString
    NSArray* sectionTitles;
    
    // list of section labels
    NSArray* sectionLabels;
    
    // the selected marker view
    UIView* selectedMarkerView;
    NSLayoutConstraint *leftMarkerViewConstraint;
    
    // the index of the viewcontroller displayed at first load
    NSUInteger selectedIndex;
    
    // the UI item color
    UIColor *greenVectorColor;
}

@end

@implementation SegmentedViewController

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([SegmentedViewController class])
                          bundle:[NSBundle bundleForClass:[SegmentedViewController class]]];
}

+ (instancetype)segmentedViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([SegmentedViewController class])
                                          bundle:[NSBundle bundleForClass:[SegmentedViewController class]]];
}

/**
 init the segmentedViewController with a list of UIViewControllers.
 @param titles the section tiles
 @param viewControllers the list of viewControllers to display.
 @param defaultSelected index of the default selected UIViewController in the list.
 */
- (void)initWithTitles:(NSArray*)titles viewControllers:(NSArray*)someViewControllers defaultSelected:(NSUInteger)index
{
    viewControllers = someViewControllers;
    sectionTitles = titles;
    selectedIndex = index;
}

#pragma mark -

- (void)addConstraint:(UIView*)view constraint:(NSLayoutConstraint*)aConstraint
{
    if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)])
    {
        [NSLayoutConstraint activateConstraints:@[aConstraint]];
    }
    else
    {
        [view addConstraint:aConstraint];
    }
}

- (void)removeConstraint:(UIView*)view constraint:(NSLayoutConstraint*)aConstraint
{
    if ([NSLayoutConstraint respondsToSelector:@selector(deactivateConstraints:)])
    {
        [NSLayoutConstraint deactivateConstraints:@[aConstraint]];
    }
    else
    {
        [view removeConstraint:aConstraint];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedIndex = 1;
    
    // Adjust Top
    [self removeConstraint:self.view constraint:self.selectionContainerTopConstraint];
    
    // it is not possible to define a constraint to the topLayoutGuide in the xib editor
    // so do it in the code ..
    self.selectionContainerTopConstraint = [NSLayoutConstraint constraintWithItem:self.topLayoutGuide
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.selectionContainer
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0f
                                                                   constant:0.0f];
    
    [self addConstraint:self.selectionContainer constraint:self.selectionContainerTopConstraint];
    
    // TODO : it should be an application constant value
    greenVectorColor = [UIColor colorWithRed:(98.0/256.0) green:(206.0/256.0) blue:(156.0/256.0) alpha:1.0];
    
    [self createSegmentedViews];
}

- (void)createSegmentedViews
{
    NSMutableArray* labels = [[NSMutableArray alloc] init];
    
    int count = 4;
    
    for(int index = 0; index < count; index++)
    {
        // create programmatically each label
        UILabel *label = [[UILabel alloc] init];
        
        label.text = label.text = [NSString stringWithFormat:@"toto %d", index];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = greenVectorColor;
        label.backgroundColor = [UIColor clearColor];
        
        // the constraint defines the label frame
        // so ignore any autolayout stuff
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // add the label before setting the constraints
        [self.selectionContainer addSubview:label];
    
        NSLayoutConstraint *leftConstraint;
        if (labels.count)
        {
            leftConstraint = [NSLayoutConstraint constraintWithItem:label
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:[labels objectAtIndex:(index-1)]
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0];
        }
        else
        {
            leftConstraint = [NSLayoutConstraint constraintWithItem:label
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.selectionContainer
                                         attribute:NSLayoutAttributeLeading
                                        multiplier:1.0
                                          constant:0];
        }
        
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.selectionContainer
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0 / count
                                                                            constant:0];
        
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.selectionContainer
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0];
        
        
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.selectionContainer
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:0];
        
        
        // set the constraints
        if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)])
        {
            [NSLayoutConstraint activateConstraints:@[leftConstraint, rightConstraint, topConstraint, heightConstraint]];
        }
        else
        {
            [self.selectionContainer addConstraint:leftConstraint];
            [self.selectionContainer addConstraint:rightConstraint];
            [self.selectionContainer addConstraint:topConstraint];
            [label addConstraint:heightConstraint];
        }
        
        UITapGestureRecognizer *labelTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLabelTouch:)];
        [labelTapGesture setNumberOfTouchesRequired:1];
        [labelTapGesture setNumberOfTapsRequired:1];
        label.userInteractionEnabled = YES;
        [label addGestureRecognizer:labelTapGesture];
            
        [labels addObject:label];
    }
    
    sectionLabels = labels;
    
    [self addSelectedMarkerView];
    
    [self displaySelectedViewController];
}

- (void)addSelectedMarkerView
{
    // create the selected marker view
    selectedMarkerView = [[UIView alloc] init];
    selectedMarkerView.backgroundColor = greenVectorColor;
    [selectedMarkerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.selectionContainer addSubview:selectedMarkerView];
    
    leftMarkerViewConstraint = [NSLayoutConstraint constraintWithItem:selectedMarkerView
                                                            attribute:NSLayoutAttributeLeading
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:[sectionLabels objectAtIndex:selectedIndex]
                                                            attribute:NSLayoutAttributeLeading
                                                           multiplier:1.0
                                                             constant:0];
    
    
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:selectedMarkerView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.selectionContainer
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0 / sectionLabels.count
                                                                        constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:selectedMarkerView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.selectionContainer
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0];
    
    
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:selectedMarkerView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:3];
    
    // set the constraints
    if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)])
    {
        [NSLayoutConstraint activateConstraints:@[leftMarkerViewConstraint, widthConstraint, bottomConstraint, heightConstraint]];
    }
    else
    {
        [self.selectionContainer addConstraint:leftMarkerViewConstraint];
        [self.selectionContainer addConstraint:bottomConstraint];
        [selectedMarkerView addConstraint:heightConstraint];
        [selectedMarkerView addConstraint:heightConstraint];
    }
}

- (void)displaySelectedViewController
{
    /*
     - (void) displayContentController: (UIViewController*) content;
     {
     [self addChildViewController:content];
     content.view.frame = [self frameForContentController];
     [self.view addSubview:self.currentClientView];
     [content didMoveToParentViewController:self];
     }*/
}

#pragma mark - touch event

- (void)onLabelTouch:(UIGestureRecognizer*)gestureRecognizer
{
    NSUInteger pos = [sectionLabels indexOfObject:gestureRecognizer.view];
    
    // check if there is an update before triggering anything
    if ((pos != NSNotFound) && (selectedIndex != pos))
    {
        // update the selected index
        selectedIndex = pos;
        
        // update the marker view position
        [self removeConstraint:selectedMarkerView constraint:leftMarkerViewConstraint];
        
        leftMarkerViewConstraint = [NSLayoutConstraint constraintWithItem:selectedMarkerView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:[sectionLabels objectAtIndex:selectedIndex]
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:0];
        
        [self addConstraint:selectedMarkerView constraint:leftMarkerViewConstraint];
        
        [self displaySelectedViewController];
    }
}

@end
