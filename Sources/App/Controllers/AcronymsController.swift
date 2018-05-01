import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymsRoutes = router.grouped("api", "acronyms")
        acronymsRoutes.get("all", use: getAllHandler)
        acronymsRoutes.get(use: getHandeler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.post(use: postHandler)
        acronymsRoutes.put(use: putHandler)
        acronymsRoutes.get(Acronym.parameter, "user", use: getUserHandler)
    }

    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }

    func getHandeler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameter(Acronym.self)
    }

    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return try Acronym.query(on: req).filter(\.short == searchTerm).all()
    }

    func postHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.content.decode(Acronym.self)
            .flatMap(to: Acronym.self, { acronym in
                acronym.save(on: req)
            })
    }

    func putHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self,
                           req.parameter(Acronym.self),
                           req.content.decode(Acronym.self), { acronym, updateAcronym in
                               acronym.short = updateAcronym.short
                               acronym.long = updateAcronym.long
                               acronym.userID = updateAcronym.userID
                               return acronym.save(on: req)
        })
    }

    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameter(Acronym.self).flatMap(to: User.self, { acronym in
            try acronym.user.get(on: req)
        })
    }
}
