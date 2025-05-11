import UIKit
import Combine
import UIKitNavigation

open class BaseUIComponent: UIView {
	var _currentModel: (any UIComponentModel)?
	var _modelCancellables: Set<AnyCancellable> = []

	func _setModelIfNeeded(_ model: (any UIComponentModel)?) -> Bool {
		guard _currentModel !== model else { return false }
		_modelCancellables = []
		_currentModel = model
		return true
	}

	public func updateBindings(_ cancellables: [ObserveToken]) {
		_modelCancellables = Set(cancellables.map { AnyCancellable($0.cancel) })
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
		self._init()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self._init()
	}

	open func _init() {}
}

@MainActor
public protocol UIComponent<Model>: BaseUIComponent {
	associatedtype Model: UIComponentModel
	func bind(_ model: Model)
}

@MainActor
public protocol UIComponentModel<Component>: AnyObject, Observable {
	associatedtype Component: UIComponent<Self>
	func createComponent() -> Component
}

extension UIComponent {
	@discardableResult
	public func setModelIfNeeded(_ model: Model) -> Bool {
		_setModelIfNeeded(model)
	}

	public var currentModel: Model? {
		return _currentModel as? Model
	}
}

extension UIComponentModel {
	public func createComponent() -> Component {
		let component = Component()
		component.bind(self)
		return component
	}
}
