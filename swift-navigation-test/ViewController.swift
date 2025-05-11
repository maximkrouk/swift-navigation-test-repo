import UIKit
import UIKitNavigation

class ViewController: UIViewController {
	let toggle = UISwitch()

	override func viewDidLoad() {
		super.viewDidLoad()

		let visualExampleButton = UIButton(
			configuration: {
				var config: UIButton.Configuration = .bordered()
				config.title = "Visual example"
				config.subtitle = "More complex one"
				config.titleAlignment = .center
				return config
			}(),
			primaryAction: .init { [weak self] _ in
				self?.navigationController?.pushViewController(
					VisualExampleViewController(),
					animated: true
				)
			}
		)

		let logicalExampleButton = UIButton(
			configuration: {
				var config: UIButton.Configuration = .bordered()
				config.title = "Run logical example"
				config.subtitle = "Simple one"
				config.titleAlignment = .center
				return config
			}(),
			primaryAction: .init { _ in runLogicalExample() }
		)

		toggle.isOn = enableExperimentalObservation
		toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)

		let stack = UIStackView(
			arrangedSubviews: [
				visualExampleButton,
				logicalExampleButton,
				{
					let label = UILabel()
					label.text = "Experimental observation:"
					return label
				}(),
				toggle
			]
		)

		stack.axis = .vertical
		stack.spacing = 12
		stack.distribution = .fill
		stack.alignment = .fill

		view.addSubview(stack)
		stack.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48),
		])
	}

	@objc
	private func toggleValueChanged(_ sender: UISwitch) {
		enableExperimentalObservation = sender.isOn
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		toggle.isOn = enableExperimentalObservation
	}
}
