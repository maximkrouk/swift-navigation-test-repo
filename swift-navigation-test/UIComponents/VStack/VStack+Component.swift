import UIKit
import UIKitNavigation
import Observation

extension VStack: UIComponent {
	@MainActor
	@Observable
	public final class Model: UIComponentModel {
		public typealias Component = VStack

		public var spacing: CGFloat
		public var items: [(any UIComponentModel)]

		public init(
			spacing: CGFloat = 8,
			items: [any UIComponentModel] = []
		) {
			self.spacing = spacing
			self.items = items
		}
	}

	public func bind(_ model: Model) {
		guard setModelIfNeeded(model) else { return }
		updateBindings(
			enableExperimentalObservation
			? [
				_observe({ _ = model.spacing }) { [weak self] in
					print("set", "vstack", "spacing")
					self?.spacing = model.spacing
				},
				_observe({ _ = model.spacing }) { [weak self] in
					print("set", "vstack", "items")
					self?.items = model.items.map { $0.createComponent() }
				}
			]
			: [
				observe { [weak self] in
					print("set", "vstack", "spacing")
					self?.spacing = model.spacing
				},
				observe { [weak self] in
					print("set", "vstack", "items")
					self?.items = model.items.map { $0.createComponent() }
				}
			]
		)
	}
}
