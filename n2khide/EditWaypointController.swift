//
//  EditWaypointController.swift
//  n2khide
//
//  Created by localuser on 30.05.18.
//  Copyright © 2018 cqd.ch. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation

protocol  setWayPoint  {
    func didSetName(originalName: String?, name: String?)
    func didSetHint(name: String?, hint: String?)
    func didSetImage(name: String?, image: UIImage?)
    func didSetChallenge(name: String?, challenge: String?)
    func didSetURL(name: String?, URL:String?)
    func didSetProximity(name: String?, proximity: CLProximity?)
}

class EditWaypointController: UIViewController, UIDropInteractionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var hereLabel: UIImageView!
    @IBOutlet weak var nearLabel: UIImageView!
    @IBOutlet weak var farLabel: UIImageView!
    @IBOutlet weak var thereLabel: UIImageView!
    
    // MARK: Document Picker
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        //code
    }
    
    var setWayPoint: setWayPoint!
    var me:HiddingViewController!
    var lastProximity: CLProximity? {
        willSet {
            if lastProximity == .near, manProx == nil {
                hereLabel.backgroundColor = UIColor.clear
                nearLabel.backgroundColor = UIColor.yellow
                farLabel.backgroundColor = UIColor.yellow
                thereLabel.backgroundColor = UIColor.yellow
            }
            if lastProximity == .far, manProx == nil {
                hereLabel.backgroundColor = UIColor.clear
                nearLabel.backgroundColor = UIColor.clear
                farLabel.backgroundColor = UIColor.yellow
                thereLabel.backgroundColor = UIColor.yellow
            }
            if lastProximity == .immediate, manProx == nil {
                hereLabel.backgroundColor = UIColor.yellow
                nearLabel.backgroundColor = UIColor.yellow
                farLabel.backgroundColor = UIColor.yellow
                thereLabel.backgroundColor = UIColor.yellow
            }
            if lastProximity == .unknown, manProx == nil {
                hereLabel.backgroundColor = UIColor.clear
                nearLabel.backgroundColor = UIColor.clear
                farLabel.backgroundColor = UIColor.clear
                thereLabel.backgroundColor = UIColor.yellow
            }
        }
    }
    
    //MARK: Camera and Library routines
    
    

    @IBAction func dragDropButton(_ sender: Any) {
//        let importMenu = UIDocumentMenuViewController(documentTypes: [(kUTTypeText as NSString) as String], in: .import)
//        importMenu.delegate = self
//        importMenu.addOption(withTitle: "Create New Document", image: nil, order: .first, handler: { print("New Doc Requested") })
//        present(importMenu, animated: true, completion: nil)
        let documentPicker = UIDocumentPickerViewController(documentTypes: [(kUTTypeImage as NSString) as String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    // MARK:- UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
            DispatchQueue.main.async() {
                self.setWayPoint.didSetImage(name: self.nameTextField.text, image: UIImage(data: data))
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    
    

    @IBOutlet weak var CameraButton: UIButton! {
        didSet {
            CameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        }
    }
    
    
    @IBAction func WebBrowser(_ sender: Any) {
        performSegue(withIdentifier: Constants.WebViewController, sender: view)
    }
    
    @IBAction func Camera(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: {
//            let prox2U = self.manProx != nil ? self.manProx : self.lastProximity
//           self.setWayPoint.didSetProximity(name: self.nameTextField.text, proximity: prox2U)
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = (info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as? UIImage) {
            DispatchQueue.main.async {
//                self.updateImage(image2U: image)
                self.setWayPoint.didSetImage(name: self.nameTextField.text, image: image)
            }
        }
        picker.presentingViewController?.dismiss(animated: true, completion: {
//            let prox2U = self.manProx != nil ? self.manProx : self.lastProximity
//            self.setWayPoint.didSetProximity(name: self.nameTextField.text, proximity: prox2U)
        })
    }
    
    @IBAction func Library(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeImage as String]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var challengeTextField: UITextField!
    
    var nameText: String?
    var hintText: String?
    var challengeText: String?
    var manProx: CLProximity?
    
    //MARK: Gesture methods
    
    @objc func hereTap(_ sender: UITapGestureRecognizer) {
        manProx = CLProximity.immediate
        hereLabel.backgroundColor = UIColor.yellow
        nearLabel.backgroundColor = UIColor.yellow
        farLabel.backgroundColor = UIColor.yellow
        thereLabel.backgroundColor = UIColor.yellow
    }
    
    @objc func nearTap(_ sender: UITapGestureRecognizer) {
        manProx = CLProximity.near
        hereLabel.backgroundColor = UIColor.clear
        nearLabel.backgroundColor = UIColor.yellow
        farLabel.backgroundColor = UIColor.yellow
        thereLabel.backgroundColor = UIColor.yellow
    }
    
    @objc func farTap(_ sender: UITapGestureRecognizer) {
        manProx = CLProximity.far
        hereLabel.backgroundColor = UIColor.clear
        nearLabel.backgroundColor = UIColor.clear
        farLabel.backgroundColor = UIColor.yellow
        thereLabel.backgroundColor = UIColor.yellow
    }
    
    @objc func thereTap(_ sender: UITapGestureRecognizer) {
        manProx = CLProximity.unknown
        hereLabel.backgroundColor = UIColor.clear
        nearLabel.backgroundColor = UIColor.clear
        farLabel.backgroundColor = UIColor.clear
        thereLabel.backgroundColor = UIColor.yellow
    }
    
    // MARK: View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIDevice.current.userInterfaceIdiom == .phone {
            // not needed
        }
        
        let hereTap = UITapGestureRecognizer(target: self, action: #selector(self.hereTap(_:)))
        hereLabel.addGestureRecognizer(hereTap)
        hereLabel.isUserInteractionEnabled = true
        
        let nearTap = UITapGestureRecognizer(target: self, action: #selector(self.nearTap(_:)))
        nearLabel.addGestureRecognizer(nearTap)
        nearLabel.isUserInteractionEnabled = true
        
        let farTap = UITapGestureRecognizer(target: self, action: #selector(self.farTap(_:)))
        farLabel.addGestureRecognizer(farTap)
        farLabel.isUserInteractionEnabled = true
        
        let thereTap = UITapGestureRecognizer(target: self, action: #selector(self.thereTap(_:)))
        thereLabel.addGestureRecognizer(thereTap)
        thereLabel.isUserInteractionEnabled = true
        
        
        nameTextField.text = nameText
        hintTextField.text = hintText
        challengeTextField.text = challengeText
        nameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        if lastProximity != nil {
            switch lastProximity! {
            case .near:
                self.nearLabel.backgroundColor = UIColor.yellow
                break
            case .far:
                self.farLabel.backgroundColor = UIColor.yellow
                break
            case .immediate:
                self.hereLabel.backgroundColor = UIColor.yellow
                break
            case .unknown:
                self.thereLabel.backgroundColor = UIColor.yellow
                break
            }
        }
        hereLabel.layer.borderWidth = 1
        hereLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        nearLabel.layer.borderWidth = 1
        nearLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        farLabel.layer.borderWidth = 1
        farLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
        thereLabel.layer.borderWidth = 1
        thereLabel.layer.borderColor = UIColor(red:222/255, green:225/255, blue:227/255, alpha: 1).cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopListeningToTextFields()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let prox2U = self.manProx != nil ? self.manProx : self.lastProximity
        self.setWayPoint.didSetProximity(name: self.nameTextField.text, proximity: prox2U)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        preferredContentSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination.contents
        if segue.identifier == Constants.WebViewController {
            let svc = destination as? WebViewController
            svc?.firstViewController = self
            svc?.secondViewController = me
            svc?.nameOfNode = nameText
        }
    }
    
    // MARK: Observers
    
    private var namedObserver: NSObjectProtocol!
    private var hintObserver: NSObjectProtocol!
    private var challengeObserver: NSObjectProtocol!
    
    private func listenToTextFields() {
//        weak var presentingController = self.presentingViewController as? HiddingViewController
        let center = NotificationCenter.default
        let queue = OperationQueue.main
        let alert2Monitor = NSNotification.Name.UITextFieldTextDidEndEditing
        namedObserver = center.addObserver(forName: alert2Monitor, object: nameTextField, queue: queue) { (notification) in
            self.setWayPoint.didSetName(originalName:self.nameText, name: self.nameTextField.text)
        }
        hintObserver = center.addObserver(forName: alert2Monitor, object: hintTextField, queue: queue) { (notification) in
            self.setWayPoint.didSetHint(name: self.nameTextField.text,hint: self.hintTextField.text)
        }
        challengeObserver = center.addObserver(forName: alert2Monitor, object: challengeTextField, queue: queue) { (notification) in
            self.setWayPoint.didSetChallenge(name: self.nameTextField.text, challenge: self.challengeTextField.text)
        }
        
    }
    
    private func stopListeningToTextFields() {
        let center = NotificationCenter.default
        if namedObserver != nil {
            center.removeObserver(namedObserver)
        }
        if hintObserver != nil {
            center.removeObserver(hintObserver)
        }
        if challengeObserver != nil {
            center.removeObserver(challengeObserver)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TextDelegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: DropZone
    
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate:  self))
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
//        return  session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        return session.hasItemsConforming(toTypeIdentifiers:
            [kUTTypeImage as String]) || session.canLoadObjects(ofClass: UIImage.self) || session.canLoadObjects(ofClass: NSURL.self) &&
            session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    var imageFetcher: ImageFetcher!
    
    private func updateImage(image2U: UIImage) {
        let image2D = UIImageView(frame: self.dropZone.frame)
        image2D.image = image2U
        self.dropZone.addSubview(image2D)
        image2D.translatesAutoresizingMaskIntoConstraints  = false
        image2D.widthAnchor.constraint(equalToConstant: 64).isActive = true
        image2D.heightAnchor.constraint(equalToConstant: 64).isActive = true
        image2D.centerXAnchor.constraint(equalTo: self.dropZone.centerXAnchor).isActive = true
        image2D.centerYAnchor.constraint(equalTo: self.dropZone.centerYAnchor).isActive = true
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
//        imageFetcher = ImageFetcher() { (url, image) in
//            DispatchQueue.main.async {
////               self.updateImage(image2U: image)
//                self.setWayPoint.didSetImage(name: self.nameTextField.text, image: image)
//            }
//        }
        if session.canLoadObjects(ofClass: UIImage.self) {
            session.loadObjects(ofClass: UIImage.self) { (items) in
                if let images = items as? [UIImage] {
                    self.setWayPoint.didSetImage(name: self.nameTextField.text, image: images.first)
                }
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurl in
            if let url = nsurl.first as? URL {
                self.setWayPoint.didSetURL(name: self.nameTextField.text, URL: url.absoluteString)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self) { images in
//            if let image = images.first as? UIImage {
//                self.imageFetcher.backup = image
//            }
        }
    }
    
    
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditUserWaypoint = "Edit Waypoint"
        static let TableWaypoint = "Table Waypoint"
        static let ScannerViewController = "Scan VC"
        static let WebViewController = "WebViewController"
        
        
        struct Entity {
            static let wayPoints = "wayPoints"
            static let mapLinks = "mapLinks"
        }
        struct Attribute {
            static let UUID = "UUID"
            static let minor = "minor"
            static let major = "major"
            static let proximity = "proximity"
            static let longitude = "longitude"
            static let  latitude = "latitude"
            static let  name = "name"
            static let hint = "hint"
            static let order = "order"
            static let  imageData = "image"
            static let mapName = "mapName"
            static let linkReference = "linkReference"
            static let wayPointsArray = "wayPointsArray"
            static let boxes = "boxes"
            static let challenge = "challenge"
        }
        struct Variable {
            static  let radius = 40
            // the digital difference between degrees-miniutes-seconds 46-20-41 & 46-20-42.
            static let magic = 0.00015
        }
    }
    
}
