//
//  CircleColorButton.swift
//  DSFFinderLabelsDemo
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

import Cocoa

class DSFFinderColorCircleButton: NSButton {

	public var darkColor = NSColor.clear
	{
		didSet
		{
			self.needsDisplay = true
		}
	}
	public var lightColor = NSColor.clear
	{
		didSet
		{
			self.needsDisplay = true
		}
	}

	public override func drawFocusRingMask() {
		let circlePath = NSBezierPath(ovalIn: self.bounds.insetBy(dx: 1, dy: 1))
		circlePath.fill()
	}

	static var Shadow: NSShadow = {
		let shad = NSShadow.init()
		shad.shadowBlurRadius = 4
		shad.shadowColor = NSColor.black.withAlphaComponent(0.7)
		shad.shadowOffset = NSSize(width: 1, height: -1)
		return shad
	}()

	public override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		let inset: CGFloat = (self.state == .on) ? 3 : 5


		let rect = NSRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
		let insetRect = rect.insetBy(dx: inset, dy: inset)
		let circlePath = NSBezierPath(ovalIn: insetRect)

		var fillColor: NSColor
		var strokeColor: NSColor
		circlePath.fill()
		if self.isHighlighted {
			strokeColor = self.darkColor
			fillColor = self.lightColor
		} else {
			strokeColor = self.lightColor
			fillColor = self.darkColor
		}

		strokeColor.setStroke()
		circlePath.lineWidth = 1
		circlePath.stroke()
		fillColor.setFill()
		circlePath.fill()

		// Draw selection

		if self.state == .on
		{
			let circlePath = NSBezierPath(ovalIn: rect.insetBy(dx: 8, dy: 8))

			if let gs = NSGraphicsContext.current
			{
				gs.saveGraphicsState()
				DSFFinderColorCircleButton.Shadow.set()
				NSColor.white.setFill()
				circlePath.fill()
				gs.restoreGraphicsState()
			}
		}
	}
}

@objc open class DSFFinderColorGridView: NSGridView
{
	static let FinderColors = DSFFinderLabels.FinderColors.colors

	private var colorButtons = [DSFFinderColorCircleButton]()

	public var selectedColors: [DSFFinderLabels.ColorIndex] {
		return self.colorButtons
			.filter({ $0.state == .on })
			.compactMap { DSFFinderLabels.ColorIndex(rawValue: $0.tag) }
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.colorButtons = self.finderColorButtons()
		self.addRow(with: self.colorButtons)
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		self.colorButtons = self.finderColorButtons()
		self.addRow(with: self.colorButtons)
	}

	public func reset()
	{
		self.setSelected(colors: [])
	}

	public func setSelected(colors: [DSFFinderLabels.ColorIndex]) {
		self.colorButtons.forEach { $0.state = .off }
		colors.forEach { self.colorButtons[$0.rawValue].state = .on }
	}

	@objc func selectedButton(_ sender: DSFFinderColorCircleButton)
	{
		if sender.tag == DSFFinderLabels.ColorIndex.none.rawValue
		{
			self.reset()
		}
	}

	func darkerColor(_ color: NSColor) -> NSColor
	{
		guard let convertedColor = color.usingColorSpace(.genericRGB) else
		{
			return color
		}
		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0
		convertedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		return NSColor(calibratedHue: hue, saturation: saturation, brightness: brightness * 0.75, alpha: alpha)
	}

	func saturatedColor(_ color: NSColor) -> NSColor
	{
		guard let convertedColor = color.usingColorSpace(.genericRGB) else
		{
			return color
		}

		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		var brightness: CGFloat = 0
		var alpha: CGFloat = 0
		convertedColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		return NSColor(calibratedHue: hue, saturation: saturation * 1.2, brightness: brightness, alpha: alpha)
	}

	private func finderColorButtons() -> [DSFFinderColorCircleButton]
	{
		var arr = [DSFFinderColorCircleButton]()
		for color in DSFFinderColorGridView.FinderColors {
			let button = DSFFinderColorCircleButton(frame: NSRect(x: 0, y: 0, width: 24, height: 24))
			button.isBordered = false
			button.title = ""
			button.bezelStyle = .shadowlessSquare
			button.setButtonType(.onOff)
			button.addConstraint(
				NSLayoutConstraint(item: button, attribute: .width,
								   relatedBy: .equal,
								   toItem: nil, attribute: .notAnAttribute,
								   multiplier: 1, constant: 24))
			button.addConstraint(
				NSLayoutConstraint(item: button, attribute: .height,
								   relatedBy: .equal,
								   toItem: nil, attribute: .notAnAttribute,
								   multiplier: 1, constant: 24))

			var itemColor: NSColor?
			switch color.index
			{
			case .none:
				itemColor = NSColor.clear
			case .grey:
				itemColor = NSColor.systemGray
			case .green:
				itemColor = NSColor.systemGreen
			case .purple:
				itemColor = NSColor.systemPurple
			case .blue:
				itemColor = NSColor.systemBlue
			case .yellow:
				itemColor = NSColor.systemYellow
			case .red:
				itemColor = NSColor.systemRed
			case .orange:
				itemColor = NSColor.systemOrange
			}

			button.lightColor = self.saturatedColor(itemColor!)
			button.darkColor = itemColor! //self.darkerColor(itemColor!)
			button.tag = color.index.rawValue
			button.setAccessibilityLabel(color.label)

			button.target = self
			button.action = #selector(DSFFinderColorGridView.selectedButton(_:))

			arr.append(button)
		}

		return arr
	}
}