
import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseDatabase
import FirebaseDatabaseSwift

struct addExpenseView: View {
    var displayName : String
    var selectedDate : Date
    @State public var newExpenseName : String = ""
    @State public var newExpensePrice : Float = 0
    @Binding var expenses: [Expense]
    var body: some View {
        
        VStack {
            TextField(text: $newExpenseName, prompt: Text("Pe ce ai aruncat banii?")) {
                Text("Pe ce ai aruncat banii?")
            }        .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .frame(height: 30)
                .padding()

            TextField("Cat ai dat?", value: $newExpensePrice, format: .number)    .disableAutocorrection(true)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(height: 30)
                .padding()

            
        
            Spacer()
            Button("Adaugă", action: {
                if (newExpenseName != ""){
            
                    expenses.append(Expense(name: newExpenseName, price: newExpensePrice))
                    newExpenseName = ""
                    newExpensePrice = 0
                    let myDict = expenses.map { ["price": $0.price, "name": $0.name] }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MMMM d, yyyy"
                    let date = dateFormatter.string(from: selectedDate)
                    
                    let db = Firestore.firestore()
                    let expensesString = expenses.description
                    db.collection(displayName).document(date).setData(["expenses" : expensesString])
                    
                    
//                    print (displayName, date)
//                    print(myDict)
//
                }
                else {
                    newExpenseName = ""
                    newExpensePrice = 0
                }
                    
            })
            Spacer()
            Spacer()
            Spacer()
            Spacer()


        }
        .buttonStyle(.bordered)
        .foregroundColor(.black)
        .padding()
        #if os(iOS)
        .background(Color(UIColor.systemBackground))
        #endif
    }

}



struct Expense: Hashable, Decodable{
    let name: String
    let price: Float
}


struct ExpenseView: View {
    
    let expense: Expense
    
    var body: some View{
        HStack{
            Text(expense.name)
            Spacer()
            Text(String(expense.price) + " lei")
        }
    }
}

struct ContentView: View {
    var displayName : String
    var viewModel : ExpensesViewModel
    
    @State var selectedDate: Date = .now

    init(displayName: String){
        self.displayName = displayName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let date = dateFormatter.string(from: Date())
        
        self.viewModel = ExpensesViewModel(user : displayName, selectedDate: date)
    }
     
    @State public var expenses: [Expense] = []
    
    var body: some View {
        
      VStack {
          DatePicker(
            "Selectează ziua: ",
            selection: $selectedDate,
            displayedComponents: [.date]
          )
        
          
      }
      
    .frame(maxHeight: 50)
    .foregroundColor(.black)
    .padding()
    #if os(iOS)
    .background(Color(UIColor.systemBackground))
    #endif
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
    .shadow(radius: 8)
    .navigationTitle("")
    .analyticsScreen(name: "\(ContentView.self)")
      
      NavigationView {
          
          
          List {
                  ForEach(expenses, id: \.self) {
                      expense in ExpenseView(expense: expense)
                  }
                
                .onDelete(perform: delete)
              
              NavigationLink(destination: addExpenseView(displayName: displayName, selectedDate: selectedDate, expenses: self.$expenses)) {

                  Button(action: addItem) {
                      Label("Adaugă", systemImage: "plus")
                  }
              }
             
          }
          
          .onAppear(){
              self.viewModel.subscribe()
              self.expenses = viewModel.expenses
//              let dateFormatter = DateFormatter()
//              dateFormatter.dateFormat = "MMMM d, yyyy"
//              let date = dateFormatter.string(from: Date())
//
//              let newViewModel = ExpensesViewModel(user : displayName, selectedDate: date)
//              newViewModel.subscribe()
//              self.expenses = newViewModel.expenses
              
          }
          .navigationTitle("Cheltuieli:")
          .background(Color(UIColor.systemBackground))
      }

      
  }
    func delete (indexSet: IndexSet){
        expenses.remove(atOffsets: indexSet)
        let myDict = expenses.map { ["price": $0.price, "name": $0.name] }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let date = dateFormatter.string(from: selectedDate)
        
        let db = Firestore.firestore()
        let expensesString = expenses.description
        db.collection(displayName).document(date).setData(["expenses" : expensesString])
        
    }
    
    func addItem(){
    }

}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
        ContentView(displayName: "")
    }
  }
}
