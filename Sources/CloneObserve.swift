@testable import SwiftNavigation
import Foundation

func observeClone(
	isolation: (any Actor)? = #isolation,
	@_inheritActorContext _ tracking: @escaping @Sendable () -> Void,
	@_inheritActorContext onChange apply: @escaping @Sendable () -> Void
) -> ObserveToken {
	observeClone(
		isolation: isolation,
		{ _ in tracking() },
		onChange: { _ in apply() }
	)
}

func observeClone(
	isolation: (any Actor)? = #isolation,
	@_inheritActorContext _ tracking: @escaping @Sendable (UITransaction) -> Void,
	@_inheritActorContext onChange apply: @escaping @Sendable (_ transaction: UITransaction) -> Void
) -> ObserveToken {
	let actor = ActorProxy(base: isolation)
	return clownObserve(
		tracking,
		onChange: apply,
		task: { transaction, operation in
			Task {
				await actor.perform {
					operation()
				}
			}
		}
	)
}

/// Got a bit creative here 🤡
private func clownObserve(
	_ tracking: @escaping @Sendable (UITransaction) -> Void,
	onChange: @escaping @MainActor @Sendable (UITransaction) -> Void,
	task: @escaping @Sendable (
	 _ transaction: UITransaction,
	 _ operation: @escaping @Sendable () -> Void
 ) -> Void = {
	 Task(operation: $1)
 }
) -> ObserveToken {
	let token = SwiftNavigation.observe { transaction in
		// Do not call onChange here, only call tracking

		MainActor.assumeIsolated { tracking(transaction) }
	} task: { transaction, work in
		task(transaction) {
			if Thread.isMainThread {
				MainActor.assumeIsolated {
					onChange(transaction) // onChange updates are handled here
					withUITransaction(transaction, work)
				}
			} else {
				DispatchQueue.main.async {
					onChange(transaction) // onChange updates are handled here
					withUITransaction(transaction, work)
				}
			}
		}
	}

	// since onChange wasn't called, we need to send an initial update here
	let transaction = UITransaction.current
	if Thread.isMainThread {
		MainActor.assumeIsolated {
			onChange(transaction)
		}
	} else {
		DispatchQueue.main.async {
			onChange(transaction)
		}
	}

	return token
}

private actor ActorProxy {
	let base: (any Actor)?
	init(base: (any Actor)?) {
		self.base = base
	}
	nonisolated var unownedExecutor: UnownedSerialExecutor {
		(base ?? MainActor.shared).unownedExecutor
	}
	func perform(_ operation: @Sendable () -> Void) {
		operation()
	}
}
