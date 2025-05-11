import UIKit
import UIKitNavigation
import Observation

extension Counter: UIComponent {
	@MainActor
	@Observable
	public final class Model: UIComponentModel {
		public typealias Component = Counter

		@ObservationIgnored
		@UIBinding
		public var value: Int
		public var incrementButton: IconButton.Model
		public var decrementButton: IconButton.Model

		public init(
			value: Int = 0,
			incrementButton: IconButton.Model,
			decrementButton: IconButton.Model
		) {
			self.value = value
			self.incrementButton = incrementButton
			self.decrementButton = decrementButton
		}

		public init(
			value: UIBinding<Int>,
			incrementButton: IconButton.Model,
			decrementButton: IconButton.Model
		) {
			self._value = value
			self.incrementButton = incrementButton
			self.decrementButton = decrementButton
		}
	}

	public func bind(_ model: Model) {
		guard setModelIfNeeded(model) else { return }
		updateBindings(
			enableExperimentalObservation
			? [
				bind(model.$value),
				_observe({ _ = model.incrementButton }) { [weak self] in
					print("set", "counter", "incrementButton")
					self?.incrementButton.bind(model.incrementButton)
				},
				_observe({ _ = model.decrementButton }) { [weak self] in
					print("set", "counter", "decrementButton")
					self?.decrementButton.bind(model.decrementButton)
				}
			]
			: [
				bind(model.$value),
				observe { [weak self] in
					print("set", "counter", "incrementButton")
					self?.incrementButton.bind(model.incrementButton)
				},
				observe { [weak self] in
					print("set", "counter", "decrementButton")
					self?.decrementButton.bind(model.decrementButton)
				}
			]
		)
	}
}
