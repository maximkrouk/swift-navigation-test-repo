import UIKit
import UIKitNavigation

// This example is a showcase that redundant updates
// cause ui glitches, it might be a bit difficult to navigate
// so it's better to check LogicalExample folder for investigation
class VisualExampleViewController: UIViewController {
	var model: Model!
	let contentView: VStack = .init()

	func updateModel(with model: Model) {
		model.toggleButton.action = { [weak self] in
			enableExperimentalObservation.toggle()
			self?.updateModel(with: .init())
		}

		model.incrementButton.action = { [weak model] in
			model?.counter.value += 1
		}

		model.decrementButton.action = { [weak model] in
			model?.counter.value -= 1
		}

		model.buttonsStack.items.compactMap { $0 as? IconButton.Model }.forEach { model in
			guard model.action == nil else { return }
			model.action = { [weak model] in
				withUIKitAnimation(.easeInOut(duration: 1)) {
					model?.tintColor = .random()
				}
			}
		}

		self.model = model
		contentView.bind(model.contentStack)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .systemBackground

		view.addSubview(contentView)

		contentView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			contentView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48),
			contentView.heightAnchor.constraint(equalToConstant: 120)
		])

		updateModel(with: .init())
	}

	@MainActor
	class Model {
		@UIBinding
		var counterValue: Int = 0

		// middle button enables/disables experimental observation
		private(set) lazy var toggleButton: IconButton.Model = .init(
			icon: enableExperimentalObservation
			? .init(systemName: "star.fill")
			: .init(systemName: "star"),
			tintColor: .label
		)

		private(set) lazy var incrementButton: IconButton.Model = .init(icon: .init(systemName: "plus"))
		private(set) lazy var decrementButton: IconButton.Model = .init(icon: .init(systemName: "minus"))
		private(set) lazy var counter: Counter.Model = .init(
			value: counterValue,
			incrementButton: incrementButton,
			decrementButton: decrementButton
		)

		private(set) lazy var buttonsStack: HStack.Model = .init(items: [
			IconButton.Model(icon: .init(systemName: "star.fill")),
			IconButton.Model(icon: .init(systemName: "star.fill")),
			toggleButton,
			IconButton.Model(icon: .init(systemName: "star.fill")),
			IconButton.Model(icon: .init(systemName: "star.fill")),
		])

		private(set) lazy var contentStack: VStack.Model = .init(items: [
			counter,
			buttonsStack
		])
	}
}

extension UIColor {
	static func random() -> UIColor {
		return UIColor(
			red: .random(in: 0...1),
			green: .random(in: 0...1),
			blue: .random(in: 0...1),
			alpha: 1
		)
	}
}
