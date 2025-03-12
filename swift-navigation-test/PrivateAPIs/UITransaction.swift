import SwiftNavigation
import ConcurrencyExtras

extension UITransaction {
	public static func current() -> UITransaction {
		let transaction = LockIsolated(UITransaction())
		observe { transaction.setValue($0) }.cancel()
		return transaction.value
	}
}

