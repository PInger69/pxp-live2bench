//
//  ViewController.m
//  Test12
//
//  Created by colin on 7/29/15.
//  Copyright (c) 2015 colin. All rights reserved.
//

#import "ViewController.h"
#import "ViewController2.h"

@interface ViewController ()


@end

@implementation ViewController

@synthesize tabImage;


UIColor* color()
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"VC1";
        tabImage =  [UIImage imageNamed:@"settings.png"];
        self.modules = [[NSMutableArray alloc]initWithObjects:
                        @"1",@"2",@"5",@"4",
                        @"3", nil];
    }
    
    
    return self;
}

/*- (void)tap:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateEnded)
        [self transitionToNextViewController];
}

- (UIViewController *)nextViewController
{
    UIViewController *viewController = [UIViewController new];
    viewController.view.frame = CGRectInset(self.view.bounds, 0, 200);
    UILabel *label = [[UILabel alloc] initWithFrame:viewController.view.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.text = @"Contained View Controller's View\n\nClick To Transition";
    [viewController.view addSubview:label];
    
    viewController.view.backgroundColor = color();
    viewController.view.layer.borderWidth = 6;
    viewController.view.layer.cornerRadius = 8;
    viewController.view.layer.borderColor = color().CGColor;
    viewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    viewController.view.layer.shadowOffset = CGSizeZero;
    viewController.view.layer.shadowOpacity = 0.5;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [viewController.view addGestureRecognizer:tap];
    
    return viewController;
}*/


//Scroll View Delegates

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return aView;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"Did end decelerating");
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //    NSLog(@"Did scroll");
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                 willDecelerate:(BOOL)decelerate{
    NSLog(@"Did end dragging");
}
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSLog(@"Did begin decelerating");
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"Did begin dragging");
}

/*-(UIScrollView*)addScrollView{
    UIScrollView *scrollView;
    scrollView = [[UIScrollView alloc]initWithFrame:
                    self.view.frame];
    scrollView.accessibilityActivationPoint = CGPointMake(100, 100);
    imgView = [[UIImageView alloc]initWithImage:
               [UIImage imageNamed:@"mavericks.jpg"]];
    [scrollView addSubview:imgView];
    scrollView.minimumZoomScale = 0.5;
    scrollView.maximumZoomScale = 3;
    scrollView.contentSize = CGSizeMake(imgView.frame.size.width,
                                          imgView.frame.size.height);
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    return scrollView;
}*/

-(void)initScrollView{
    UIViewController *temp = [[UIViewController alloc]initWithNibName:@"ScrollViewTest" bundle:nil];
    aView = temp.view;
    [self.myLeftScrollView addSubview:aView];
    self.myLeftScrollView.accessibilityActivationPoint = CGPointMake(100, 100);
    
    self.myLeftScrollView.minimumZoomScale = 0.5;
    self.myLeftScrollView.maximumZoomScale = 3;
    self.myLeftScrollView.contentSize = CGSizeMake(aView.frame.size.width,
                                        aView.frame.size.height);
    self.myLeftScrollView.delegate = self;
    imgView = [[UIImageView alloc]initWithImage:
               [UIImage imageNamed:@"mavericks.jpg"]];
    self.myRightScrollView.accessibilityActivationPoint = CGPointMake(100, 100);
    [self.myRightScrollView addSubview:imgView];
    self.myRightScrollView.minimumZoomScale = 0.5;
    self.myRightScrollView.maximumZoomScale = 3;
    self.myRightScrollView.contentSize = CGSizeMake(imgView.frame.size.width,
                                                   imgView.frame.size.height);
    self.myRightScrollView.delegate = self;
}

//Table View Delegates

#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
(NSInteger)section{
    return [myData count]/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:
                UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSString *stringForCell;
    if (indexPath.section == 0) {
        stringForCell= [myData objectAtIndex:indexPath.row];
        
    }
    else if (indexPath.section == 1){
        stringForCell= [myData objectAtIndex:indexPath.row+ [myData count]/2];
        
    }
    [cell.textLabel setText:stringForCell];
    return cell;
}

// Default is 1 if not implemented
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:
(NSInteger)section{
    NSString *headerTitle;
    if (section==0) {
        headerTitle = @"Section 1 Header";
    }
    else{
        headerTitle = @"Section 2 Header";
        
    }
    return headerTitle;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:
(NSInteger)section{
    NSString *footerTitle;
    if (section==0) {
        footerTitle = @"Section 1 Footer";
    }
    else{
        footerTitle = @"Section 2 Footer";
        
    }
    return footerTitle;
}

#pragma mark - TableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Section:%ld Row:%ld selected and its data is %@",
          (long)indexPath.section,(long)indexPath.row,cell.textLabel.text);
}


-(UITableView*)addTableView{
    UITableView *tableView;
    tableView = [[UITableView alloc]initWithFrame:
                    self.view.frame];
    //myTablelView.accessibilityActivationPoint = CGPointMake(100, 100);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    return tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self initScrollView];
    //myTableView = [self addTableView];
    //scrollView = [self addScrollView];
    
    // Do any additional setup after loading the view from its nib
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
