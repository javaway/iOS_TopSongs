
@interface AppRecord : NSObject

    @property (nonatomic, strong) NSString *songTitle;
    @property (nonatomic, strong) UIImage *songIcon;
    @property (nonatomic, strong) NSString *artist;
    @property (nonatomic, strong) NSString *songURLString;
    @property (nonatomic, strong) NSString *appURLString;

@end