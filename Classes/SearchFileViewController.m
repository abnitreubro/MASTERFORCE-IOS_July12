//
//  SearchFileViewController.m
//  P2PCamera
//
//  Created by Tsang on 13-2-1.
//
//

#import "SearchFileViewController.h"
#import "AppDelegate.h"
#import "obj_common.h"
@interface SearchFileViewController ()

@end

@implementation SearchFileViewController
@synthesize navigationBar;
@synthesize sPickerView;
@synthesize fPickerView;
@synthesize yearArray;
@synthesize monthArray;
@synthesize dateArray;
@synthesize hourArray;
@synthesize minuteArray;
@synthesize secondArray;
@synthesize allSwitch;
@synthesize remoteProtocol;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    [navigationBar release];
    [fPickerView release];
    [sPickerView release];
    [yearArray release];
    [monthArray release];
    [dateArray release];
    [hourArray release];
    [minuteArray release];
    [secondArray release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"top_bg_blue.png"];
    if (![AppDelegate is43Version]) {
        [navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    self.navigationBar.delegate = self;
    self.navigationBar.tintColor = [UIColor colorWithRed:BTN_NORMAL_RED/255.0f green:BTN_NORMAL_GREEN/255.0f blue:BTN_NORMAL_BLUE/255.0f alpha:1];
    UINavigationItem *back=[[UINavigationItem alloc]initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_uplate", @STR_LOCALIZED_FILE_NAME, nil)];
    UINavigationItem *item=[[UINavigationItem alloc]initWithTitle:NSLocalizedStringFromTable(@"runcar_select_search_date", @STR_LOCALIZED_FILE_NAME, nil)];
    //创建一个右边按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Done", @STR_LOCALIZED_FILE_NAME, nil)
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(btnSetDatetime)];
    item.rightBarButtonItem=rightButton;
    [rightButton release];
    item.rightBarButtonItem = rightButton;
    [navigationBar setItems:[NSArray arrayWithObjects:back,item, nil]];
    [back release];
    [item release];
    
    yearArray=[[NSMutableArray alloc]init];
    monthArray=[[NSMutableArray alloc]init];
    dateArray=[[NSMutableArray alloc]init];
    hourArray=[[NSMutableArray alloc]init];
    minuteArray=[[NSMutableArray alloc]init];
    secondArray=[[NSMutableArray alloc]init];
    
    
    
    fPickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(10,80,300,100)];
    fPickerView.delegate=self;
    fPickerView.dataSource=self;
    fPickerView.showsSelectionIndicator=YES;
    fPickerView.tag=100;
    
    [self.view addSubview:fPickerView];
    
    sPickerView=[[UIPickerView alloc]initWithFrame:CGRectMake(10,280,300,100)];
    sPickerView.delegate=self;
    sPickerView.dataSource=self;
    sPickerView.showsSelectionIndicator=YES;
    sPickerView.tag=101;
    [self.view addSubview:sPickerView];
    
    
    
    UILabel *fLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 56, 100, 20)];
    fLabel.text=NSLocalizedStringFromTable(@"runcar_search_starttime", @STR_LOCALIZED_FILE_NAME, nil);
    
    [self.view addSubview:fLabel];
    [fLabel release];
    
    UILabel *sLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 256, 100, 20)];
    sLabel.text=NSLocalizedStringFromTable(@"runcar_search_endtime", @STR_LOCALIZED_FILE_NAME, nil);
    [self.view addSubview:sLabel];
    [sLabel release];
    
    
    UILabel *allLabel=[[UILabel alloc]initWithFrame:CGRectMake(125, 56, 38, 20)];
    allLabel.text=NSLocalizedStringFromTable(@"runcar_search_all", @STR_LOCALIZED_FILE_NAME, nil); 
    [self.view addSubview:allLabel];
    [allLabel release];
    [allSwitch addTarget:self action:@selector(allSwitchChange:) forControlEvents:UIControlEventValueChanged];
    [allSwitch setOn:NO];
    [self initDateAndTime];
}
- (void)showLoadingIndicator
{
    UINavigationItem *back=[[UINavigationItem alloc]initWithTitle:NSLocalizedStringFromTable(@"runcar_mode_uplate", @STR_LOCALIZED_FILE_NAME, nil)];
    UINavigationItem *item=[[UINavigationItem alloc]initWithTitle:NSLocalizedStringFromTable(@"runcar_select_search_date", @STR_LOCALIZED_FILE_NAME, nil)];
    
    //创建一个右边按钮
    UIActivityIndicatorView *indicator =
    [[[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]
     autorelease];
	indicator.frame = CGRectMake(0, 0, 24, 24);
	[indicator startAnimating];
	UIBarButtonItem *progress =
    [[[UIBarButtonItem alloc] initWithCustomView:indicator] autorelease];
    
    item.rightBarButtonItem = progress;
    
    NSArray *array = [NSArray arrayWithObjects:back, item, nil];
    [self.navigationBar setItems:array];
	
    [item release];
    [back release];
}

-(void)allSwitchChange:(id)sender{
    isAll=allSwitch.on;
    
}
-(void)btnSetDatetime{
    [self showLoadingIndicator];
    [self performSelector:@selector(searchDateTime) withObject:nil afterDelay:1];
}
-(void)searchDateTime{
    
    NSString *strFMonth;
    NSString *strFDate;
    NSString *strFHour;
    NSString *strFMinute;
    NSString *strFSecond;
    NSString *strSMonth;
    NSString *strSDate;
    NSString *strSHour;
    NSString *strSMinute;
    NSString *strSSecond;
    if (fMonth<10) {
        strFMonth=[NSString stringWithFormat:@"0%d",fMonth];
    }else{
        strFMonth=[NSString stringWithFormat:@"%d",fMonth];
    }
    
    if (fDate<10) {
        strFDate=[NSString stringWithFormat:@"0%d",fDate];
    }else{
        strFDate=[NSString stringWithFormat:@"%d",fDate];
    }
    if (fHour<10) {
        strFHour=[NSString stringWithFormat:@"0%d",fHour];
    }else{
        strFHour=[NSString stringWithFormat:@"%d",fHour];
    }
    if (fMinute<10) {
        strFMinute=[NSString stringWithFormat:@"0%d",fMinute];
    }else{
        strFMinute=[NSString stringWithFormat:@"%d",fMinute];
    }
    if (fSecond<10) {
        strFSecond=[NSString stringWithFormat:@"0%d",fSecond];
    }else{
        strFSecond=[NSString stringWithFormat:@"%d",fSecond];
    }
    
    if (sMonth<10) {
        strSMonth=[NSString stringWithFormat:@"0%d",sMonth];
    }else{
        strSMonth=[NSString stringWithFormat:@"%d",sMonth];
    }
    if (sDate<10) {
        strSDate=[NSString stringWithFormat:@"0%d",sDate];
    }else{
        strSDate=[NSString stringWithFormat:@"%d",sDate];
    }
    if (sHour<10) {
        strSHour=[NSString stringWithFormat:@"0%d",sHour];
    }else{
        strSHour=[NSString stringWithFormat:@"%d",sHour];
    }
    if (sMinute<10) {
        strSMinute=[NSString stringWithFormat:@"0%d",sMinute];
    }else{
        strSMinute=[NSString stringWithFormat:@"%d",sMinute];
    }
    if (fSecond<10) {
        strSSecond=[NSString stringWithFormat:@"0%d",sSecond];
    }else{
        strSSecond=[NSString stringWithFormat:@"%d",sSecond];
    }
    
    NSString *startTime=[NSString stringWithFormat:@"%d%@%@_%@%@%@",fYear,strFMonth,strFDate,strFHour,strFMinute,strFSecond];
    NSString *endTime=[NSString stringWithFormat:@"%d%@%@_%@%@%@",sYear,strSMonth,strSDate,strSHour,strSMinute,strSSecond];
    
    
    
    [self.navigationController popViewControllerAnimated:YES];
    [remoteProtocol searchResult:isAll StartTime:startTime EndTime:endTime];

}
-(void)initDateAndTime{
    int year=2012;
    for (int i=0; i<60; i++) {
        year+=1;
        NSString *num=[NSString stringWithFormat:@"%d",year];
        [yearArray addObject:num];
    }
    int month=0;
    for (int i=0; i<12; i++) {
        
        month+=1;
        
        NSString *num;
        if (month<10) {
            num=[NSString stringWithFormat:@"0%d",month];
        }else{
            num=[NSString stringWithFormat:@"%d",month];
        }
        
        [monthArray addObject:num];
    }

    int hour=-1;
    for (int i=0; i<24; i++) {
        hour+=1;
        NSString *num;
        if (hour<10) {
            num=[NSString stringWithFormat:@"0%d",hour];
        }else{
            num=[NSString stringWithFormat:@"%d",hour];
        }
        
        [hourArray addObject:num];
    }
    
    int minute=-1;
    for (int i=0; i<60; i++) {
        minute+=1;
        NSString *num;
        if (minute<10) {
            num=[NSString stringWithFormat:@"0%d",minute];
        }else{
            num=[NSString stringWithFormat:@"%d",minute];
        }
        [minuteArray addObject:num];
    }
    
    int second=-1;
    for (int i=0; i<60; i++) {
        second+=1;
        NSString *num;
        if (second<10) {
            num=[NSString stringWithFormat:@"0%d",second];
        }else{
            num=[NSString stringWithFormat:@"%d",second];
        }
        [secondArray addObject:num];
    }
    
    NSDate *today=[NSDate date];
    NSDateFormatter *f=[[NSDateFormatter alloc]init];
    [f setDateFormat:@"yyyyMMddHHmmss"];
    NSString *strNow=[f stringFromDate:today];
    NSLog(@"strNow=%@",strNow);
    
    sYear=[[strNow substringWithRange:NSMakeRange(0,4)] intValue];
    sMonth=[[strNow substringWithRange:NSMakeRange(4,2)]intValue];
    sDate=[[strNow substringWithRange:NSMakeRange(6,2)]intValue];
    sHour=[[strNow substringWithRange:NSMakeRange(8,2)]intValue];
    sMinute=[[strNow substringWithRange:NSMakeRange(10,2)]intValue];
    sSecond=[[strNow substringWithRange:NSMakeRange(12,2)]intValue];
    
    
    //NSLog(@"year=%d month=%d date=%d  hour=%d minute=%d second=%d",year,month,date,hour,minute,second);
    int n;
    for (n=0; n<yearArray.count; n++) {
        int y=[[yearArray objectAtIndex:n]intValue];
         
        if (y==sYear) {
           
            break;
        }
    }
    [sPickerView selectRow:n inComponent:0 animated:YES];
    [sPickerView selectRow:sMonth-1 inComponent:1 animated:YES];
    [sPickerView selectRow:sDate-1 inComponent:2 animated:YES];
    [sPickerView selectRow:sHour inComponent:3 animated:YES];
    [sPickerView selectRow:sMinute inComponent:4 animated:YES];
    [sPickerView selectRow:sSecond inComponent:5 animated:YES];
    

    

    
    if (sDate==1) {
        if (sMonth>1) {
            fMonth=sMonth-1;
            fYear=sYear;//同一年
            [self initDate:fMonth Year:[NSString stringWithFormat:@"%d",fYear] Tag:102];
            fDate=[[dateArray lastObject]intValue];
        }else{//上一年的最后一天
            fYear=sYear-1;
            fMonth=12;
            fDate=31;
            
        }
        
    }else{
        fYear=sYear;
        fMonth=sMonth;
        fDate=sDate-1;
    }
    
    
    //同时
    fYear=sYear;
    fMonth=sMonth;
    fDate=sDate;
    int j;
    for (j=0; j<yearArray.count; j++) {
        int y=[[yearArray objectAtIndex:j]intValue];
        if (y==fYear) {
            break;
        }
    }
    fHour=sHour;
    fMinute=sMinute;
    fSecond=sSecond;
    [fPickerView selectRow:j inComponent:0 animated:YES];
    [fPickerView selectRow:fMonth-1 inComponent:1 animated:YES];
    [fPickerView selectRow:fDate-1 inComponent:2 animated:YES];
    [fPickerView selectRow:fHour inComponent:3 animated:YES];
    [fPickerView selectRow:fMinute inComponent:4 animated:YES];
    [fPickerView selectRow:sSecond inComponent:5 animated:YES];
}
-(BOOL)isLoopYear:(NSString *)year{
    int y=[year intValue];
    BOOL isLoop=NO;
    if ((y%400==0)||(y%4==0&&y%100!=0)) {
        isLoop=YES;
    }
    return  isLoop;
}
-(void)initDate:(int)month Year:(NSString *)year Tag:(int)tag{
  //  NSLog(@"=====month=%d",month);
    [dateArray removeAllObjects];
    int n=0;
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            n=31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            n=30;
            break;
        case 2:
            if ([self isLoopYear:year]) {
                n=29;
            }else{
                n=28;
            }
            break;
      
    }
    
    int date=0;
    for (int i=0; i<n; i++) {
        date+=1;
        NSString *num;
        if (date<10) {
            num=[NSString stringWithFormat:@"0%d",date];
        }else{
            num=[NSString stringWithFormat:@"%d",date];
        }
        
        [dateArray addObject:num];
    }
    switch (tag) {
        case 100:
            [fPickerView reloadComponent:2];
            break;
        case 101:
             [sPickerView reloadComponent:2];
            break;
        default:
            break;
    }
   
    
}
#pragma mark- UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return [yearArray objectAtIndex:row];
            
        case 1:
            return [monthArray objectAtIndex:row];
           

        case 2:
            
            return [dateArray objectAtIndex:row];
            
        case 3:
            return [hourArray objectAtIndex:row];
            

        case 4:
            return [minuteArray objectAtIndex:row];
            

        case 5:
            return [secondArray objectAtIndex:row];
    
    }
    
    
    return nil;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component==0) {
        return 60;
    }
    return 40;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (pickerView.tag) {
        case 100://起始时间
            switch (component) {
                case 0:
                    fYear=[[yearArray objectAtIndex:row]intValue];
                    break;
                case 1:
                    fMonth=[[monthArray objectAtIndex:row]intValue];
                    [self initDate:fMonth Year:[NSString stringWithFormat:@"%d",fYear] Tag:100];
                    break;
                case 2:
                    fDate=[[dateArray objectAtIndex:row]intValue];
                    
                    break;
                case 3:
                    fHour=[[hourArray objectAtIndex:row]intValue];
                    break;
                case 4:
                    fMinute=[[minuteArray objectAtIndex:row]intValue];
                    break;
                case 5:
                    fSecond=[[secondArray objectAtIndex:row]intValue];
                    break;
                    
                default:
                    break;
            }

            break;
        case 101://结束时间
            switch (component) {
                case 0:
                    sYear=[[yearArray objectAtIndex:row]intValue];
                    break;
                case 1:
                    sMonth=[[monthArray objectAtIndex:row]intValue];
                    [self initDate:sMonth Year:[NSString stringWithFormat:@"%d",sYear] Tag:101];
                    break;
                case 2:
                    sDate=[[dateArray objectAtIndex:row]intValue];
                    
                    break;
                case 3:
                    sHour=[[hourArray objectAtIndex:row]intValue];
                    break;
                case 4:
                    sMinute=[[minuteArray objectAtIndex:row]intValue];
                    break;
                case 5:
                    sSecond=[[secondArray objectAtIndex:row]intValue];
                    break;
             
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

//-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{}
#pragma mark- UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 6;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return yearArray.count;
           
        case 1:
            return monthArray.count;
           
        case 2:
            switch (pickerView.tag) {
                case 100:
                    [self initDate:fMonth Year:[NSString stringWithFormat:@"%d",fYear] Tag:102];
                    break;
                case 101:
                    [self initDate:sMonth Year:[NSString stringWithFormat:@"%d",sYear] Tag:102];
                    break;
                    

                default:
                    break;
            }
            return dateArray.count;
           
        case 3:
            return hourArray.count;
           
        case 4:
            return minuteArray.count;
           
        case 5:
            return secondArray.count;
            
     
    }
    return 0;
}
#pragma mark- NavigationBarDelegate
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
    return  YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
