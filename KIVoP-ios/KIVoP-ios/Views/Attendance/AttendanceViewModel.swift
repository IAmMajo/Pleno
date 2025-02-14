import Foundation
import SwiftUI
import MeetingServiceDTOs

@MainActor
class AttendanceViewModel: ObservableObject {

    @Published var errorMessage: String? = nil
    @Published var searchText: String = "" {
        didSet {
            filterMeetings() // Wenn der Suchtext geändert wird, wird die Filterung angewendet
        }
    }
    @Published var selectedTab: Int = 0 {
        didSet {
            filterMeetings() // Wenn der Tab geändert wird, wird die Filterung erneut angewendet
        }
    }
    @Published var meetings: [GetMeetingDTO] = [] {
        didSet {
            filterMeetings() // Wenn neue Meetings abgerufen werden, werden diese ebenfalls gefiltert
        }
    }
    @Published var filteredMeetings: [GetMeetingDTO] = [] // Gefilterte Meetings

    @Published var isLoading: Bool = false
    @Published var attendanceManager = AttendanceManager.shared
    
    // Abrufen aller Meetings
    func fetchMeetings() {
        Task {
            await self.meetings = attendanceManager.fetchMeetings()
            filterMeetings() // Nachdem Meetings abgerufen wurden, filtere sie
        }
    }

    // Filtert die Meetings basierend auf dem Status und dem Suchtext
    private func filterMeetings() {
        // Zuerst nach dem Status filtern (je nach Tab)
        let filteredByStatus = meetings.filter { meeting in
            switch selectedTab {
            case 0:
                return meeting.status == .completed
            case 1:
                return meeting.status == .scheduled
            default:
                return true // Kein Filter, wenn ein anderer Tab ausgewählt ist
            }
        }

        // Danach nach dem Suchtext filtern
        filteredMeetings = filteredByStatus.filter { meeting in
            searchText.isEmpty || meeting.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    // Aktuelle Sitzungen (inSession)
    var currentMeetings: [GetMeetingDTO] {
        meetings
            .filter { $0.status == .inSession } // Filtere nach "inSession"
            .filter { meeting in
                // Wenn der searchText nicht leer ist, filtern wir nach dem Namen
                searchText.isEmpty || meeting.name.localizedCaseInsensitiveContains(searchText)
            }
    }


    // Gruppierte Sitzungen nach Monat und Jahr
    var groupedMeetings: [Dictionary<String, [GetMeetingDTO]>.Element] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM - yyyy"
        
        // Gruppierung nach Monat/Jahr
        var grouped = Dictionary(grouping: filteredMeetings) { meeting in
            dateFormatter.string(from: meeting.start)
        }

        // Sortierung innerhalb der Gruppen
        for (key, meetings) in grouped {
            grouped[key] = meetings.sorted { lhs, rhs in
                selectedTab == 0 ? lhs.start > rhs.start : lhs.start < rhs.start
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

    // Wechsel zwischen den destination Views je nach Status
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
