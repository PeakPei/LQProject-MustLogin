
#import "JWTableViewController.h"
#import "QMUICore.h"
#import "QMUINavigationTitleView.h"
#import "QMUIEmptyView.h"
#import "NSString+QMUI.h"
#import "NSObject+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UIGestureRecognizer+QMUI.h"
#import "QMUITableViewHeaderFooterView.h"
#import "UIScrollView+QMUI.h"
#import "UITableView+QMUI.h"
#import "UICollectionView+QMUI.h"
#import "UIView+QMUI.h"

@interface JWTableViewControllerHideKeyboardDelegateObject : NSObject <UIGestureRecognizerDelegate, QMUIKeyboardManagerDelegate>

@property(nonatomic, weak) JWTableViewController *viewController;

- (instancetype)initWithViewController:(JWTableViewController *)viewController;
@end

@interface JWTableViewController () {
    UITapGestureRecognizer *_hideKeyboardTapGestureRecognizer;
    QMUIKeyboardManager *_hideKeyboardManager;
    JWTableViewControllerHideKeyboardDelegateObject *_hideKeyboadDelegateObject;
}
@property(nonatomic,strong,readwrite) QMUINavigationTitleView *titleView;
@property(nonatomic, assign) BOOL hasSetInitialContentInset;
@property(nonatomic, assign) BOOL hasHideTableHeaderViewInitial;
@end

const UIEdgeInsets QMUICommonTableViewControllerInitialContentInsetNotSet = {-1, -1, -1, -1};
NSString *const QMUICommonTableViewControllerSectionHeaderIdentifier = @"QMUISectionHeaderView";
NSString *const QMUICommonTableViewControllerSectionFooterIdentifier = @"QMUISectionFooterView";

@implementation JWTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    self.titleView = [[QMUINavigationTitleView alloc] init];
    self.titleView.title = self.title;// 从 storyboard 初始化的话，可能带有 self.title 的值
    
    self.hidesBottomBarWhenPushed = HidesBottomBarWhenPushedInitially;
    
    // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.supportedOrientationMask = SupportedOrientationMask;
    
    // 动态字体notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.hasHideTableHeaderViewInitial = NO;
    self.tableViewInitialContentInset = QMUICommonTableViewControllerInitialContentInsetNotSet;
    self.tableViewInitialScrollIndicatorInsets = QMUICommonTableViewControllerInitialContentInsetNotSet;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChangedNotification:) name:QDThemeChangedNotification object:nil];
    self.extendedLayoutIncludesOpaqueBars = NO;

    
}
- (void)viewTapped {
    [self.view endEditing:YES];
}
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.titleView.title = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.view.backgroundColor) {
        UIColor *backgroundColor = UIColorForBackground;
        if (backgroundColor) {
            self.view.backgroundColor = backgroundColor;
        }
    }
    
    // 点击空白区域降下键盘 QMUICommonViewController (QMUIKeyboard)
    
    _hideKeyboadDelegateObject = [[JWTableViewControllerHideKeyboardDelegateObject alloc] initWithViewController:self];
    
    _hideKeyboardTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
    self.hideKeyboardTapGestureRecognizer.delegate = _hideKeyboadDelegateObject;
    self.hideKeyboardTapGestureRecognizer.enabled = NO;
    [self.view addGestureRecognizer:self.hideKeyboardTapGestureRecognizer];
    
    _hideKeyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:_hideKeyboadDelegateObject];
    
    [self initSubviews];
    
    self.tableView.backgroundColor = APPColor_BackgroudView;
    //收起键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tapGr.cancelsTouchesInView    = NO;
    [self.view addGestureRecognizer:tapGr];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self shouldAdjustTableViewContentInsetsInitially] && !self.hasSetInitialContentInset) {
        self.tableView.contentInset = self.tableViewInitialContentInset;
        if ([self shouldAdjustTableViewScrollIndicatorInsetsInitially]) {
            self.tableView.scrollIndicatorInsets = self.tableViewInitialScrollIndicatorInsets;
        } else {
            // 默认和tableView.contentInset一致
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }
        [self.tableView qmui_scrollToTop];
        self.hasSetInitialContentInset = YES;
    }
    
    [self hideTableHeaderViewInitialIfCanWithAnimated:NO force:NO];
    [self layoutEmptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationItemsIsInEditMode:NO animated:NO];
    [self setToolbarItemsIsInEditMode:NO animated:NO];
    [self.tableView qmui_clearsSelection];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}
