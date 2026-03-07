import SwiftUI

struct HistoryScreen: View {
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.top, RyddeTheme.Spacing.md)
                .padding(.bottom, RyddeTheme.Spacing.md)

            ScrollView {
                VStack(spacing: RyddeTheme.Spacing.lg) {
                    ConsistencyCalendar(
                        completedDates: viewModel.completedDates,
                        displayedMonth: $viewModel.displayedMonth
                    )
                    .padding(.horizontal, RyddeTheme.Spacing.lg)

                    TaskLog(
                        tasks: viewModel.tasks,
                        rooms: viewModel.availableRooms,
                        selectedRoom: $viewModel.selectedRoom,
                        isLoading: viewModel.isLoadingMore,
                        onLoadMore: { viewModel.loadMoreIfNeeded() }
                    )
                    .padding(.horizontal, RyddeTheme.Spacing.lg)
                }
                .padding(.bottom, RyddeTheme.Spacing.lg)
            }
        }
        .background(Color(RyddeTheme.Colors.snow).ignoresSafeArea())
        .task {
            await viewModel.initialLoad()
        }
    }

    private var header: some View {
        HStack {
            Text("rydde")
                .font(RyddeTheme.Fonts.headingSmall)
                .foregroundColor(Color(RyddeTheme.Colors.fjord))
            Spacer()
        }
    }
}
