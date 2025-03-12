@testable import SwiftNavigation
import Foundation

public var enableExperimentalObservation: Bool = false

@MainActor
public func _observe(
	_ tracking: @escaping @MainActor @Sendable () -> Void,
	onChange: @escaping @MainActor @Sendable () -> Void
) -> ObserveToken {
	return _observe(
		{ _ in tracking() },
		onChange: { _ in onChange()}
	)
}

@MainActor
public func _observe(
	_ tracking: @escaping @MainActor @Sendable (UITransaction) -> Void,
	onChange: @escaping @MainActor @Sendable (UITransaction) -> Void
) -> ObserveToken {
	let token = SwiftNavigation.observe { transaction in
		MainActor.assumeIsolated { tracking(transaction) }
	} task: { transaction, work in
		runOnMainThread {
			onChange(transaction)
			withUITransaction(transaction, work)
		}
	}

	let transaction = UITransaction.current()
	runOnMainThread { onChange(transaction) }

	return token
}

private func runOnMainThread(_ action: @escaping @MainActor @Sendable () -> Void) {
	if Thread.isMainThread {
		MainActor.assumeIsolated { action() }
	} else {
		DispatchQueue.main.async { action() }
	}
}
