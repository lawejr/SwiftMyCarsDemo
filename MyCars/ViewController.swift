//
//  ViewController.swift
//  MyCars
//
//  Created by Ivan Akulov on 07/11/16.
//  Copyright © 2016 Ivan Akulov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
  
  lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var markLabel: UILabel!
  @IBOutlet weak var modelLabel: UILabel!
  @IBOutlet weak var carImageView: UIImageView!
  @IBOutlet weak var lastTimeStartedLabel: UILabel!
  @IBOutlet weak var numberOfTripsLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var myChoiceImageView: UIImageView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func getDataFromFile() {
    let carsRequest: NSFetchRequest<Car> = Car.fetchRequest()
    // Пример-пустышка, как делать запрос выборки данных по какому-то конкретному значению
    carsRequest.predicate = NSPredicate(format: "mark !=nil")
    
    var records = 0
    
    do {
      let count = try context.count(for: carsRequest)
      records = count
    } catch {
      print(error.localizedDescription)
    }
    
    guard records == 0 else { return }
    // Путь до файла откуда брать данные
    let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist")
    let dataArray = NSArray(contentsOfFile: pathToFile!)!
    
    for dictionary in dataArray {
      let carEntity = NSEntityDescription.entity(forEntityName: "Car", in: context)
      assert(carEntity != nil, "carEntity == nil")
      let carObject = NSManagedObject(entity: carEntity!, insertInto: context) as! Car
      // Кастим словарь полученный в цикле до реального словаря
      let carDictionary = dictionary as! NSDictionary
      
      carObject.mark = carDictionary["mark"] as? String
      carObject.model = carDictionary["model"] as? String
      carObject.rating = (carDictionary["rating"] as? Double)!
      carObject.lastStarted = carDictionary["lastStarted"] as? NSDate
      carObject.timesDriven = carDictionary["timesDriven"] as! Int16
      carObject.myChoice = (carDictionary["myChoice"] as? Bool)!
      
      let imageName = carDictionary["imageName"] as? String
      let image = UIImage(named: imageName!)
      let imageData = UIImagePNGRepresentation(image!)
      
      carObject.imageData = imageData as NSData?
      
      let colorDictionary = carDictionary["tintColor"] as! NSDictionary
      carObject.tintColor = getColor(colorDictionary: colorDictionary)
      
      do {
        try context.save()
      } catch {
        print("Error \(error.localizedDescription)")
      }
    }
  }
  
  func getColor(colorDictionary: NSDictionary) -> UIColor {
    let red = colorDictionary["red"] as! NSNumber
    let green = colorDictionary["green"] as! NSNumber
    let blue = colorDictionary["blue"] as! NSNumber
    
    return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1.0)
  }
  
  
  @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
    
  }
  
  @IBAction func startEnginePressed(_ sender: UIButton) {
    
  }
  
  @IBAction func rateItPressed(_ sender: UIButton) {
    
  }
}

