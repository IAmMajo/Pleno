// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Models
import Foundation
import MeetingServiceDTOs
import Fluent

extension Record {
    public func toGetRecordDTO(db: Database, userId: User.IDValue) async throws -> GetRecordDTO {
        let lang = try self.requireID().lang
        let identityIds = try await IdentityHistory.byUserId(userId, db).map { identityHistory in
            try identityHistory.identity.requireID()
        }
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
        
        let votingSummaries: String = try await votings.map({ voting in
            let getVotingDTO = try await voting.toGetVotingDTO(db: db)
            let getVotingResultsDTO = try await voting.toGetVotingResultsDTO(db: db)
            return await """
            ## \(voting.question)
            _\(voting.description)_
            **\(LocalizableManager.shared.translate(key: "Opened at", into: lang))**: \(voting.startedAt?.description(with: Locale(identifier: lang)) ?? "X")
            **\(LocalizableManager.shared.translate(key: "Closed at", into: lang))**: \(voting.closedAt?.description(with: Locale(identifier: lang)) ?? "X")
            **\(LocalizableManager.shared.translate(key: "Options",  into: lang))**: \(getVotingDTO.options.map(\.text).joined(separator: ", "))
            ### \(LocalizableManager.shared.translate(key: "Distribution of votes",  into: lang))
            \(getVotingResultsDTO.results.map({ getVotingResultDTO in
            let votingOptionText: String
            if let text = getVotingDTO.options.first(where: {$0.index == getVotingResultDTO.index})?.text {
                votingOptionText = text
            } else { // Null-coalescing operator (??) does not allow for the right side to be asyncronous if the left side is not
                votingOptionText = await LocalizableManager.shared.translate(key: "Abstention",  into: lang)
            }
                return "- \(votingOptionText): \(getVotingResultDTO.count)/\(getVotingResultsDTO.totalCount) (\(getVotingResultDTO.percentage)%)"
            }).joined(separator: "\n"))
            """
        }).joined(separator: "\n\n")
        
        return try await .init(
            meetingId: self.requireID().$meeting.id,
            lang: self.requireID().lang,
            identity: self.$identity.get(on: db).toGetIdentityDTO(),
            status: self.status.convert(),
            content: self.content,
            attendancesAppendix: "# \(LocalizableManager.shared.translate(key: "Attendees", into: lang))\n\(attendances)",
            votingResultsAppendix: "# \(LocalizableManager.shared.translate(key: "Votings", into: lang))\n\(votingSummaries.isEmpty ? "/" : votingSummaries)",
            iAmTheRecorder: identityIds.contains(self.$identity.id)
        )
    }
}
