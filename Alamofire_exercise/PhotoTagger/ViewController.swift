/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Alamofire


class ViewController: UIViewController {

  
  // MARK: - IBOutlets
  @IBOutlet var takePictureButton: UIButton!
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var progressView: UIProgressView!
  @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
  
  // MARK: - Properties
  private var tags: [String]?
  private var colors: [PhotoColor]?

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
      takePictureButton.setTitle("Select Photo", forState: .Normal)
    }
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    imageView.image = nil
  }

  // MARK: - Navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    if segue.identifier == "ShowResults" {
      guard let controller = segue.destinationViewController as? TagsColorsViewController else {
        fatalError("Storyboard mis-configuration. Controller is not of expected type TagsColorsViewController")
      }

      controller.tags = tags
      controller.colors = colors
    }
  }

  // MARK: - IBActions
  @IBAction func takePicture(sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false

    if UIImagePickerController.isSourceTypeAvailable(.Camera) {
      picker.sourceType = UIImagePickerControllerSourceType.Camera
    } else {
      picker.sourceType = .PhotoLibrary
      picker.modalPresentationStyle = .FullScreen
    }

    presentViewController(picker, animated: true, completion: nil)
  }
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      print("Info did not have the required UIImage for the Original Image")
      dismissViewControllerAnimated(true, completion: nil)
      return
    }
    imageView.image = image
    
    //开始上传照片。隐藏takePictureButton，显示progressView和activityIndicatorView
    takePictureButton.hidden = true
    progressView.progress = 0.0
    progressView.hidden = false
    activityIndicatorView.startAnimating()
    
    uploadImage(image, progress: { [unowned self](percent) in
     //progressView显示上传进度
      self.progressView.setProgress(percent, animated: true)
      
      }) { [unowned self](tags, colors) in
        
        //上传完成，恢复原状
        self.takePictureButton.hidden = false
        self.progressView.hidden = true
        self.activityIndicatorView.stopAnimating()
        
        self.tags = tags
        self.colors = colors
        //上传成功后，转到Results Scene
        self.performSegueWithIdentifier("ShowResults", sender: self)
    }
    dismissViewControllerAnimated(true, completion: nil)
  }
}
//Networking calls

extension ViewController {
  func uploadImage(image: UIImage, progress:(percent: Float) -> Void, completion: (tags:[String], colors: [PhotoColor]) -> Void) {
    ////将UIImage格式转换为NSData格式
    guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
      print("Could not get JPEG representation of UIImage.")
      return
    }
    
    Alamofire.upload(.POST, "http://api.imagga.com/v1/content", headers: ["Authorization" : "Basic YWNjXzMxNWE1YjQ4N2E1NWFmMzpkNzczODkxMTlhOTkyNzQxYjBkZmMyMmVkYjM3MzQ4NA=="], multipartFormData: { (multipartFormData) in
      multipartFormData.appendBodyPart(data: imageData, name: "imagefile", fileName: "image.jpg", mimeType: "image/jpeg")
      }) { (encodingResult) in
        switch encodingResult {
        case .Success(let upload,_,_):
          upload.progress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
            dispatch_async(dispatch_get_main_queue(), { 
              let percent = (Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
              progress(percent: percent)
            })
          })
          upload.validate()
          upload.responseJSON(completionHandler: { (response) in
            guard response.result.isSuccess else {
              print("Error while uploading file: \(response.result.error)")
              completion(tags: [String](), colors: [PhotoColor]())
              return
            }
            
            guard let responseJSON = response.result.value as? [String : AnyObject],
              uploadedFiles = responseJSON["uploaded"] as? [AnyObject], firstFile = uploadedFiles.first as? [String : AnyObject], firstFileID = firstFile["id"] as? String else {
                print("Invalid information from services.")
                completion(tags: [String](), colors: [PhotoColor]())
                return
            }
            print("Content uploaded with ID: \(firstFileID)")
            completion(tags: [String](), colors: [PhotoColor]())
            
          })
        case .Failure(let encodingError):
          print(encodingError)
        }
    }
    
  
    
    
    Alamofire.request(.GET, "https://httpbin.org/get", parameters: ["foo" : "bar"]).responseJSON { (response) in
      print(response.request) //请求对象
      print(response.response) //响应对象
      print(response.data) //服务端返回的数据
      print(response.result) //response serialization的结果
      
      if let JSON = response.result.value {
        print("JSON : \(JSON)")
      }
    }
    
    
    
    
  }

}