//
//  EntryDataLogTableViewController.swift
//  BudgetSheet
//
//  Created by Fiona O'Mahoney on 13/08/2018.
//  Copyright © 2018 Fiona O'Mahoney. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

struct CurrentLocation {
    var name: String?
    var latitude: String?
    var longitude: String?
}

class EntryDataLogTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    enum PickerView :Int { // enum with type
        case category = 1
        case subcategory = 2
    }
    
    @IBOutlet weak var enteredBy: UITextField!
    @IBOutlet weak var spender: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var categoriesPickerView: UIPickerView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var subcategory: UITextField!
    @IBOutlet weak var subcategoriesPickerView: UIPickerView!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var method: UITextField!
    @IBOutlet weak var paymentMethodsPickerView: UIPickerView!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var spenderButton: UIButton!
    
    private var currentNoteTextViewHeight:CGFloat = 37.0
    private var hideDatePicker = true
    private var hideEnteredBy = true
    private var hideCategories = true
    private var hideSubcategories = true
    private var hidePaymentMethod = true
    private var hideMap = true
    private var categories: [String:Category] = [:]
    private var paymentMethods: [PaymentMethod] = []
    public var currentLocation: CurrentLocation = CurrentLocation()
    private var locationManager: CLLocationManager?
    private var locationSearchTimer: Timer?
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationSearchTimer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        // Remove extra lines
        tableView.tableFooterView = UIView()
        
        tableView.keyboardDismissMode = .onDrag
        
        // Setup Data
        if let user = UserDefaults.standard.dictionary(forKey: "user"),
           let userName = user["fullName"] as? String {
            self.enteredBy.text = userName
            self.spender.text = userName
        }
        
        toggleLocationServices()
        
        amount.becomeFirstResponder()
        
        copyDatePickerDate()
        
        setupCategories()
        
        setupPaymentMethods()
        
        // Keyboard Adjustments
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleLocationServices() {
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
            locationManager!.requestWhenInUseAuthorization()
            locationManager!.startUpdatingLocation()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 14
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1) {
            if (hideDatePicker) {
                return 0
            }
            else {
                return 150
            }
        }
        else if (indexPath.row == 4) {
            if (hideCategories) {
                return 0
            }
            else {
                return 150
            }
        }
        else if (indexPath.row == 6) {
            if (hideSubcategories) {
                return 0
            }
            else {
                return 150
            }
        }
        else if (indexPath.row == 8) {
            if (hidePaymentMethod) {
                return 0
            }
            else {
                return 150
            }
        }
        else if (indexPath.row == 10) {
            if (hideMap) {
                return 0
            }
            else {
                return 200
            }
        }
        else if (indexPath.row == 11) {
            return 23 + currentNoteTextViewHeight
        }
        else if (indexPath.row == 13 && hideEnteredBy) {
            return 0
        }
        return 60
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        copyDatePickerDate()
    }
    
    func setupCategories() {
        self.categoriesPickerView.delegate = self
        self.categoriesPickerView.dataSource = self

        if let userDefaultCategories = UserDefaults.standard.codable([String: Category].self, forKey: "categories") {
            self.categories = userDefaultCategories
            
            // Default to Category with Id: 1
            if let firstCategory = self.categories["1"] as Category? {
                for (index, categoryInArray) in Array(self.categories.values).enumerated() {
                    if categoryInArray.id == "1" {
                        categoriesPickerView.selectRow(index, inComponent: 0, animated: false)
                        subcategoriesPickerView.selectRow(0, inComponent: 0, animated: false)
                        subcategory.text = firstCategory.subcategories[0].name
                    }
                }
                self.category.text = firstCategory.name
            }
        }
    }
    
    func setupPaymentMethods() {
        if let userDefaultPaymentMethods = UserDefaults.standard.codable([PaymentMethod].self, forKey: "payment_methods") {
            self.paymentMethods = userDefaultPaymentMethods
            self.method.text = self.paymentMethods[0].name
        }
    }
    
    /*func setupSubcategories() {
        self.subcategoriesPickerView.delegate = self
        self.subcategoriesPickerView.dataSource = self
        if let subcategories = UserDefaults.standard.array(forKey: "subcategories") {
            self.subcategories_data = subcategories
            // Select first by default
            let rowData = subcategories_data[0] as! NSArray
            self.subcategory.text = rowData[1] as? String
        }
    } */
    
    func copyDatePickerDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d-MMM-yyyy"
        let strDate = dateFormatter.string(from: self.datePicker.date)
        self.date.text = strDate
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            tableView.contentInset = UIEdgeInsets.zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    @IBAction func dateFieldClicked(_ sender: Any) {
        hideDatePicker = !hideDatePicker
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func spenderClicked(_ sender: Any) {
        if (hideEnteredBy) {
            hideEnteredBy = false
            spenderButton.isUserInteractionEnabled = false
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    @IBAction func subcategoryClicked(_ sender: Any) {
        hideSubcategories = !hideSubcategories
        hideCategories = true
        hidePaymentMethod = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func categoryClicked(_ sender: Any) {
        hideCategories = !hideCategories
        hideSubcategories = true
        hidePaymentMethod = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @IBAction func paymentMethodClicked(_ sender: Any) {
        hidePaymentMethod = !hidePaymentMethod
        hideCategories = true
        hideSubcategories = true
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func toggleMap() {
        if hideMap {
            hideMap = false
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
        
    @objc func search() {
        // Search nearby
        if !(location.text?.isEmpty ?? true) {
            toggleMap()
            
            // Remove all annotations
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = self.location.text
            let region = CLLocationCoordinate2D(latitude: (locationManager!.location?.coordinate.latitude)!, longitude: (locationManager!.location?.coordinate.longitude)!)
            let span = mapView.region.span
            request.region = MKCoordinateRegion(center: region, span: span)
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response else {
                    print("There was an error searching for: \(String(describing: request.naturalLanguageQuery)) error: \(String(describing: error))")
                    return
                }
                print("There are \(response.mapItems.count)")
                for item in response.mapItems {
                    let pin = MKPointAnnotation()
                    pin.title = item.placemark.name!
                    if let addressLines = item.placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
                        pin.subtitle =  addressLines.joined(separator: ", ")
                    }
                    pin.coordinate = CLLocationCoordinate2D(latitude: (item.placemark.location?.coordinate.latitude)!, longitude: (item.placemark.location?.coordinate.longitude)!)
                    self.mapView.addAnnotation(pin)
                }
                
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let annotationTitle = view.annotation?.title {
            self.currentLocation = CurrentLocation(name: annotationTitle, latitude: "", longitude: "")
            self.location.text = annotationTitle
        }
        
        if let annotationLatitude = view.annotation?.coordinate.latitude,
           let annotationLongitude = view.annotation?.coordinate.longitude {
            self.currentLocation.latitude = String(annotationLatitude)
            self.currentLocation.longitude = String(annotationLongitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last as CLLocation? {
            print("Latitude: \(currentLocation.coordinate.latitude)")
            print("Longitude: \(currentLocation.coordinate.longitude)")
            
            // Zoom to user location
            let userRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 1000, 1000)
            mapView.setRegion(userRegion, animated: true)
            mapView.showsUserLocation = true
            
            search()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            print(error)
            return
        }
        // Notify the user of any errors.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == PickerView.category.rawValue) {
             return categories.count
        }
        else if (pickerView.tag == PickerView.subcategory.rawValue) {
            // Get the selected category and then the subcategory count
            let selectedCategoryRow = categoriesPickerView.selectedRow(inComponent: 0)
            let selectedCategory = Array(categories.values)[selectedCategoryRow]
            let subcategories = selectedCategory.subcategories
            return subcategories.count
        }
        else {
            return paymentMethods.count
        }
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == PickerView.category.rawValue) {
            let selectedCategory = Array(categories.values)[row] 
            return selectedCategory.name
        }
        else if (pickerView.tag == PickerView.subcategory.rawValue) {
            // Get the selected category and then the subcategory count
            let selectedCategoryRow = categoriesPickerView.selectedRow(inComponent: 0)
            let selectedCategory = Array(categories.values)[selectedCategoryRow]
            let subcategories = selectedCategory.subcategories
            return subcategories[row].name
        }
        else {
            return paymentMethods[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == PickerView.category.rawValue) {
            let selectedCategory = Array(categories.values)[row]
            category.text = selectedCategory.name
            subcategoriesPickerView.reloadComponent(0)
            subcategoriesPickerView.selectRow(0, inComponent: 0, animated: false)
            subcategory.text = selectedCategory.subcategories[0].name
        }
        else if (pickerView.tag == PickerView.subcategory.rawValue) {
            // Get the selected category and then the subcategory count
            let selectedCategoryRow = categoriesPickerView.selectedRow(inComponent: 0)
            let selectedCategory = Array(categories.values)[selectedCategoryRow]
            let subcategories = selectedCategory.subcategories
            self.subcategory.text = subcategories[row].name
        }
        else {
            self.method.text = paymentMethods[row].name
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = note.frame.size.width
        let newSize = note.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        note.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if (newSize.height > currentNoteTextViewHeight) {
            currentNoteTextViewHeight = newSize.height
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    
    @IBAction func locationTextChanged(_ sender: Any) {
        if let textfield = sender as? UITextField {
            if (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
                
                locationSearchTimer?.invalidate()
                
                self.currentLocation.latitude = ""
                self.currentLocation.longitude = ""
                
                if let newLocation = textfield.text {
                    self.currentLocation.name = newLocation
                    locationSearchTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(search), userInfo: nil, repeats: false)
                }
            }
        }
    }
}



extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardView))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboardView() {
        view.endEditing(true)
    }
}
