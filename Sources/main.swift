import SwiftNavigation
import Perception
import ConcurrencyExtras
import Foundation

// MARK: - Declarations

// delay to allow everything to print correctly
let interval: Duration = .seconds(1)

@Perceptible
class ObservableParent: @unchecked Sendable {
	var value: Int = 0

	var child: ObservableChild = .init()

	@PerceptionIgnored
	var tokens: [ObserveToken] = []
}

@Perceptible
class ObservableChild: @unchecked Sendable {
	var value: Int = 0

	@PerceptionIgnored
	var tokens: [ObserveToken] = []

	func observe() {
		print(Self.self, #function)

		tokens = []

		// it's ok to use basic observe here since
		// there are no nested calls
		SwiftNavigation.observe {
			print("child.value changed to", self.value)
		}.store(in: &tokens)
	}
}

// MARK: - Current Behavior

extension ObservableParent {
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
}

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

// MARK: - PR Behavior

extension ObservableParent {
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

// MARK: - No-lib-change test

extension ObservableParent {
	func observeClone() {
		print(Self.self, #function)

		swift_navigation_test.observeClone { _ = self.value } onChange: {
			print("parent.value changed to", self.value)
		}.store(in: &tokens)

		swift_navigation_test.observeClone { _ = self.child } onChange: {
			print("parent.child changed to", ObjectIdentifier(self.child))
			self.child.observe()
		}.store(in: &tokens)
	}
}

// Local implementation utilizing @testable import
// will not work in prod, so it makes it kinda
// impossible to implement it outside of library
//
// Or even if it's possible the implementation will be
// infinitely worse than the one in the PR
//
// Also PR just brings back ability that `withPerceptionTracking`
// has and swift-navigation just removes it for the sake of ergonomics
// but sacrificing actual flexibility and providing bug-prone approach
func runCloneBehaviorExample() async {
	print(">>> Clone Behavior Example:\n")

	let parent = ObservableParent()
	let child = parent.child

	parent.observeClone()
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

// MARK: - Execution

Task {
	await runCurrentBehaviorExample()
	await runPRBehaviorExample()
	await runCloneBehaviorExample()
}

RunLoop.main.run()
