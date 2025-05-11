import UIKit

public final class HStack: BaseUIComponent {
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.spacing = 8
		stackView.distribution = .equalSpacing
		stackView.alignment = .center
		return stackView
	}()

	public var spacing: CGFloat {
		get { stackView.spacing }
		set { stackView.spacing = newValue }
	}

	public var items: [any UIComponent] = [] {
		didSet {
			oldValue.forEach { item in
				stackView.removeArrangedSubview(item)
				item.removeFromSuperview()
			}

			items.forEach { item in
				stackView.addArrangedSubview(item)
			}

			translatesAutoresizingMaskIntoConstraints = false
			NSLayoutConstraint.activate([
				heightAnchor.constraint(equalToConstant: 56)
			])
		}
	}

	public override func _init() {
		super._init()

		addSubview(stackView)
		stackView.frame = bounds
		stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
}
