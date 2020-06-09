//
//  BannerView.swift
//
//  Created by 周日朝 on 2020/5/28.
//  Copyright © 2020 ZRC. All rights reserved.
//

import UIKit
import SnapKit

public protocol BannerViewDataSource: AnyObject {
    func numberOfBanners(_ bannerView: BannerView) -> Int
    func viewForBanner(_ bannView: BannerView, index: Int, convertView: UIView?) -> UIView
}

public protocol BannerViewDelegate: AnyObject {
    func didSelectBanner(_ bannerView: BannerView, index: Int)
}

public enum Position {
    case left
    case center
    case right
}

/// 纯Swift Banner组件（支持手动和自动的滚动方式）
public class BannerView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private static var convertViewTag = 911128
    private static var cellId = "bannerViewCellId"
    
    private var collectionView: UICollectionView
    private var pageControl: UIPageControl
    
    private var timer: Timer?
    public var isInfinite: Bool = true
    
    public var pageControlPosition: Position = .center {
        didSet {
            pageControl.snp.remakeConstraints { (make) in
                if pageControlPosition == .left {
                    make.left.equalToSuperview().offset(15)
                }else if pageControlPosition == .right {
                    make.right.equalToSuperview().offset(-15)
                }else {
                    make.centerX.equalToSuperview()
                }
                make.bottom.equalToSuperview().offset(-10)
            }
        }
    }
    
    public weak var dataSource: BannerViewDataSource! {
        didSet {
            pageControl.numberOfPages = dataSource.numberOfBanners(self)
            collectionView.reloadData()
            if isInfinite {
                DispatchQueue.main.async {
                    let offset = CGPoint(x: self.collectionView.frame.width, y: 0)
                    self.collectionView.setContentOffset(offset, animated: false)
                }
            }
        }
    }
    public weak var delegate: BannerViewDelegate?
    
    public var autoScrollInterval = 2 {
        didSet {
            autoScrollInterval > 0 ? startAutoScroll() : stopAutoScroll()
        }
    }
    
    // MARK: - life cycle
    public override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), collectionViewLayout: flowLayout)
        pageControl = UIPageControl()
        super.init(frame: frame)
        setupViews()
        autoScrollInterval > 0 ? startAutoScroll() : stopAutoScroll()
    }
    
    private func setupViews() {
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: BannerView.cellId)
        
        self.addSubview(collectionView)
        self.addSubview(pageControl)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewDataSource
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataSource.numberOfBanners(self)
        if isInfinite {
            if count == 1 {
                return 1
            }else {
                return count + 2
            }
        }else {
            return count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerView.cellId, for: indexPath)
        let index = indexForItem(indexPath.row)
        
        if let view = cell.contentView.viewWithTag(BannerView.convertViewTag) {
            let _ = dataSource.viewForBanner(self, index: index, convertView: view)
        }else {
            let newView = dataSource.viewForBanner(self, index: index, convertView: nil)
            newView.tag = BannerView.convertViewTag
            cell.contentView.addSubview(newView)
            newView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexForItem(indexPath.row)
        delegate?.didSelectBanner(self, index: index)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.bounds.size
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let current = Int(round(collectionView.contentOffset.x / collectionView.frame.width))
        pageControl.currentPage = indexForItem(current)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let total = dataSource.numberOfBanners(self)
        let current = Int(round(collectionView.contentOffset.x / collectionView.frame.width))
        
        if current >= total + 1 {
            collectionView.setContentOffset(CGPoint(x: collectionView.frame.width, y: 0), animated: false)
        }
        
        if current <= 0 {
            collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(total), y: 0), animated: false)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
        scrollViewDidEndScrollingAnimation(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startAutoScroll()
    }
    
    // MARK: - private method
    private func startAutoScroll() {
        guard autoScrollInterval > 0 && timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(autoScrollInterval), target: self, selector: #selector(flipNext), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func stopAutoScroll() {
        if let t = timer {
            t.invalidate()
            timer = nil
        }
    }
    
    @objc private func flipNext() {
        guard let _ = superview, let _ = window else {
            return
        }
        
        let totalCount = dataSource.numberOfBanners(self)
        guard totalCount > 1 else {
            return
        }
        
        let current = Int(round(collectionView.contentOffset.x / collectionView.frame.width))
        if isInfinite {
            let next = current + 1
            collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(next), y: 0), animated: true)
            
            if next >= totalCount + 1 {
                pageControl.currentPage = 0
            }else {
                pageControl.currentPage = next - 1
            }
        }else {
            var next = current + 1
            if next >= totalCount {
                next = 0
            }
            collectionView.setContentOffset(CGPoint(x: collectionView.frame.width * CGFloat(next), y: 0), animated: true)
            
            pageControl.currentPage = next
        }
    }
    
    private func indexForItem(_ currentPage: Int) -> Int {
        var index = currentPage
        if isInfinite {
            let count = dataSource.numberOfBanners(self)
            if count > 1 {
                if currentPage == 0 {
                    index = count - 1
                } else if currentPage == count + 1 {
                    index = 0
                } else {
                    index = currentPage - 1
                }
            }
        }
        return index
    }
}
