//
//  FavoriteMetricsStore.swift
//  Calmscient
//

import Foundation

struct FavoriteMetricsStore {

    static let shared = FavoriteMetricsStore()

    /// Maximum number of metrics a user can pin.
    let maxCount = 3

    private let key = "health.favorites.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Ordered favorite ids (pin order preserved).
    func favorites() -> [String] {
        defaults.stringArray(forKey: key) ?? []
    }

    func isFavorite(_ id: String) -> Bool { favorites().contains(id) }

    var count: Int { favorites().count }
    var isFull: Bool { count >= maxCount }

    /// Adds `id` if there is room. Returns false if already at the max.
    @discardableResult
    func add(_ id: String) -> Bool {
        var list = favorites()
        guard !list.contains(id) else { return true }
        if list.count >= maxCount {
            list.removeFirst()          // drop the oldest pin (FIFO)
        }
        list.append(id)
        defaults.set(list, forKey: key)
        return true
    }

    func remove(_ id: String) {
        var list = favorites()
        list.removeAll { $0 == id }
        defaults.set(list, forKey: key)
    }

    /// Toggles `id`. `didHitLimit` is true only when an add was blocked by the cap.
    @discardableResult
    func toggle(_ id: String) -> (isFavorite: Bool, didHitLimit: Bool) {
        if isFavorite(id) {
            remove(id)
            return (false, false)
        }
        let added = add(id)
        return (added, !added)
    }

    func reset() { defaults.removeObject(forKey: key) }
}
