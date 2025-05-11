import Observation
import UIKitNavigation

var redundantMark = false

/// Here is a description of a general idea:
///
/// There should be an overload that allows to access observable props
/// separately from `onChange` applicaton of those changes (see PrivateAPIs folder)
/// (currently public `observe` function accepts only one closure)
/// it will also enable some cool convenience extensions and in my case I acheived this API
/// ```swift
/// class CaptureToolbar {
///   public func bind(_ model: Model) {
///     guard setModelIfNeeded(model) else { return }
///     updateBindings([
///       model.observe(\.captureButton, onChange: bind(to: \.captureButton)), // bind subcomponents
///       model.observe(\.leadingItems, onChange: bindOrReplace(\.leadingItems)), // update stacks with subcomponents
///       model.observe(\.trailingItems, onChange: bindOrReplace(\.trailingItems)),
///       model.observe(\.labelExampleText, onChange: assign(to: \.label.text)), // assign simple values
///     ])
///   }
/// }
/// ```
/// But for the library implementing an `observe` function with 2 closure args would be sufficient
@MainActor
func runLogicalExample() {
	redundantMark = false

	let component = Parent()
	let parentModel = Parent.Model()

	print("\nExperimental:", enableExperimentalObservation)

	print(">>> `component.bindModel(parentModel)`:")
	component.bindModel(parentModel)
	print("<<<\n")

	print(">>> `parentModel.value = 1`:")
	parentModel.value = 1
	print("<<<\n")

	print(">>> `parentModel.child.value = 1`:")
	parentModel.child.value = 1
	print("<<<\n")

	redundantMark = !enableExperimentalObservation

	Task {
		try await Task.sleep(for: .seconds(1))
		// capture objects for observation
		_ = (component, parentModel)
	}
}

@MainActor
class Child {
	var _modelCancellables: [ObserveToken] = []

	var uiValue: Int = 0 {
		didSet { print("didSet Child.uiValue to \(uiValue)") }
	}

	@Observable
	class Model {
		var value: Int = 0 {
			didSet { print("didSet Child.Model.value to \(value)") }
		}
	}

	func bindModel(_ model: Model) {
		print("call Child.bindModel \(redundantMark ? "<- redundant" : "")")

		if enableExperimentalObservation {
			// modified behavior
			_modelCancellables = [
				_observe({ _ = model.value }) { [weak self] in
					self?.uiValue = model.value
				}
			]
		} else {
			// default behavior
			_modelCancellables = [
				// this will be called from parent's bind model observe block
				// which will automatically subscribe parent to child updates
				observe { [weak self] in
					self?.uiValue = model.value
				}
			]
		}
	}
}

@MainActor
class Parent {
	var _modelCancellables: [ObserveToken] = []

	var uiValue: Int = 0 {
		didSet { print("didSet Parent.uiValue to \(uiValue)") }
	}

	var child: Child = .init() {
		didSet { print("didSet Parent.child") }
	}

	@Observable
	class Model {
		var value: Int = 0 {
			didSet { print("didSet Parent.Model.value to \(value)") }
		}

		var child: Child.Model = .init() {
			didSet { print("didSet Parent.Model.child") }
		}
	}

	func bindModel(_ model: Model) {
		print("call Parent.bindModel")

		if enableExperimentalObservation {
			// modified behavior
			_modelCancellables = [
				_observe({ _ = model.value }) { [weak self] in
					self?.uiValue = model.value
				},
				_observe({
					// only observe child reference changes
					// values of child will not be observed
					// since they are not accessed
					_ = model.child
				}) { [weak self] in
					// onChange application is separated from observation,
					// any props accessed in this block are not observed
					self?.child.bindModel(model.child)
				}
			]
		} else {
			// default behavior
			_modelCancellables = [
				observe { [weak self] in
					// simple value bindings work fine anyway
					self?.uiValue = model.value
				},
				observe { [weak self] in
					// observation and application are merged in current public API
					// which will subscribe parent to any observables accessed in
					// `child.bindModel`, that causes redundant updates
					self?.child.bindModel(model.child)
				}
			]
		}
	}
}
