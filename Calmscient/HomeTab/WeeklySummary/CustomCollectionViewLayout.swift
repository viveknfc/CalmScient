//
//  CustomCollectionViewLayout.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import UIKit

class CustomCollectionViewLayout: UICollectionViewLayout {
    
    /// Configure below properties for Custom the layout.
    var cellSize:CGSize = CGSize.zero
    var headerSize:CGSize = CGSize.zero
    var collectionViewInsets:UIEdgeInsets = UIEdgeInsets.zero
    var lineSpacing:CGFloat = 0
    var cellSpacing:CGFloat = 0
    
    private var contentWidth:CGFloat = 0
    private var contentHeight:CGFloat = 0
    
    private var scrollingDirection:UICollectionView.ScrollDirection = .horizontal
    private var contentBounds:CGRect = .zero
    
    
    private var headerCollectionViewAttributes:[IndexPath:UICollectionViewLayoutAttributes] = [:]
    private var cellCollectionViewAttributes:[IndexPath:UICollectionViewLayoutAttributes] = [:]
    
    
    override func prepare() {
        super.prepare()
        guard headerCollectionViewAttributes.keys.isEmpty, cellCollectionViewAttributes.keys.isEmpty, let collectionView = collectionView else {
            return
        }
        contentWidth = 0
        contentHeight = 0
        contentBounds = collectionView.bounds
        print("CBounds \(collectionView.bounds)")
        contentHeight += collectionViewInsets.top
        var YPosition:CGFloat = 0
        for section in 0..<collectionView.numberOfSections {
            //            let headerIndexPath = IndexPath(item: 0, section: section)
            //            let sectionAttribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndexPath)
            //            sectionAttribute.frame = CGRect(x: contentBounds.minX + 20, y: YPosition, width: headerSize.width, height: headerSize.height)
            //            YPosition = YPosition + headerSize.height
            //            headerCollectionViewAttributes[headerIndexPath] = sectionAttribute
            var cellXPosition:CGFloat = collectionViewInsets.left
            var cellYPosition:CGFloat = collectionViewInsets.top
            var cellXCount:Int = 0
            for cell in 0..<collectionView.numberOfItems(inSection: section) {
                //                if cell == 0 {
                //                    YPosition += lineSpacing
                //                }
                //                let cellIndexPath = IndexPath(item: cell, section: section)
                //                let cellLayoutAttribute = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                //                cellLayoutAttribute.frame = CGRect(x: cellXPosition, y: YPosition, width: cellSize.width, height: cellSize.height)
                ////                print("Cell Frame \(cellLayoutAttribute.frame)")
                //                cellXPosition += (cellSize.width + cellSpacing)
                //                cellCollectionViewAttributes[cellIndexPath] = cellLayoutAttribute
                //                if (cell == (collectionView.numberOfItems(inSection: section) - 1)){
                //                    cellXPosition += collectionViewInsets.right
                //                }
                if cellXCount == 0 {
                    contentWidth = cellXPosition + collectionViewInsets.right
                    cellXPosition = collectionViewInsets.left
                }
                var cellPosition:CGRect = CGRect.zero
                if cell % 2 == 0 {
                    cellPosition = CGRect(x: cellXPosition, y: cellYPosition, width: cellSize.width, height: cellSize.height)
                    cellXPosition += (cellSize.width + cellSpacing)
                } else {
                    cellPosition = CGRect(x: cellXPosition, y: cellYPosition, width: cellSize.width, height: cellSize.height)
                    cellYPosition += (cellSize.height + cellSpacing)
                    contentHeight = cellYPosition
                }
                cellXCount += 1
                cellXCount = cellXCount % 2
                let cellIndexPath = IndexPath(item: cell, section: section)
                let cellLayoutAttribute = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                cellLayoutAttribute.frame = cellPosition
                cellCollectionViewAttributes[cellIndexPath] = cellLayoutAttribute
                
            }
            YPosition += collectionViewInsets.bottom
        }
        contentHeight += collectionViewInsets.bottom
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var collectionAttributes:[UICollectionViewLayoutAttributes] = []
        for (_ , headerAttribute) in headerCollectionViewAttributes {
            if (headerAttribute.frame.intersects(rect)) {
                collectionAttributes.append(headerAttribute)
            }
        }
        for (_ , cellAttribute) in cellCollectionViewAttributes {
            if (cellAttribute.frame.intersects(rect)) {
                collectionAttributes.append(cellAttribute)
            }
        }
        return collectionAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellCollectionViewAttributes[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return headerCollectionViewAttributes[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        contentWidth = 0
        contentHeight = 0
        headerCollectionViewAttributes = [:]
        cellCollectionViewAttributes = [:]
    }
    
    override var collectionViewContentSize: CGSize {
        print("Content Size \(contentWidth) \(contentHeight)")
        return CGSize(width: contentWidth + 200, height: contentHeight + 200)
    }
    
}
