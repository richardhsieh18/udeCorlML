//
//  ViewController.swift
//  udeCoreML
//
//  Created by chang on 2017/9/15.
//  Copyright © 2017年 chang. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var chooseImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
 
    
    //imagePicker
    @IBAction func btnClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imgView.image!) {
            self.chooseImage = ciImage
        }
        recognizeImage(image: chooseImage)
    }
    
    func recognizeImage(image: CIImage) {
        lblName.text = "Finding...."
        if let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model ) {
            let request = VNCoreMLRequest(model: model, completionHandler: { (vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    let topResult = results.first
                    DispatchQueue.main.async {
                        let conf = (topResult?.confidence)! * 100
                        let rounded = Int(conf * 100) / 100
                        self.lblName.text = "\(rounded) % it's Like a \(String(describing: topResult!.identifier)) "
                    }
                }
            })
            let handler = VNImageRequestHandler(ciImage: chooseImage)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                 try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
    }
}

