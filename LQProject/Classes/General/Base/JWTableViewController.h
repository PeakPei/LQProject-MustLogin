
#import <UIKit/UIKit.h>
#import <QMUIKit/QMUIKit.h>
#import "QDThemeProtocol.h"

@class QMUINavigationTitleView;
@class QMUIEmptyView;

/**
 *  配合属性 `tableViewInitialContentInset` 使用，标志 `tableViewInitialContentInset` 是否有被修改过
 *  @see tableViewInitialContentInset
 */
extern const UIEdgeInsets QMUICommonTableViewControllerInitialContentInsetNotSet;

extern NSString *const QMUICommonTableViewControllerSectionHeaderIdentifier;
extern NSString *const QMUICommonTableViewControllerSectionFooterIdentifier;

/**
 *  可作为项目内所有 `UITableViewController` 的基类，注意是继承自 `QMUICommonViewController` 而不是 `UITableViewController`。
 *
 *  一般通过 `initWithStyle:` 方法初始化，对于要生成 `UITableViewStylePlain` 类型的列表，推荐使用 `init:` 方法。
 *
 *  提供的功能包括：
 *
 *  1. 集成 `QMUISearchController`，可通过属性 `shouldShowSearchBar` 来快速为列表生成一个 searchBar 及 searchController，具体请查看 QMUICommonTableViewController (Search)。
 *
 *  2. 通过属性 `tableViewInitialContentInset` 和 `tableViewInitialScrollIndicatorInsets` 来提供对界面初始状态下的列表 `contentInset`、`contentOffset` 的调整能力，一般在系统的 `automaticallyAdjustsScrollViewInsets` 属性无法满足需求时使用。
 *
 *  @note emptyView 会从 tableHeaderView 的下方开始布局到 tableView 最底部，因此它会遮挡 tableHeaderView 之外的部分（比如 tableFooterView 和 cells ），你可以重写 layoutEmptyView 来改变这个布局方式
 *
 *  @see QMUISearchController
 */
@interface JWTableViewController : UITableViewController<QMUINavigationControllerDelegate, QDChangingThemeDelegate>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitialized NS_REQUIRES_SUPER;

/**
 *  QMUICommonViewController默认都会增加一个QMUINavigationTitleView的titleView，然后重写了setTitle来间接设置titleView的值。所以设置title的时候就跟系统的接口一样：self.title = xxx。
 *
 *  同时，QMUINavigationTitleView提供了更多的功能，具体可以参考QMUINavigationTitleView的文档。<br/>
 *  @see QMUINavigationTitleView
 */
@property(nonatomic, strong, readonly) QMUINavigationTitleView *titleView;

/**
 *  修改当前界面要支持的横竖屏方向，默认为 SupportedOrientationMask
 */
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

/**
 *  空列表控件，支持显示提示文字、loading、操作按钮
 */
@property(nonatomic, strong) QMUIEmptyView *emptyView;

/// 当前self.emptyView是否显示
@property(nonatomic, assign, readonly, getter = isEmptyViewShowing) BOOL emptyViewShowing;

/**
 *  显示emptyView
 *  emptyView 的以下系列接口可以按需进行重写
 *
 *  @see QMUIEmptyView
 */
- (void)showEmptyView;

/**
 *  显示loading的emptyView
 */
- (void)showEmptyViewWithLoading;

/**
 *  显示带text、detailText、button的emptyView
 */
- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(SEL)action;

/**
 *  显示带image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithImage:(UIImage *)image
                          text:(NSString *)text
                    detailText:(NSString *)detailText
                   buttonTitle:(NSString *)buttonTitle
                  buttonAction:(SEL)action;

/**
 *  显示带loading、image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage *)image
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                     buttonTitle:(NSString *)buttonTitle
                    buttonAction:(SEL)action;

/**
 *  隐藏emptyView
 */
- (void)hideEmptyView;

/**
 *  布局emptyView，如果emptyView没有被初始化或者没被添加到界面上，则直接忽略掉。
 *
 *  如果有特殊的情况，子类可以重写，实现自己的样式
 *
 *  @return YES表示成功进行一次布局，NO表示本次调用并没有进行布局操作（例如emptyView还没被初始化）
 */
- (BOOL)layoutEmptyView;
/**
 *  列表使用自定义的contentInset，不使用系统默认计算的，默认为QMUICommonTableViewControllerInitialContentInsetNotSet。<br/>
 *  @warning 当更改了这个值后，在 iOS 11 及以后里，会把 self.tableView.contentInsetAdjustmentBehavior 改为 UIScrollViewContentInsetAdjustmentNever，而在 iOS 11 以前，会把 self.automaticallyAdjustsScrollViewInsets 改为 NO。
 */