- (void)dealloc {
    [kNotificationCenter removeObserver:self];
}
- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force {
    if (self.tableView.tableHeaderView && [self shouldHideTableHeaderViewInitial] && (force || !self.hasHideTableHeaderViewInitial)) {
        CGPoint contentOffset = CGPointMake(self.tableView.contentOffset.x, -self.tableView.qmui_contentInset.top + CGRectGetHeight(self.tableView.tableHeaderView.frame));
        [self.tableView setContentOffset:contentOffset animated:animated];
        self.hasHideTableHeaderViewInitial = YES;
    }
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    [self contentSizeCategoryDidChanged:notification];
    [self.tableView reloadData];
}

- (void)setTableViewInitialContentInset:(UIEdgeInsets)tableViewInitialContentInset {
    _tableViewInitialContentInset = tableViewInitialContentInset;
    if (UIEdgeInsetsEqualToEdgeInsets(tableViewInitialContentInset, QMUICommonTableViewControllerInitialContentInsetNotSet)) {
        if (@available(iOS 11, *)) {
            if (self.isViewLoaded) {
                self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
            }
        } else {
            self.automaticallyAdjustsScrollViewInsets = YES;
        }
    } else {
        if (@available(iOS 11, *)) {
            if (self.isViewLoaded) {
                self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
}

- (BOOL)shouldAdjustTableViewContentInsetsInitially {
    BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.tableViewInitialContentInset, QMUICommonTableViewControllerInitialContentInsetNotSet);
    return shouldAdjust;
}

- (BOOL)shouldAdjustTableViewScrollIndicatorInsetsInitially {
    BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.tableViewInitialScrollIndicatorInsets, QMUICommonTableViewControllerInitialContentInsetNotSet);
    return shouldAdjust;
}

#pragma mark - 空列表视图 QMUIEmptyView

- (void)showEmptyView {
    if (!self.emptyView) {
        self.emptyView = [[QMUIEmptyView alloc] init];
    }
    [self.tableView addSubview:self.emptyView];
    [self layoutEmptyView];
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
}

- (BOOL)layoutEmptyView {
    if (!self.emptyView || !self.emptyView.superview) {
        return NO;
    }
    
    UIEdgeInsets insets = self.tableView.contentInset;
    if (@available(iOS 11, *)) {
        if (self.tableView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            insets = self.tableView.adjustedContentInset;
        }
    }
    
    // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
    if (self.tableView.tableHeaderView) {
        self.emptyView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.tableHeaderView.frame), CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets) - CGRectGetMaxY(self.tableView.tableHeaderView.frame));
    } else {
        self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets));
    }
    return YES;
}

#pragma mark - <QMUITableViewDelegate, QMUITableViewDataSource>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        UIImage *indicatorImage = TableViewCellDisclosureIndicatorImage;
        if (indicatorImage) {
            indicatorImage = [indicatorImage qmui_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
            UIImageView *defaultAccessoryImageView = [[UIImageView alloc] init];
            defaultAccessoryImageView.contentMode = UIViewContentModeCenter;
            defaultAccessoryImageView.image = indicatorImage;
            [defaultAccessoryImageView sizeToFit];
            cell.accessoryView = defaultAccessoryImageView;
        }
    }
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView realTitleForHeaderInSection:section];
    if (title) {
        QMUITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:QMUICommonTableViewControllerSectionHeaderIdentifier];
        headerView.parentTableView = tableView;
        headerView.type = QMUITableViewHeaderFooterViewTypeHeader;
        headerView.titleLabel.text = title;
        return headerView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView realTitleForFooterInSection:section];
    if (title) {
        QMUITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:QMUICommonTableViewControllerSectionFooterIdentifier];
        footerView.parentTableView = tableView;
        footerView.type = QMUITableViewHeaderFooterViewTypeFooter;
        footerView.titleLabel.text = title;
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForHeaderInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.qmui_safeAreaInsets), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : TableViewGroupedSectionHeaderDefaultHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForFooterInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.qmui_safeAreaInsets), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : TableViewGroupedSectionFooterDefaultHeight;
}

// 是否有定义某个section的header title
- (NSString *)tableView:(UITableView *)tableView realTitleForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        NSString *sectionTitle = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if (sectionTitle && sectionTitle.length > 0) {
            return sectionTitle;
        }
    }
    return nil;
}

// 是否有定义某个section的footer title
- (NSString *)tableView:(UITableView *)tableView realTitleForFooterInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        NSString *sectionFooter = [tableView.dataSource tableView:tableView titleForFooterInSection:section];
        if (sectionFooter && sectionFooter.length > 0) {
            return sectionFooter;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)isEmptyViewShowing {
    return self.emptyView && self.emptyView.superview;
}

- (void)showEmptyViewWithLoading {
    [self showEmptyView];
    [self.emptyView setImage:nil];
    [self.emptyView setLoadingViewHidden:NO];
    [self.emptyView setTextLabelText:nil];
    [self.emptyView setDetailTextLabelText:nil];
    [self.emptyView setActionButtonTitle:nil];
}

- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:nil text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithImage:(UIImage *)image
                          text:(NSString *)text
                    detailText:(NSString *)detailText
                   buttonTitle:(NSString *)buttonTitle
                  buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:image text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage *)image
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                     buttonTitle:(NSString *)buttonTitle
                    buttonAction:(SEL)action {
    [self showEmptyView];
    [self.emptyView setLoadingViewHidden:!showLoading];
    [self.emptyView setImage:image];
    [self.emptyView setTextLabelText:text];
    [self.emptyView setDetailTextLabelText:detailText];
    [self.emptyView setActionButtonTitle:buttonTitle];
    [self.emptyView.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.emptyView.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientationMask;
}

#pragma mark - 键盘交互

#pragma mark - <QMUINavigationControllerDelegate>

- (BOOL)shouldSetStatusBarStyleLight {
    return StatusbarStyleLightInitially;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)preferredNavigationBarHidden {
    return NavigationBarHiddenInitially;
}

- (void)viewControllerKeepingAppearWhenSetViewControllersWithAnimated:(BOOL)animated {
    // 通常和 viewWillAppear: 里做的事情保持一致
    [self setNavigationItemsIsInEditMode:NO animated:NO];
    [self setToolbarItemsIsInEditMode:NO animated:NO];
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
    [self.tableView reloadData];
}
#pragma mark - 添加下拉刷新
- (void)addPullRefreshWithBlock:(void(^)(void))block {
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        self.tableView.mj_footer.hidden = NO;
        if (block) {
            block();
        }
    }];
    ((MJRefreshNormalHeader*)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
}

#pragma mark - 上拉加载更多
- (void)addLoadingMoreWithBlock:(void(^)(void))block {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (block) {
            block();
        }
    }];
    // Set footer
    self.tableView.mj_footer = footer;
    footer.stateLabel.hidden = YES;//隐藏刷新时显示文字
}

- (void)endRefreshWithFooterHidden {
    [self.tableView.mj_footer endRefreshing];
    //通知已经全部加载完毕
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    self.tableView.mj_footer.hidden = YES;
}
@end

@implementation JWTableViewController (QMUISubclassingHooks)

- (void)initTableView {
    self.hasHideTableHeaderViewInitial = NO;
    self.tableViewInitialContentInset = QMUICommonTableViewControllerInitialContentInsetNotSet;
    self.tableViewInitialScrollIndicatorInsets = QMUICommonTableViewControllerInitialContentInsetNotSet;
    [self.tableView registerClass:[QMUITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:QMUICommonTableViewControllerSectionHeaderIdentifier];
    [self.tableView registerClass:[QMUITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:QMUICommonTableViewControllerSectionFooterIdentifier];
    
    if (@available(iOS 11, *)) {
        if ([self shouldAdjustTableViewContentInsetsInitially]) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    
}
- (void)initSubviews {
    // 子类重写
    [self initTableView];
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    // 子类重写
    self.navigationItem.titleView = self.titleView;
}

- (void)setToolbarItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    // 子类重写
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    // 子类重写
}

- (BOOL)shouldHideTableHeaderViewInitial {
    return NO;
}
@end

@implementation JWTableViewController (QMUIKeyboard)

- (UITapGestureRecognizer *)hideKeyboardTapGestureRecognizer {
    return _hideKeyboardTapGestureRecognizer;
}

- (QMUIKeyboardManager *)hideKeyboardManager {
    return _hideKeyboardManager;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    // 子类重写，默认返回 NO，也即不主动干预键盘的状态
    return YES;
}

@end

@implementation JWTableViewControllerHideKeyboardDelegateObject

- (instancetype)initWithViewController:(JWTableViewController *)viewController {
    if (self = [super init]) {
        self.viewController = viewController;
    }
    return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.viewController.hideKeyboardTapGestureRecognizer) {
        return YES;
    }
    
    if (![QMUIKeyboardManager isKeyboardVisible]) {
        return NO;
    }
    
    UIView *targetView = gestureRecognizer.qmui_targetView;
    
    // 点击了本身就是输入框的 view，就不要降下键盘了
    if ([targetView isKindOfClass:[UITextField class]] || [targetView isKindOfClass:[UITextView class]]) {
        return NO;
    }
    
    if ([self.viewController shouldHideKeyboardWhenTouchInView:targetView]) {
        [self.viewController.view endEditing:YES];
    }
    return NO;
}

#pragma mark - <QMUIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (![self.viewController qmui_isViewLoadedAndVisible]) return;
    BOOL hasOverrideMethod = [self.viewController qmui_hasOverrideMethod:@selector(shouldHideKeyboardWhenTouchInView:) ofSuperclass:[JWTableViewController class]];
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = hasOverrideMethod;
}

- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = NO;
}

@end
