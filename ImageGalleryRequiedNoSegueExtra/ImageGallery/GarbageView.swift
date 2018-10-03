//
//  GarbageView.swift
//  ImageGallery
//
//  Created by Tatiana Kornilova on 15/06/2018.
//  Copyright © 2018 Stanford University. All rights reserved.
//

import UIKit

class GarbageView: UIView, UIDropInteractionDelegate {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var myButton = UIButton()
    
    private func setup() {
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
        
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        let trashImage = UIImage.imageFromSystemBarButton(.trash)
        myButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        myButton.setImage(trashImage, for: .normal)
        self.addSubview(myButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.subviews.count > 0 {
            self.subviews[0].frame = CGRect(x: bounds.width - bounds.height, y: 0, width:  myButton.bounds.width, height: myButton.bounds.height)
        }
    }
    
    // MARK: - UIDropInteractionDelegate
    
    func dropInteraction(_ interaction: UIDropInteraction,
                     canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction,
              sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(
        _ interaction: UIDropInteraction,
        previewForDropping item: UIDragItem,
        withDefault defaultPreview: UITargetedDragPreview
        ) -> UITargetedDragPreview? {
        let target = UIDragPreviewTarget(
            container: self,
            center: CGPoint(x: bounds.width - bounds.size.height * 1 / 2,
                            y: bounds.size.height * 1 / 2),
            transform: CGAffineTransform(scaleX: 0.1, y: 0.1)
        )
        return defaultPreview.retargetedPreview(with: target)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { providers in
            if let collection = (session.localDragSession?.localContext as? UICollectionView),
                let images = (collection.dataSource as? ImageGalleryCollectionViewController)?.imageGallery.images,
                let items = session.localDragSession?.items {
                for item in items {
                    if let object = item.localObject as? ImageModel,
                        let index = images.index(of: object) {
                        let indexPath = IndexPath(item: index, section: 0)
                        collection.performBatchUpdates({
                            (collection.dataSource as? ImageGalleryCollectionViewController)?.imageGallery.images.remove(at: index)
                            collection.deleteItems(at: [indexPath])
                        })
                    }
                }
            }
        }
    }
}

extension UIImage{
    
    class func imageFromSystemBarButton(_ systemItem: UIBarButtonSystemItem, renderingMode:UIImageRenderingMode = .automatic)-> UIImage {
        
        let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
        
        // add to toolbar and render it
        let bar = UIToolbar()
        bar.setItems([tempItem], animated: false)
        bar.snapshotView(afterScreenUpdates: true)
        
        // got image from real uibutton
        let itemView = tempItem.value(forKey: "view") as! UIView
        
        for view in itemView.subviews {
            if view is UIButton {
                let button = view as! UIButton
                let image = button.imageView!.image!
                image.withRenderingMode(renderingMode)
                return image
            }
        }
        
        return UIImage()
    }
}
