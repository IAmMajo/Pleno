import Models
import Foundation
import MeetingServiceDTOs
import Fluent

extension Record {
    public func toGetRecordDTO(db: Database) async throws -> GetRecordDTO {
        let lang = try self.requireID().lang
        let attendances = try await self.$id.$meeting.get(on: db).$attendances.query(on: db)
            .filter(\.$status == .present)
            .with(\.$id.$identity)
            .all().map({ attendance in
                "- \(try attendance.requireID().identity.name)"
            })
            .joined(separator: "\n")
        let votings = try await self.$id.$meeting.get(on: db).$votings.query(on: db)
            .filter(\.$isOpen == false)
            .filter(\.$closedAt != nil)
            .with(\.$votingOptions)
            .with(\.$votes)
            .all()
        
        return try await .init(meetingId: self.requireID().$meeting.id,
                               lang: self.requireID().lang,
                               identity: self.$identity.get(on: db).toGetIdentityDTO(),
                               status: self.status.convert(),
                               content: self.content,
                               attendancesAppendix: "# \(LocalizableManager.shared.translate(key: "Attendees", into: lang))\n\(attendances)",
                               votingResultsAppendix: """
# \(LocalizableManager.shared.translate(key: "Votings", into: lang))
\(votings.map({ voting in
let getVotingDTO = try await voting.toGetVotingDTO(db: db)
let getVotingResultsDTO = try await voting.toGetVotingResultsDTO(db: db)
return await """
## \(unsafeRaw: voting.question)
_\(unsafeRaw: voting.description)_
**\(unsafeRaw: LocalizableManager.shared.translate(key: "Opened at", into: lang))**: \(unsafeRaw: voting.startedAt?.description(with: Locale(identifier: lang)) ?? "X")
**\(unsafeRaw: LocalizableManager.shared.translate(key: "Closed at", into: lang))**: \(unsafeRaw: voting.closedAt?.description(with: Locale(identifier: lang)) ?? "X")
** \(unsafeRaw: LocalizableManager.shared.translate(key: "Options",  into: lang))**: \(unsafeRaw: getVotingDTO.options.map(\.text).joined(separator: ", "))
### \(unsafeRaw: LocalizableManager.shared.translate(key: "Distribution of votes",  into: lang))
\(unsafeRaw: getVotingResultsDTO.results.map({ getVotingResultDTO in
let votingOptionText: String
if let text = getVotingDTO.options.first(where: {$0.index == getVotingResultDTO.index})?.text {
    votingOptionText = text
} else { // Null-coalescing operator (??) does not allow for the right side to be asyncronous if the left side is not
    votingOptionText = await LocalizableManager.shared.translate(key: "Abstention",  into: lang)
}
    return "- \(votingOptionText): \(getVotingResultDTO.count)/\(getVotingResultsDTO.totalCount) (\(getVotingResultDTO.percentage)%)"
}).joined(separator: "\n"))
"""
}).joined(separator: "\n\n"))
""")
    }
}
