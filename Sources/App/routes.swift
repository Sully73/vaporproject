import Routing
import Vapor
import Fluent

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
    
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameter(Acronym.self)
    }
    
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameter(Acronym.self), req.content.decode(Acronym.self), { (acronym, updatedAcronym) in
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: req)
        })
    }
    
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return try Acronym.query(on: req).filter(\.short == searchTerm).all()
    }
}
