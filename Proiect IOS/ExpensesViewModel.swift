import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift


class ExpensesViewModel: ObservableObject {
    @Published var expenses = [Expense]()
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    
    
    
      deinit {
         unsubscribe()
      }

      func unsubscribe() {
         if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
         }
      }

    @MainActor func subscribe() {
//          let email : String = AuthenticationViewModel().email;
          if listenerRegistration == nil {
              listenerRegistration = db.collection("expenses").addSnapshotListener { (querySnapshot, error) in
             guard let expenses = querySnapshot?.documents  else {
                print("No expenses")
                return
             }

            self.expenses = expenses.compactMap { queryExpenseSnapshot in
                try? queryExpenseSnapshot.data(as: Expense.self)
            }
         }
      }
  }

}
