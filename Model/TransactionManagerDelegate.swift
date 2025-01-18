protocol TransactionManagerDelegate: AnyObject {
    func didFetchTransactions(_ transactions: [TransactionListData])
    func didFailWithError(_ error: Error)
}

class TransactionManager {
    let supabase = SupabaseManager.shared.client
    weak var delegate: TransactionManagerDelegate?
    
    func fetchAllTransactions() {
        Task {
            do {
                let transactions: [TransactionListData] = try await supabase
                    .from("transactions")
                    .select("""
                        *,
                        transaction_types (
                            name
                        )
                    """)
                    .order("transaction_date", ascending: false)
                    .execute()
                    .value
                
                await MainActor.run {
                    delegate?.didFetchTransactions(transactions)
                }
            } catch {
                await MainActor.run {
                    delegate?.didFailWithError(error)
                }
            }
        }
    }
}