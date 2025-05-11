import UIKit

public final class IconButton: BaseUIComponent {
	private let control: Control = .init()
	private let imageView: UIImageView = .init()

	public var action: (() -> Void)? {
		get { control.onAction }
		set { control.onAction = newValue }
	}

	public var icon: UIImage? {
		get { imageView.image }
		set { imageView.image = newValue }
	}

	public var iconTint: UIColor! {
		get { imageView.tintColor }
		set { imageView.tintColor = newValue }
	}

	public override func _init() {
		super._init()

		addSubview(imageView)
		imageView.frame = bounds
		imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		addSubview(control)
		control.frame = bounds
		control.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			widthAnchor.constraint(equalToConstant: 56),
			heightAnchor.constraint(equalToConstant: 56)
		])
	}

	private class Control: UIControl {
		var onPressBegin: (() -> Void)?
		var onPressEnd: (() -> Void)?
		var onAction: (() -> Void)?

		var triggerEvent: UIControl.Event = .touchUpInside {
			didSet {
				removeTarget(self, action: #selector(runAction), for: oldValue)
				addTarget(self, action: #selector(runAction), for: [triggerEvent])
			}
		}

		convenience init(
			action: (() -> Void)? = nil,
			onPressBegin: (() -> Void)? = nil,
			onPressEnd: (() -> Void)? = nil
		) {
			self.init(frame: .zero)
			self.onAction = action
			self.onPressBegin = onPressBegin
			self.onPressEnd = onPressEnd
		}

		override init(frame: CGRect) {
			super.init(frame: frame)
			configure()
		}

		required init?(coder: NSCoder) {
			super.init(coder: coder)
			configure()
		}

		private func configure() {
			addTarget(self, action: #selector(pressBegin), for: [.touchDown, .touchDragEnter])
			addTarget(self, action: #selector(pressEnd), for: [.touchUpInside, .touchDragExit, .touchCancel])
			addTarget(self, action: #selector(runAction), for: [triggerEvent])
		}

		@objc private func pressBegin() {
			onPressBegin?()
		}

		@objc private func pressEnd() {
			onPressEnd?()
		}

		@objc private func runAction() {
			onAction?()
		}
	}
}
