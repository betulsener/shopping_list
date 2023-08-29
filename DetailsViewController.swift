//
//  DetailsViewController.swift
//  shopping_list
//
//  Created by Betul Sener on 29.08.2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var pickedProductName = ""
    var pickedProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if pickedProductName != "" {
            
            saveButton.isHidden = true
            //Showing the Core Data picked product info
            
            if let uuidString = pickedProductUUID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                //Gettind the products thats id equals to the uuidString
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                
                //Required when there are large data in CoreData
                
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let name = result.value(forKey: "name") as? String {
                                nameTextField.text = name
                                
                            }
                            if let price = result.value(forKey: "price") as? Int {
                                priceTextField.text = String(price)
                                
                            }
                            if let size = result.value(forKey: "size") as? String {
                                sizeTextField.text = size
                                
                            }
                            if let brand = result.value(forKey: "brand") as? String {
                                brandTextField.text = brand
                                
                            }
                            
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                } catch {
                    print("error")
                }
                
            }
                
                
                
            } else {
                
                saveButton.isHidden = false
                saveButton.isEnabled = false
                //Adding new product
                nameTextField.text = ""
                priceTextField.text = ""
                sizeTextField.text = ""
                brandTextField.text = ""
                
                
            }
            
        
        
        //Hiding the keybord
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeybord))
        view.addGestureRecognizer(gestureRecognizer)
        
        //Uploading product photo
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(uploadPhoto))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        //Swiping the Text Fields when the keybord has toggled
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func uploadPhoto(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height - 60
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
        
        @objc func hideKeybord() {
            view.endEditing(true)
        }
        
    @IBAction func saveButtonClicked(_ sender: Any) {
            
            //Defining AppDelegate as variable
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            //To save the object
            let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
            
            shopping.setValue(nameTextField.text!, forKey: "name")
            shopping.setValue(sizeTextField.text!, forKey: "size")
            shopping.setValue(brandTextField.text!, forKey: "brand")
            
            if let price = Int(priceTextField.text!) {
                shopping.setValue(price, forKey: "price")
            }
            
            shopping.setValue(UUID(), forKey: "id")
            
            let data = imageView.image!.jpegData(compressionQuality: 0.5)
            
            shopping.setValue(data, forKey: "image")
            
 
            do {
                try context.save()
                print("saved")
            } catch {
                print("error")
            }
        
        //Saving data to table view before going back
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataEntered"), object: nil)
        
        //To go back to table view VC
        self.navigationController?.popViewController(animated: true)
        
            
            
            
            
        }
        
}