@property(nonatomic, assign) UIEdgeInsets tableViewInitialContentInset;

/**
 *  是否需要让scrollIndicatorInsets与tableView.contentInsets区分开来，如果不设置，则与tableView.contentInset保持一致。
 *
 *  只有当更改了tableViewInitialContentInset后，这个属性才会生效。
 */
@property(nonatomic, assign) UIEdgeInsets tableViewInitialScrollIndicatorInsets;

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force;


/**
 添加下拉刷新
 */
- (void)addPullRefreshWithBlock:(nullable void(^)(void))block;

/**
 添加上拉加载更多
 
 @param block 上拉加载回调
 */
- (void)addLoadingMoreWithBlock:(nullable void(^)(void))block;

/**
 停止上拉加载更多并隐藏footer
 */
- (void)endRefreshWithFooterHidden;
@end


@interface JWTableViewController (QMUISubclassingHooks)

/**
 *  负责初始化和设置controller里面的view，也就是self.view的subView。目的在于分类代码，所以与view初始化的相关代码都写在这里。
 *
 *  @warning initSubviews只负责subviews的init，不负责布局。布局相关的代码应该写在 <b>viewDidLayoutSubviews</b>
 */
- (void)initSubviews NS_REQUIRES_SUPER;

/**
 *  负责设置和更新navigationItem，包括title、leftBarButtonItem、rightBarButtonItem。viewDidLoad里面会自动调用，允许手动调用更新。目的在于分类代码，所有与navigationItem相关的代码都写在这里。在需要修改navigationItem的时候都只调用这个接口。
 *
 *  @param isInEditMode 是否用于编辑模式下
 *  @param animated     是否使用动画呈现
 */
- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated NS_REQUIRES_SUPER;

/**
 *  负责设置和更新toolbarItem。在viewWillAppear里面自动调用（因为toolbar是navigationController的，是每个界面公用的，所以必须在每个界面的viewWillAppear时更新，不能放在viewDidLoad里），允许手动调用。目的在于分类代码，所有与toolbarItem相关的代码都写在这里。在需要修改toolbarItem的时候都只调用这个接口。
 *
 *  @param isInEditMode 是否用于编辑模式下
 *  @param animated     是否使用动画呈现
 */
- (void)setToolbarItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated NS_REQUIRES_SUPER;

/**
 *  动态字体的回调函数。
 *
 *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
 *
 *  @param notification test
 */
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification;

/**
 *  是否需要在第一次进入界面时将tableHeaderView隐藏（通过调整self.tableView.contentOffset实现）
 *
 *  默认为NO
 *
 *  @see QMUITableViewDelegate
 */
- (BOOL)shouldHideTableHeaderViewInitial;
@end

/**
 *  为了方便实现“点击空白区域降下键盘”的需求，QMUICommonViewController 内部集成一个 tap 手势对象并添加到 self.view 上，而业务只需要通过重写 -shouldHideKeyboardWhenTouchInView: 方法并根据当前被点击的 view 返回一个 BOOL 来控制键盘的显隐即可。
 *  @note 为了避免不必要的事件拦截，集成的手势 hideKeyboardTapGestureRecognizer：
 *  1. 默认的 enabled = NO。
 *  2. 如果当前 viewController 或其父类（非 QMUICommonViewController 那个层级的父类）没重写 -shouldHideKeyboardWhenTouchInView:，则永远 enabled = NO。
 *  3. 在键盘升起时，并且当前 viewController 重写了 -shouldHideKeyboardWhenTouchInView: 且处于可视状态下，此时手势的 enabled 才会被修改为 YES，并且在键盘消失时置为 NO。
 */
@interface JWTableViewController (QMUIKeyboard)

/// 在 viewDidLoad 内初始化，并且 gestureRecognizerShouldBegin: 必定返回 NO。
@property(nonatomic, strong, readonly) UITapGestureRecognizer *hideKeyboardTapGestureRecognizer;
@property(nonatomic, strong, readonly) QMUIKeyboardManager *hideKeyboardManager;

/**
 *  当用户点击界面上某个 view 时，如果此时键盘处于升起状态，则可通过重写这个方法并返回一个 YES 来达到“点击空白区域自动降下键盘”的需求。默认返回 NO，也即不处理键盘。
 *  @warning 注意如果被点击的 view 本身消耗了事件（iOS 11 下测试得到这种类型的所有系统的 view 仅有 UIButton 和 UISwitch），则这个方法并不会被触发。
 *  @warning 有可能参数传进去的 view 是某个 subview 的 subview，所以建议用 isDescendantOfView: 来判断是否点到了某个目标 subview
 */
- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view;

@end
