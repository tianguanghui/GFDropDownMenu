# GFDropDownMenu
DropDownMenu+UICollectionView

1.首选感谢DOPDropDownMenu的作者：https://github.com/dopcn/DOPDropDownMenu ，我是讲里边的UITableView替换成了UICollectionView，可定制性更强一些。

2.效果图：
![](https://github.com/tianguanghui/GFDropDownMenu/blob/master/Screenshot.gif)

3.使用方式：
works the same as `UITableView` with a `dataSource` and a `delegate`

```objc
#pragma mark - data source protocol
@protocol DOPDropDownMenuDataSource <NSObject>
@required
- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column;
- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath;
@optional
//default value is 1
- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu;
@end

#pragma mark - delegate
@protocol DOPDropDownMenuDelegate <NSObject>
@optional
- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath;
@end
```




