import SwiftUI

struct EventRideView: View {
    @ObservedObject var viewModel: EventRideViewModel
    
    var body: some View {
        Text("Planned Ride for \(viewModel.event.name)")
    }
}
