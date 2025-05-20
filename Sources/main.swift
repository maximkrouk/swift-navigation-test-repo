import SwiftNavigation
import Perception
import ConcurrencyExtras
import Foundation

var tokens: LockIsolated<[String: ObserveToken]> = .init( [:])

@Perceptible
class ObservableParent: @unchecked Sendable {
	var value: Int = 0

	var child: ObservableChild = .init()

	@PerceptionIgnored
	var tokens: [ObserveToken] = []

	func observeOld() {
		print(Self.self, #function)

		tokens = []

		SwiftNavigation.observe {
			print("parent.value changed to", self.value)
		}.store(in: &tokens)

		SwiftNavigation.observe {
			print("parent.child changed to", ObjectIdentifier(self.child))
			self.child.observe()
		}.store(in: &tokens)
	}

	func observeNew() {
		print(Self.self, #function)

		SwiftNavigation.observe { _ = self.value } onChange: {
			print("parent.value changed to", self.value)
		}.store(in: &tokens)

		SwiftNavigation.observe { _ = self.child } onChange: {
			print("parent.child changed to", ObjectIdentifier(self.child))
			self.child.observe()
		}.store(in: &tokens)
	}
}

@Perceptible
class ObservableChild: @unchecked Sendable {
	var value: Int = 0

	@PerceptionIgnored
	var tokens: [ObserveToken] = []

	func observe() {
		print(Self.self, #function)

		tokens = []

		SwiftNavigation.observe {
			print("child.value changed to", self.value)
		}.store(in: &tokens)
	}
}

// delay to allow everything to print correctly
let interval: Duration = .seconds(1)

func runCurrentBehaviorExample() async {
	print(">>> Current Behavior Example:\n")
	let parent = ObservableParent()
	let child = parent.child

	parent.observeOld()
	try? await Task.sleep(for: interval)
	print("    ↑ Expected updates on observe\n")

	parent.value = 1
	try? await Task.sleep(for: interval)
	print("    ↑ Expected update on parent.value change\n")

	child.value = 1
	try? await Task.sleep(for: interval)
	print("    ↑ Expected child.value update on child.value change")
	print("    ↑ Redundant parent.child update on child.value change ⚠︎ \n")
	print("\n<<<\n")
}

func runPRBehaviorExample() async {
	print(">>> PR Behavior Example:\n")

	let parent = ObservableParent()
	let child = parent.child

	parent.observeNew()
	try? await Task.sleep(for: interval)
	print("    ↑ Expected updates on observe\n")

	parent.value = 1
	try? await Task.sleep(for: interval)
	print("    ↑ Expected update on parent.value change\n")

	child.value = 1
	try? await Task.sleep(for: interval)
	print("    ↑ Expected update on child.value change\n")
	print("\n<<<\n")
}

Task {
	await runCurrentBehaviorExample()
	await runPRBehaviorExample()
}

RunLoop.main.run()
