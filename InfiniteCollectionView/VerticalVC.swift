//
//  ViewController2.swift
//  InfiniteCollectionView
//
//  Created by Denis Senichkin on 8/30/19.
//  Copyright © 2019 Denis Senichkin. All rights reserved.
//

import UIKit

private let kOffset: CGFloat = 5

class VerticalVC: UIViewController {
    
    private let items = ["5", "1", "2", "3", "4", "5", "1"]
    //private let colors:[UIColor] = [.red, .green, .orange, .white, .purple, .yellow, .blue]

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var bOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.numberOfPages = items.count - 2
        
        collectionView.isPagingEnabled = true
         collectionView.backgroundColor = .clear
        collectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .top, animated: false)
        }
    }
}

extension VerticalVC {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging willDecelerate \(decelerate), y \(scrollView.contentOffset.y)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            let center = CGPoint(x: scrollView.frame.width / 2, y: scrollView.contentOffset.y + (scrollView.frame.height / 2))
            if let ip = self?.collectionView.indexPathForItem(at: center) {
                print("scrollViewDidEndDragging \(ip.row)")
                
                NSObject.cancelPreviousPerformRequests(withTarget: strongSelf)
                //self.infiniteScrollLogic(index: ip.row)
                strongSelf.perform(#selector(strongSelf.infiniteScrollLogic(indexO:)), with: ip.row, afterDelay: 0.3)

            }
        }
    }
    
    @objc func infiniteScrollLogic(indexO: NSNumber) {
        
        let index = indexO.intValue
        
        if bOnce {
            //return
        }
        
        var newIndex = index
        
        if index == 0 { // at list start
            newIndex = items.count - 2
            print("infiniteScrollLogic 1 curIndex \(index), newIndex \(newIndex)")
            self.collectionView.scrollToItem(at: IndexPath(row: newIndex, section: 0), at: .centeredVertically, animated: false)
            bOnce = true

        } else if index == items.count - 1 { // at list end
            newIndex = 1
            print("infiniteScrollLogic 2 curIndex \(index) newIndex \(newIndex)")
            self.collectionView.scrollToItem(at: IndexPath(row: newIndex, section: 0), at: .centeredVertically, animated: false)
            bOnce = true

        }
        
        self.pageControl.currentPage = newIndex - 1
    }
}

extension VerticalVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kOffset*2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frameSize = collectionView.bounds.size
        return CGSize(width: frameSize.width, height: frameSize.height - kOffset*2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: kOffset, left: 0, bottom: kOffset, right: 0)
    }
}

extension VerticalVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        //cell.contentView.backgroundColor = UIColor.random()
        cell.contentView.backgroundColor = .lightGray
        
        if let lbTitle = cell.contentView.viewWithTag(1) as? UILabel, let index = indexPath.row as Int?, index < items.count {
            
            /*if index < colors.count {
                cell.contentView.backgroundColor = colors[index]
            }*/

            lbTitle.text = items[index]
        }
        return cell
    }
}

//MARK - Next/Prev buttons
extension VerticalVC {
    
    @IBAction func btnPrevClicked(_ sender: UIButton) {
        clickLogic(false)
    }
    
    @IBAction func btnNextClicked(_ sender: UIButton) {
        clickLogic(true)
    }
    
    private func clickLogic(_ isNext: Bool){
        let curIndex = pageControl.currentPage + 1
        var nextIndex = curIndex + (isNext ? 1 : -1)
        if nextIndex == 0 { //start of list
            nextIndex = items.count - 2
            print("clickLogic curIndex \(curIndex), nextIndex \(nextIndex)")
            self.collectionView.scrollToItem(at: IndexPath(row: nextIndex + 1, section: 0), at: .top, animated: false)
        } else if nextIndex == items.count - 1 { //end of list
            nextIndex = 1
            print("clickLogic curIndex \(curIndex), nextIndex \(nextIndex)")
            self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        } else {
            print("clickLogic curIndex \(curIndex), nextIndex \(nextIndex)")
        }
        
        
        pageControl.currentPage = nextIndex - 1
        self.collectionView.scrollToItem(at: IndexPath(row: nextIndex, section: 0), at: .top, animated: true)
    }
}
