//
//  ViewController.swift
//  BarChartTest
//
//  Created by Raheel Sayeed on 03/06/18.
//  Copyright © 2018 Medical Gear. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var barChart: BarChart!
	
	@IBAction func addEntries(_ sender: Any) {
		
		var e = barChart.dataEntries
		if e != nil { e = e! + generateDataEntries() }
		else { e = generateDataEntries() }
		barChart.dataEntries = e
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let dataEntries = generateDataEntries()
		barChart.title = "TEMP"
		barChart.dataEntries = dataEntries

		
	}

	func generateDataEntries() -> [BarEntry] {
		//let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
		let colors = [UIColor.white]
		var result: [BarEntry] = []
		for i in 0..<20 {
			let randomNo = arc4random()
			let random = (randomNo % 90)
			let value = random + 10
			
			let height: Float = Float(value) / 100.0
			let formatter = DateFormatter()
			formatter.dateFormat = "d MMM"
			var date = Date()
			date.addTimeInterval(TimeInterval(24*60*60*i))
			result.append(BarEntry(color: colors[i % colors.count], height: height, textValue: "\(value)", title: formatter.string(from: date)))
		}
		return result
	}

}

