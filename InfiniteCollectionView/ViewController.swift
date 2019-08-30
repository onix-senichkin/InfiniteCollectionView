//
//  ViewController.swift
//  InfiniteCollectionView
//
//  Created by Denis Senichkin on 8/30/19.
//  Copyright © 2019 Denis Senichkin. All rights reserved.
//

import UIKit

private let kOffset: CGFloat = 5

class ViewController: UIViewController {
    
    private let items = ["4", "1", "2", "3", "4", "1"]

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.numberOfPages = items.count - 2
        pageControl.backgroundColor = .clear
        pageControl.addTarget(self, action: #selector(pageControlTapped), for: .valueChanged)
        
        collectionView.isPagingEnabled = true
        collectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .left, animated: false)
        }
    }
}

extension ViewController {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
            if let ip = self?.collectionView.indexPathForItem(at: center) {
                print("scrollViewDidEndDragging \(ip.row)")
                self?.infiniteScrollLogic(index: ip.row)
            }
        }
    }
    
    func infiniteScrollLogic(index: Int) {
        
        var newIndex = index
        
        if index == 0 { // at list start
            newIndex = items.count - 2
            self.collectionView.scrollToItem(at: IndexPath(row: newIndex, section: 0), at: .left, animated: false)
        } else if index == items.count - 1 { // at list end
            newIndex = 1
            self.collectionView.scrollToItem(at: IndexPath(row: newIndex, section: 0), at: .left, animated: false)
        }
        
        self.pageControl.currentPage = newIndex - 1
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kOffset*2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameSize = collectionView.bounds.size
        return CGSize(width: frameSize.width - kOffset*2, height: frameSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: kOffset, bottom: 0, right: kOffset)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        //cell.contentView.backgroundColor = UIColor.random()
        cell.contentView.backgroundColor = .lightGray
        if let lbTitle = cell.contentView.viewWithTag(1) as? UILabel, let index = indexPath.row as Int?, index < items.count {
            lbTitle.text = items[index]
        }
        return cell
    }
}

//MARK - Next/Prev buttons
extension ViewController {
    
    @IBAction func btnPrevClicked(_ sender: UIButton) {
        clickLogic(false)
    }
    
    @IBAction func btnNextClicked(_ sender: UIButton) {
        clickLogic(true)
    }
    
    private func clickLogic(_ isNext: Bool){
        let curIndex = pageControl.currentPage + 1
        let nextIndex = curIndex + (isNext ? 1 : -1)
        updateItem(to: nextIndex)
    }
    
    private func updateItem(to next: Int) {
        var nextIndex = next
        if nextIndex == 0 { //start of list
            nextIndex = items.count - 2
            self.collectionView.scrollToItem(at: IndexPath(row: nextIndex + 1, section: 0), at: .left, animated: false)
        } else if nextIndex == items.count - 1 { //end of list
            nextIndex = 1
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
        }
        
        pageControl.currentPage = nextIndex - 1
        selectItem(at: nextIndex)
    }
    
    private func selectItem(at index: Int) {
        self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .left, animated: true)
    }
}

//MARK: PageControl events
extension ViewController {
    
    @objc private func pageControlTapped(sender: UIPageControl) {
        print("tapped \(sender.currentPage)")
        updateItem(to: sender.currentPage + 1)
    }
}

extension CGFloat {
    
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(red:   .random(), green: .random(), blue:  .random(), alpha: 1.0)
    }
}
