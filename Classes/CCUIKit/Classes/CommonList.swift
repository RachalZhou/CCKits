//
//  CommonList.swift
//
//  Created by 周日朝 on 2020/5/26.
//  Copyright © 2020 ZRC. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class CommonCell<ItemType>: UITableViewCell {
    public var item: ItemType?
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol CommonListDelegate: AnyObject {
    func didSelectItem<Item>(_ item: Item)
    func pullHeaderToRefresh(_ endHandler: () -> Void)
    func pullFooterToLoadMore(_ endHandler: () -> Void, _ noMoreHandler: () -> Void)
}

extension CommonListDelegate {
    // optional method
    func didSelectItem<Item>(_ item: Item){}
    func pullHeaderToRefresh(_ endHandler: () -> Void){}
    func pullFooterToLoadMore(_ endHandler: () -> Void, _ noMoreHandler: () -> Void){}
}

/// 支持泛型的通用列表组件（已支持下拉刷新和上拉加载）
class CommonList<ItemType, CellType: CommonCell<ItemType>>: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView
    
    public var items: [ItemType] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    public var cellHeight: CGFloat = 44 {
        didSet {
            self.tableView.layoutIfNeeded()
        }
    }
    
    weak var delegate: CommonListDelegate?
    
    public var needHeaderRefresh: Bool = false {
        didSet {
            if needHeaderRefresh == true {
                tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self,
                                                            refreshingAction: #selector(refreshHeader))
            }
        }
    }
    
    public var needFooterRefresh: Bool = false {
        didSet {
            if needFooterRefresh == true {
                tableView.mj_footer = MJRefreshBackNormalFooter(refreshingTarget: self,
                                                                refreshingAction: #selector(refreshFooter))
            }
        }
    }
    
    //MARK: life cycle
    override init(frame: CGRect) {
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(frame: frame)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CellType? = tableView.dequeueReusableCell(withIdentifier: "cellId") as? CellType
        if cell == nil {
            cell = CellType(style: .subtitle, reuseIdentifier: "cellId")
        }
        cell?.item = items[indexPath.row]
        return cell!
    }
    
    //MARK: TableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectItem(items[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: private method
    @objc private func refreshHeader() {
        delegate?.pullHeaderToRefresh({
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
        })
    }
    
    @objc private func refreshFooter() {
        delegate?.pullFooterToLoadMore({
            self.tableView.reloadData()
            self.tableView.mj_footer?.endRefreshing()
        }, {
            self.tableView.reloadData()
            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
        })
    }
}
