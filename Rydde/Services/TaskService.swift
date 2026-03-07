import Foundation

struct GeneratedTask {
    let room: String
    let title: String
    let description: String
    let rationale: String
}

final class TaskService {
    static let shared = TaskService()

    private let mockTasks: [GeneratedTask] = [
        GeneratedTask(
            room: "Bathroom",
            title: "Scrub the sink and faucet",
            description: "Use an all-purpose cleaner and a microfiber cloth to wipe down the entire sink basin. Pay attention to the faucet handles and the base where grime builds up. Rinse thoroughly with warm water.",
            rationale: "Your bathroom sink hasn't been cleaned in 12 days, and you mentioned the bathroom is a trouble spot."
        ),
        GeneratedTask(
            room: "Kitchen",
            title: "Wipe down all countertops",
            description: "Clear everything off the counters first. Spray with kitchen cleaner and wipe in long strokes toward the sink. Don't forget the backsplash area and around the stove.",
            rationale: "Kitchen surfaces collect crumbs and spills daily. A quick wipe keeps things from building up."
        ),
        GeneratedTask(
            room: "Living Room",
            title: "Declutter the coffee table",
            description: "Remove everything from the coffee table. Put away items that don't belong, toss any trash, and only put back what you actually want there. Wipe the surface clean.",
            rationale: "Flat surfaces attract clutter fast. Resetting the coffee table makes the whole room feel tidier."
        ),
        GeneratedTask(
            room: "Bedroom",
            title: "Make the bed and fluff pillows",
            description: "Pull up the sheets and smooth the comforter. Arrange pillows neatly. If you have decorative pillows, place them in front. Straighten the nightstand while you're at it.",
            rationale: "A made bed takes two minutes and transforms how the entire bedroom looks and feels."
        ),
        GeneratedTask(
            room: "Hallway",
            title: "Sweep and spot-mop the floor",
            description: "Give the hallway floor a quick sweep to collect dust and debris. Spot-mop any visible marks or sticky spots with a damp cloth or Swiffer.",
            rationale: "Hallway floors get foot traffic all day. A quick pass prevents dirt from spreading to other rooms."
        ),
    ]

    private init() {}

    func generateTask(durationMinutes: Int) async -> GeneratedTask {
        // Simulate AI generation delay
        try? await Task.sleep(for: .seconds(1.5))
        return mockTasks.randomElement() ?? mockTasks[0]
    }
}
