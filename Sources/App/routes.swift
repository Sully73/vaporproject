import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { _ in
        "Hello, world!"
    }

    router.post("api", "acronyms") { req -> Future<Acronym> in
        try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self, { acronym in
                acronym.save(on: req)
            })
    }
}
