import SwiftUI

struct PieChartView: View {
    let data: [Double]
    let labels: [String]
    @State private var selectedIndex: Int? = nil

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.7
            let total = data.reduce(0, +)
            let angles = calculateAngles(data: data, total: total)

            VStack {
                ZStack {
                    // Pie chart slices
                    ForEach(angles.indices, id: \.self) { index in
                        PieSlice(
                            startAngle: angles[index].start,
                            endAngle: angles[index].end,
                            color: colors[index % colors.count]
                        )
                        .opacity(selectedIndex == index || selectedIndex == nil ? 1 : 0.5)
                        .scaleEffect(selectedIndex == index ? 1.1 : 1) // Hervorhebung
                        .animation(.spring(), value: selectedIndex)
                        .onTapGesture {
                            selectedIndex = selectedIndex == index ? nil : index
                        }
                    }
                    .frame(width: size, height: size)

                    // Central text display
                    if let selectedIndex = selectedIndex {
                        VStack {
                            Text(labels[selectedIndex])
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(centralTextColor)
                            Text("Stimmen: \(Int(data[selectedIndex]))")
                                .font(.headline)
                                .foregroundColor(centralTextColor)
                            Text("Anteil: \(String(format: "%.1f", (data[selectedIndex] / total) * 100))%")
                                .font(.subheadline)
                                .foregroundColor(centralSubTextColor)
                        }
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(centralBackgroundColor)
                        .cornerRadius(12)
                        .shadow(color: shadowColor, radius: 4)
                    } else {
                        Text("Gesamt: \(Int(total))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(centralTextColor)
                    }
                }
                .frame(width: size, height: size)

                Spacer() // Platzhalter für Ausrichtung
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
        }
    }

    private let colors: [Color] = [
        .blue, .green, .orange, .purple, .red, .pink
    ]

    private var backgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
        })
    }

    private var centralBackgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.darkGray : UIColor.white
        })
    }

    private var centralTextColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        })
    }

    private var centralSubTextColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.gray : UIColor.secondaryLabel
        })
    }

    private var shadowColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.gray
        })
    }

    private func calculateAngles(data: [Double], total: Double) -> [(start: Angle, end: Angle)] {
        var startAngle = Angle(degrees: 0)
        var angles: [(start: Angle, end: Angle)] = []

        for value in data {
            let percentage = value / total
            let endAngle = startAngle + Angle(degrees: percentage * 360)
            angles.append((start: startAngle, end: endAngle))
            startAngle = endAngle
        }

        return angles
    }
}

struct PieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius: CGFloat = min(geometry.size.width, geometry.size.height) / 2

                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            }
            .fill(color)
        }
    }
}

struct PieChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PieChartView(
                data: [35, 25, 15, 10, 10, 5],
                labels: ["Xcode", "Swift", "SwiftUI", "WWDC", "SwiftData", "Andere"]
            )
            .frame(width: 300, height: 300)
            .preferredColorScheme(.light)

            PieChartView(
                data: [35, 25, 15, 10, 10, 5],
                labels: ["Xcode", "Swift", "SwiftUI", "WWDC", "SwiftData", "Andere"]
            )
            .frame(width: 300, height: 300)
            .preferredColorScheme(.dark)
        }
    }
}
