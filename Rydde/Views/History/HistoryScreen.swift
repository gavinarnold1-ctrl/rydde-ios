import SwiftUI

struct HistoryScreen: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showLogSheet = false

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, RyddeTheme.Spacing.lg)
                .padding(.top, RyddeTheme.Spacing.md)
                .padding(.bottom, RyddeTheme.Spacing.md)

            Group {
                if viewModel.isInitialLoading {
                    Spacer()
                    ArcSpinner(size: 24)
                    Spacer()
                } else if viewModel.error != nil {
                    Spacer()
                    NetworkErrorView(onRetry: { Task { await viewModel.retry() } })
                    Spacer()
                } else if viewModel.tasks.isEmpty && !viewModel.isLoadingMore {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: RyddeTheme.Spacing.lg) {
                            ConsistencyCalendar(completedDates: viewModel.completedDates, displayedMonth: $viewModel.displayedMonth)
                                .padding(.horizontal, RyddeTheme.Spacing.lg)
                            TaskLog(tasks: viewModel.tasks, rooms: viewModel.availableRooms, selectedRoom: $viewModel.selectedRoom, isLoading: viewModel.isLoadingMore, onLoadMore: { viewModel.loadMoreIfNeeded() })
                                .padding(.horizontal, RyddeTheme.Spacing.lg)
                        }
                        .padding(.bottom, RyddeTheme.Spacing.lg)
                    }
                }
            }
        }
        .background(Color(RyddeTheme.Colors.background).ignoresSafeArea())
        .task { await viewModel.initialLoad() }
        .sheet(isPresented: $showLogSheet) {
            LogTaskSheet(onSaved: { Task { await viewModel.retry() } })
        }
    }

    private var header: some View {
        HStack {
            Text("rydde").font(RyddeTheme.Fonts.headingSmall).foregroundColor(Color(RyddeTheme.Colors.primaryText))
            Spacer()
            Button(action: { showLogSheet = true }) {
                Image(systemName: "plus").font(.system(size: 20, weight: .medium)).foregroundColor(Color(RyddeTheme.Colors.accent)).frame(width: 44, height: 44)
            }
            .accessibilityLabel("Log a task")
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            Text("Your first session is waiting.").font(RyddeTheme.Fonts.body).foregroundColor(Color(RyddeTheme.Colors.secondaryText)).multilineTextAlignment(.center).padding(RyddeTheme.Spacing.xxl)
            Spacer()
        }
    }
}
