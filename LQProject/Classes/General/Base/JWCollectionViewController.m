
#import "JWCollectionViewController.h"

@interface JWCollectionViewController ()

@end

@implementation JWCollectionViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorWhite;
    self.collectionView.backgroundColor = APPColor_BackgroudView;
    //收起键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapGr.cancelsTouchesInView    = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

- (void)didInitialized {
    [super didInitialized];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChangedNotification:) name:QDThemeChangedNotification object:nil];
    self.extendedLayoutIncludesOpaqueBars = NO;
}
- (void)dealloc {
    [kNotificationCenter removeObserver:self];
}
- (void)viewTapped {
    [self.view endEditing:YES];
}
- (void)handleThemeChangedNotification:(NSNotification *)notification {
    NSObject<QDThemeProtocol> *themeBeforeChanged = notification.userInfo[QDThemeBeforeChangedName];
    themeBeforeChanged = [themeBeforeChanged isKindOfClass:[NSNull class]] ? nil : themeBeforeChanged;
    
    NSObject<QDThemeProtocol> *themeAfterChanged = notification.userInfo[QDThemeAfterChangedName];
    themeAfterChanged = [themeAfterChanged isKindOfClass:[NSNull class]] ? nil : themeAfterChanged;
    
    [self themeBeforeChanged:themeBeforeChanged afterChanged:themeAfterChanged];
}

#pragma mark - <QDChangingThemeDelegate>

- (void)themeBeforeChanged:(NSObject<QDThemeProtocol> *)themeBeforeChanged afterChanged:(NSObject<QDThemeProtocol> *)themeAfterChanged {
    [self.collectionView reloadData];
}
#pragma mark - 添加下拉刷新
- (void)addPullRefreshWithBlock:(void(^)(void))block {
    @weakify(self)
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        self.collectionView.mj_footer.hidden = NO;
        if (block) {
            block();
        }
    }];
    ((MJRefreshNormalHeader*)self.collectionView.mj_header).lastUpdatedTimeLabel.hidden = YES;
}

#pragma mark - 上拉加载更多
- (void)addLoadingMoreWithBlock:(void(^)(void))block {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (block) {
            block();
        }
    }];
    // Set footer
    self.collectionView.mj_footer = footer;
    footer.stateLabel.hidden = YES;//隐藏刷新时显示文字
}

- (void)endRefreshWithFooterHidden {
    [self.collectionView.mj_footer endRefreshing];
    //通知已经全部加载完毕
    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    //    self.tableView.mj_footer.hidden = YES;
}
- (void)initSubviews {
    [super initSubviews];
    [self.view addSubview:self.collectionView];
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}
@end
