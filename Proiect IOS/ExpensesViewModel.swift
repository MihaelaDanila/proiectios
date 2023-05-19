import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift


class ExpensesViewModel: ObservableObject {
    @Published var expenses = [Expense]()
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var user : String
    private var date : String

    init(user : String, selectedDate : String){
        self.user = user
        self.date = selectedDate
    }
    
      deinit {
         unsubscribe()
      }

      func unsubscribe() {
         if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
         }
      }

    
    func convertToExpenseArray(inputString: String) -> [Expense] {
        var expenses: [Expense] = []

        // Remove the opening and closing brackets from the input string
        let cleanedString = inputString.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))

        // Split the cleaned string by commas to get individual expense strings
        let expenseStrings = cleanedString.components(separatedBy: ", P")
        // Iterate over each expense string and extract the name and price values
        for expenseString in expenseStrings {
            // print(expenseString)
            let nr = expenseString.replacingOccurrences(of: "Proiect_IOS.Expense", with: "").components(separatedBy: "\n")
            // print(nr)
            let nameRange = expenseString.range(of: #"name: "(.*?)""#, options: .regularExpression)
            let priceRange = expenseString.range(of: #"price: (\d+(\.\d+)?)\b"#, options: .regularExpression)
                       
            //            print (nameRange)
//            print(priceRange)
            if let nameRange = nameRange, let priceRange = priceRange {
                let name = String(expenseString[nameRange].dropFirst(7).dropLast(1))
                let priceString = String(expenseString[priceRange].dropFirst(7))
                let price = Float(priceString) ?? 0.0

                let expense = Expense(name: name, price: price)
                expenses.append(expense)
                // print(expense)
            }
        }

        return expenses
    }
    
    
    func subscribe() {
          if listenerRegistration == nil {
              // let docRef = db.collection(self.user).document("10.05.2023").collection("expenses")
              
              let docRef = db.collection(self.user).document(self.date)
              docRef.getDocument { (document, error) in
                  if document!.exists {
                      
                    
                  } else {
                       print("Document does not exist")
                      self.db.collection(self.user).document(self.date).setData(["expenses" : ""])
                    }
              }
              //let data = await db.collection(self.user).document(self.date).getDocument().data()!["expenses"]
            
              let docRef2 = db.collection(self.user).document(self.date)

              docRef2.getDocument(source: .cache) { [self] (document, error) in
                  if let document = document {
                      let property : String = document.get("expenses") as! String
                      // print(property)

                      let expenses = convertToExpenseArray(inputString: property)
                      self.expenses = expenses
                  } else {
                      print("Document does not exist in cache")
                  }
              }
              
              
//              listenerRegistration = db.collection(self.user).document(self.date).collection("expenses").addSnapshotListener { (querySnapshot, error) in
//                  guard let expenses = querySnapshot?.documents  else {
//                print("No expenses")
//                return
//             }
//
//            self.expenses = expenses.compactMap { queryExpenseSnapshot in
//                try? queryExpenseSnapshot.data(as: Expense.self)
//            }
//         }
      }
  }

}
