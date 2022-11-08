//
//  SJWaterFallLayout.swift
//
//  Created by Apple on 2022/11/8.
//

import UIKit

@objc protocol SJWaterFallLayoutDelegate: NSObjectProtocol {
    // Item高度
    func setCellHeight(layouyt: SJWaterFallLayout, indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat
    // 列数
    @objc optional func columnCountWith(layout: SJWaterFallLayout) -> Int
    // 列间距
    @objc optional func columnMarginWith(layout: SJWaterFallLayout) -> CGFloat
    // 行间距
    @objc optional func rowMarginWith(layout: SJWaterFallLayout) -> CGFloat
    // 边距
    @objc optional func edgeInsetsWith(layout: SJWaterFallLayout) -> UIEdgeInsets
    
}

class SJWaterFallLayout: UICollectionViewLayout {
    
    weak open var delegate: SJWaterFallLayoutDelegate?
    fileprivate let defaultColumnCount: Int = 3       // 列数
    fileprivate let defaultColumnMargin: CGFloat = 10 // 列间距
    fileprivate let defaultRowMargin: CGFloat = 10    // 行间距
    fileprivate let defaultEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 边距
    
    // 属性数组
    fileprivate lazy var attributes: [UICollectionViewLayoutAttributes] = []
    // 列高度数组
    fileprivate lazy var columnHeights: [CGFloat] = []
    // 内容高度
    fileprivate var contentHeight: CGFloat?
    
    // 列数
    fileprivate func columnCount() -> Int {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.columnCountWith(layout:))))! {
            return (self.delegate?.columnCountWith!(layout: self))!
        } else {
            return defaultColumnCount
        }
    }
    // 列间距
    fileprivate func columnMargin() -> CGFloat {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.columnMarginWith(layout:))))! {
            return (self.delegate?.columnMarginWith!(layout: self))!
        } else {
            return defaultColumnMargin
        }
    }
    // 行间距
    fileprivate func rowMargin() -> CGFloat {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.rowMarginWith(layout:))))! {
            return (self.delegate?.rowMarginWith!(layout: self))!
        } else {
            return defaultRowMargin
        }
    }
    // 边距
    fileprivate func edgeInsets() -> UIEdgeInsets {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.edgeInsetsWith(layout:))))! {
            return (self.delegate?.edgeInsetsWith!(layout: self))!
        } else {
            return defaultEdgeInsets
        }
    }
    
    override func prepare() {
        super.prepare()
        
        if self.collectionView == nil {
            return
        }
        // 清空列高度数组
        self.columnHeights.removeAll()
        // 清空高度内容
        self.contentHeight = 0
        // 加入默认顶部边距
        for _ in 0..<self.columnCount() {
            self.columnHeights.append(self.edgeInsets().top)
        }
        // 清除属性
        self.attributes.removeAll()
        // 获取Items数量
        let items: Int = (self.collectionView?.numberOfItems(inSection: 0))!
        // 获取View宽度
        let width: CGFloat = (self.collectionView?.frame.size.width)!
        // 获取列间距总和
        let columnMargin: CGFloat = (CGFloat)(self.columnCount() - 1) * self.columnMargin()
        // 计算cell宽度
        let cellWidth: CGFloat = (width - self.edgeInsets().left - self.edgeInsets().right - columnMargin) / CGFloat(self.columnCount())
        
        for i in 0..<items {
            let indexPath: IndexPath = IndexPath(item: i, section: 0)
            let attribute: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            // 获取高度
            let cellHeight: CGFloat = (self.delegate?.setCellHeight(layouyt: self, indexPath: indexPath, itemWidth: cellWidth))!
            // 默认最小高度为第一组
            var minColumnHeight: CGFloat = self.columnHeights[0]
            var minColumn: Int = 0
            // 筛选最小高度的组
            for i in 1..<self.columnCount() {
                let colHeight = self.columnHeights[i]
                if colHeight < minColumnHeight {
                    minColumnHeight = colHeight
                    minColumn = i
                }
            }
            // 将下一个cell添加在最小高度的那一组
            let cellX: CGFloat = self.edgeInsets().left + CGFloat(minColumn) * (self.columnMargin() + cellWidth)
            var cellY: CGFloat = minColumnHeight
            if cellY != self.edgeInsets().top {
                // 如果不是第一次加入需要加上行间距
                cellY = self.rowMargin() + cellY
            }
            // 设置Frame
            attribute.frame = CGRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
            // 当前的最大Y值是新加的这个Cell的底部
            let maxY = cellY + cellHeight
            // 修改该组的列高度
            self.columnHeights[minColumn] = maxY
            // 比较当前的最大高度是否大于内容高度的
            let maxContentHeight: CGFloat = self.columnHeights[minColumn]
            if CGFloat(self.contentHeight!) < CGFloat(maxContentHeight) {
                // 大于修改内容高度
                self.contentHeight = maxContentHeight
            }
            // 添加属性
            self.attributes.append(attribute)
        }
    }
    // 属性数组
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.attributes
    }
    // 内容高度
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: 0, height: CGFloat(self.contentHeight!) + CGFloat(self.edgeInsets().bottom))
        }
        set {
            self.collectionViewContentSize = newValue
        }
    }
    
}
