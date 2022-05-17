//
//  PhotosCollectionViewController.swift
//  TonightsMeal
//
//  Created by austin on 4/21/22.
//

import UIKit

private let reuseIdentifier = "Cell"
private var model = RecipesModel.shared

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,
                                        UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
        let image: UIImage = model.images[indexPath.row]
        cell.cellImage.image = image
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/3, height: self.view.frame.height/5)
    }
    
    // add photo to collection view (Image Picker)
    @IBAction func addPhotoDidTapped(_ sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(#function)")
        let originalImage = info[.editedImage] as! UIImage
        model.images.append(originalImage)
        self.collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("\(#function)")
        picker.dismiss(animated: true, completion: nil)
    }
}
