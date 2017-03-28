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
  var selectedCar: Car!
  
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
    
    getDataFromFile()
    let carsRequest: NSFetchRequest<Car> = Car.fetchRequest()
    let mark = segmentedControl.titleForSegment(at: 0)
    
    carsRequest.predicate = NSPredicate(format: "mark == %@", mark!)

    do {
      let results = try context.fetch(carsRequest)
      selectedCar = results[0]
      insertDataFrom(selectedCar: selectedCar)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func getDataFromFile() {
    let carsRequest: NSFetchRequest<Car> = Car.fetchRequest()
    // Пример-пустышка, как делать запрос выборки данных по какому-то конкретному значению
    carsRequest.predicate = NSPredicate(format: "mark != nil")
    
    var records = 0
    
    do {
      // Подсчет количества результатов в ответе из CoreData
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
  
  func insertDataFrom(selectedCar: Car) {
    carImageView.image = UIImage(data: selectedCar.imageData! as Data)
    markLabel.text = selectedCar.mark
    modelLabel.text = selectedCar.model
    myChoiceImageView.isHidden = !(selectedCar.myChoice)
    ratingLabel.text = "Rating: \(selectedCar.rating) / 10.0"
    numberOfTripsLabel.text = "Number of trips: \(selectedCar.timesDriven)"
    
    // Позволяет отображать дату в текстовом формате по имеющимся шаблонам
    let df = DateFormatter()
    df.dateStyle = .short
    df.timeStyle = .none
    lastTimeStartedLabel.text = "Last time started: \(df.string(from: selectedCar.lastStarted! as Date))"
    
    segmentedControl.tintColor = selectedCar.tintColor as! UIColor
  }
  
  func update(rating: String) {
    selectedCar.rating = Double(rating) ?? 0.0
    
    do {
      try context.save()
      insertDataFrom(selectedCar: selectedCar)
    } catch {
      let ac = UIAlertController(title: "Wrong value", message: "Wrong input", preferredStyle: .alert)
      let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
      
      ac.addAction(ok)
      
      present(ac, animated: true, completion: nil)
    }

  }
  
  
  @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
    let mark = sender.titleForSegment(at: sender.selectedSegmentIndex)
    let carRequest: NSFetchRequest<Car> = Car.fetchRequest()
    
    carRequest.predicate = NSPredicate(format: "mark == %@", mark!)
    
    do {
      let result = try context.fetch(carRequest)
      selectedCar = result[0]
      insertDataFrom(selectedCar: selectedCar)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  @IBAction func startEnginePressed(_ sender: UIButton) {
    selectedCar.timesDriven += 1
    // Устанавливает текущее время
    selectedCar.lastStarted = NSDate()
    
    do {
      try context.save()
      insertDataFrom(selectedCar: selectedCar)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  @IBAction func rateItPressed(_ sender: UIButton) {
    let ac = UIAlertController(title: "Rati it", message: "Rate this car please", preferredStyle: .alert)
    let ok = UIAlertAction(title: "Ok", style: .default) { action in
      let textField = ac.textFields?[0]
      self.update(rating: (textField?.text)!)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    ac.addTextField { textField in
      textField.keyboardType = .numberPad
    }
    ac.addAction(ok)
    ac.addAction(cancel)
    
    present(ac, animated: true, completion: nil)
  }
}

