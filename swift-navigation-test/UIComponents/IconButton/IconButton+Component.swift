import UIKit
import UIKitNavigation
import Observation

extension IconButton: UIComponent {
	@MainActor
	@Observable
	public final class Model: UIComponentModel {
		public typealias Component = IconButton

		public var icon: UIImage?
		public var tintColor: UIColor
		public var action: (() -> Void)?

		public init(
			icon: UIImage? = nil,
			tintColor: UIColor = .systemBlue,
			action: (() -> Void)? = nil
		) {
			self.icon = icon
			self.tintColor = tintColor
			self.action = action
		}
	}

	public func bind(_ model: Model) {
		guard setModelIfNeeded(model) else { return }

		updateBindings(
			enableExperimentalObservation
			? [
				_observe({ _ = model.icon }) { [weak self] in
					print("set", "icon_button", "icon")
					self?.icon = model.icon
				},
				_observe({ _ = model.tintColor }) { [weak self] in
					print("set", "icon_button", "tint")
					self?.iconTint = model.tintColor
				},
				_observe({ _ = model.action }) { [weak self] in
					print("set", "icon_button", "action")
					self?.action = model.action
				},
			]
			: [
				observe { [weak self] in
					print("set", "icon_button", "icon")
					self?.icon = model.icon
				},
				observe { [weak self] in
					print("set", "icon_button", "tint")
					self?.iconTint = model.tintColor
				},
				observe { [weak self] in
					print("set", "icon_button", "action")
					self?.action = model.action
				},
			]
		)
	}
}
