//
//  BarChart.swift
//  BarChartTest
//
//  Created by Raheel Sayeed on 03/06/18.
//  Copyright © 2018 Medical Gear. All rights reserved.
//

import UIKit

class BarChart: UIView {

	private struct Constants {
		static let cornerRadiusSize = CGSize(width: 10.0, height: 10.0)
		static let margin: 			CGFloat = 30.0
		static let topBorder: 		CGFloat = 50.0
		static let bottomBorder: 	CGFloat = 10
		static let colorAlpha: 		CGFloat = 0.3
		static let circleDiameter: 	CGFloat = 7.0
		static let barWidth: CGFloat = 20.0
		static let space: CGFloat = 5
		static let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
								 NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 7.0)]
	}
	@IBInspectable var startColor: 	UIColor = UIColor(red: 1, green:  0.493272, blue: 0.473998, alpha: 1)
	@IBInspectable var endColor: 	UIColor = UIColor(red: 1, green:  0.57810, blue: 0, alpha: 1)
	@IBInspectable var strokeColor: UIColor = .white

	
	private let scrollView = UIScrollView()
	
	private let mainLayer  = CALayer()
	
	var title : String? = nil
	
	var lineThresholds : [Double]? = nil
	
	var dataEntries: [BarEntry]? = nil {
		didSet {
			mainLayer.sublayers?.forEach({$0.removeFromSuperlayer()})
			
			if let dataEntries = dataEntries {
				scrollView.contentSize = CGSize(width: (Constants.barWidth + Constants.space)*CGFloat(dataEntries.count), height: self.frame.size.height)
				mainLayer.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
								
				for i in 0..<dataEntries.count {
					addEntry(index: i, entry: dataEntries[i])
				}
				
				scrollView.scrollToBottom()
				
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		configureView()
	}
	
	convenience init() {
		self.init(frame: CGRect.zero)
		configureView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		configureView()
	}
	
	private func configureView() {
		scrollView.layer.addSublayer(mainLayer)
		self.addSubview(scrollView)
	}
	
	override func layoutSubviews() {
		scrollView.frame = CGRect(x: 2, y: 0, width: frame.size.width-4, height: frame.size.height)
	}
	
	override public func draw(_ rect: CGRect) {
		
		let width 	= rect.width
		let height	= rect.height
		let path = UIBezierPath(roundedRect: rect,
								byRoundingCorners: .allCorners,
								cornerRadii: Constants.cornerRadiusSize)
		path.addClip()
		let context = UIGraphicsGetCurrentContext()!
		let colors = [startColor.cgColor, endColor.cgColor]
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let colorLocations: [CGFloat] = [0.0, 1.0]
		let gradient = CGGradient(colorsSpace: colorSpace,
								  colors: colors as CFArray,
								  locations: colorLocations)!
		var startPoint = CGPoint.zero
		var endPoint = CGPoint(x: 0, y: self.bounds.height)
		context.drawLinearGradient(gradient,
								   start: startPoint,
								   end: endPoint,
								   options: CGGradientDrawingOptions(rawValue: 0))
		
		if let title = title  {
			(title as NSString).draw(at: CGPoint.init(x: Constants.margin, y: 10) ,
									 withAttributes: [NSAttributedStringKey.foregroundColor: UIColor.white,
													  NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)])
		}
		
		drawHorizontalLines()
		
		super.draw(rect)
	}
	
	private func translateHeightValueToYPosition(value: Float) -> CGFloat {
		let height: CGFloat = CGFloat(value) * (mainLayer.frame.height - (Constants.bottomBorder) - (Constants.topBorder))
		return mainLayer.frame.height - (Constants.bottomBorder) - height
	}
	
	private func drawBar(xPos: CGFloat, yPos: CGFloat, color: UIColor) {
		let barLayer = CALayer()
		barLayer.frame = CGRect(x: xPos, y: yPos, width: (Constants.barWidth), height: mainLayer.frame.height - (Constants.bottomBorder) - yPos)
		barLayer.backgroundColor = color.cgColor
		mainLayer.addSublayer(barLayer)
	}
	private func addEntry(index: Int, entry: BarEntry) {
		/// Starting x postion of the bar
		let space = Constants.space
		let barWidth = Constants.barWidth
		let xPos: CGFloat = Constants.space + CGFloat(index) * (barWidth + space)
		
		/// Starting y postion of the bar
		let yPos: CGFloat = translateHeightValueToYPosition(value: entry.height)
		
		drawBar(xPos: xPos, yPos: yPos, color: entry.color)
		
//		/// Draw text above the bar
		drawTextValue(xPos: xPos - space/2, yPos: yPos - 20, textValue: entry.textValue, color: entry.color)

//		/// Draw text below the bar
//		drawTitle(xPos: xPos - space/2, yPos: mainLayer.frame.height - bottomSpace + 10, title: entry.title, color: entry.color)
	}
	
	private func drawTextValue(xPos: CGFloat, yPos: CGFloat, textValue: String, color: UIColor) {
		let textLayer = CATextLayer()
		let barWidth = Constants.barWidth
		let space    = Constants.space
		textLayer.frame = CGRect(x: xPos, y: yPos, width: barWidth+space, height: 22)
		textLayer.foregroundColor = UIColor.lightText.cgColor
		textLayer.backgroundColor = UIColor.clear.cgColor
		textLayer.alignmentMode = kCAAlignmentCenter
		textLayer.contentsScale = UIScreen.main.scale
		textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 0).fontName as CFString, 0, nil)
		textLayer.fontSize = 14
		textLayer.string = textValue
		mainLayer.addSublayer(textLayer)
	}
	
	private func drawHorizontalLines() {
		self.layer.sublayers?.forEach({
			if $0 is CAShapeLayer {
				$0.removeFromSuperlayer()
			}
		})
		let horizontalLineInfos = [["value": Float(0.0), "dashed": false], ["value": Float(0.5), "dashed": true], ["value": Float(1.0), "dashed": false]]
		for lineInfo in horizontalLineInfos {
			let xPos = CGFloat(0.0)
			let yPos = translateHeightValueToYPosition(value: (lineInfo["value"] as! Float))
			let path = UIBezierPath()
			path.move(to: CGPoint(x: xPos, y: yPos))
			path.addLine(to: CGPoint(x: scrollView.frame.size.width, y: yPos))
			let lineLayer = CAShapeLayer()
			lineLayer.path = path.cgPath
			lineLayer.lineWidth = 0.5
			if lineInfo["dashed"] as! Bool {
				lineLayer.lineDashPattern = [4, 4]
			}
			lineLayer.strokeColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
			self.layer.insertSublayer(lineLayer, at: 0)
		}
	}
}

struct BarEntry {
	let color: UIColor
	
	/// Ranged from 0.0 to 1.0
	let height: Float
	
	/// To be shown on top of the bar
	let textValue: String
	
	/// To be shown at the bottom of the bar
	let title: String
}


extension UIScrollView {
	
	func scrollToBottom() {
		let bottomOffset = CGPoint(x: contentSize.width - bounds.size.width, y: contentSize.height - bounds.size.height)
		setContentOffset(bottomOffset, animated: true)
	}
}
