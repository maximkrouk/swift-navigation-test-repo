import UIKit
import UIKitNavigation

public final class Counter: BaseUIComponent {
	private let control: Control = .init()
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 8
		stackView.distribution = .equalSpacing
		stackView.alignment = .fill
		return stackView
	}()

	public let incrementButton: IconButton = .init()
	public let decrementButton: IconButton = .init()

	public override func _init() {
		super._init()

		addSubview(stackView)
		stackView.frame = bounds
		stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		stackView.addArrangedSubview(decrementButton)
		stackView.addArrangedSubview(control)
		stackView.addArrangedSubview(incrementButton)

		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalToConstant: 56)
		])
	}

	func bind(_ binding: UIBinding<Int>) -> ObserveToken {
		control.bind(binding, to: \.value, for: .valueChanged)
	}

	private class Control: UIControl {
		@objc dynamic
		public var value: Int = 0 {
			didSet {
				print("set", "counter", value)
				label.text = value.description
				sendActions(for: .valueChanged)
			}
		}

		public let label: UILabel = {
			let label = UILabel()
			label.textAlignment = .center
			return label
		}()

		override init(frame: CGRect) {
			super.init(frame: frame)
			self._init()
		}

		required init?(coder: NSCoder) {
			super.init(coder: coder)
			self._init()
		}

		func _init() {
			label.text = value.description
			addSubview(label)
			label.frame = bounds
			label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		}
	}
}
