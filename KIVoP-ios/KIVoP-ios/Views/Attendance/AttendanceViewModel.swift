// This file is licensed under the MIT-0 License.
import Foundation
import SwiftUI
import MeetingServiceDTOs

@MainActor
class AttendanceViewModel: ObservableObject {

    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var meetings: [GetMeetingDTO] = []
    @Published var isLoading: Bool = false
    
    // Hier werden alle API-Aufrufe ausgeführt
    @Published var attendanceManager = AttendanceManager.shared
    
    // Abrufen aller Meetings über den attendanceManager
    func fetchMeetings() {
        Task {
            await self.meetings = attendanceManager.fetchMeetings()
        }
    }
    
    // Aktuelle Sitzung werden ermittelt (falls vorhanden)
    var currentMeetings: [GetMeetingDTO] {
        meetings
            .filter { $0.status == .inSession }
            .sorted { $0.start < $1.start }
    }

    // Gruppiert die Sitzungen nach Monat und Jahr
    var groupedMeetings: [Dictionary<String, [GetMeetingDTO]>.Element] {
        let filtered = filteredMeetings()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM - yyyy"

        // Gruppierung
        var grouped = Dictionary(grouping: filtered) { meeting in
            dateFormatter.string(from: meeting.start)
        }

        // Sortierung innerhalb der Gruppen
        for (key, meetings) in grouped {
            grouped[key] = meetings.sorted { lhs, rhs in
                if selectedTab == 0 {
                    return lhs.start > rhs.start // Vergangene: Absteigend
                } else {
                    return lhs.start < rhs.start // Anstehende: Aufsteigend
                }
            }
        }

        // Sortierung der Gruppen
        return grouped.sorted { lhs, rhs in
            guard let lhsDate = dateFormatter.date(from: lhs.key),
                  let rhsDate = dateFormatter.date(from: rhs.key) else {
                return lhs.key < rhs.key
            }
            return selectedTab == 0 ? lhsDate > rhsDate : lhsDate < rhsDate
        }
    }

    // Filtert Sitzungen basierend auf dem Status (completed/scheduled)
    private func filteredMeetings() -> [GetMeetingDTO] {
        switch selectedTab {
        case 0:
            return meetings.filter { $0.status == .completed }
        case 1:
            return meetings.filter { $0.status == .scheduled }
        default:
            return []
        }
    }
    
    // Wechsel zwischen den destinations je nach meeting Status
    func destinationView(for meeting: GetMeetingDTO) -> some View {
        switch meeting.status {
        case .inSession:
            let viewModel = AttendanceCurrentViewModel(meeting: meeting)
            return AnyView(AttendanceCurrentView(viewModel: viewModel))
        case .completed:
            let viewModel = AttendanceDetailViewModel(meeting: meeting)
            return AnyView(AttendanceDetailView(viewModel: viewModel))
        case .scheduled:
            let viewModel = AttendancePlanningViewModel(meeting: meeting)
            return AnyView(AttendancePlanningView(viewModel: viewModel))
        }
    }
}
