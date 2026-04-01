import Foundation
import Combine

@MainActor
final class ConnectionViewModel: ObservableObject {
    @Published var partnerNickname: String?
    @Published var isLoading = false

    private let userRepo = UserRepository()

    func loadPartner(pairLink: PairLink, currentUserID: String) async {
        isLoading = true
        defer { isLoading = false }

        let partnerID: String?
        if pairLink.parentUserID == currentUserID {
            partnerID = pairLink.childUserID
        } else {
            partnerID = pairLink.parentUserID
        }

        guard let pid = partnerID else { return }
        if let partner = try? await userRepo.fetchUser(id: pid) {
            partnerNickname = partner.nickname
        }
    }
}
