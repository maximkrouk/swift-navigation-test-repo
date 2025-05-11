import UIKit

public final class VStack: BaseUIComponent {
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.distribution = .fill
		stackView.alignment = .fill
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
		}
	}

	public override func _init() {
		super._init()

		addSubview(stackView)
		stackView.frame = bounds
		stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
	}
}
