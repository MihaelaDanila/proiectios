
import SwiftUI
import Combine
import FirebaseAnalytics
import FirebaseAnalyticsSwift
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseDatabase
import FirebaseDatabaseSwift

//class FavouriteNumberViewModel: ObservableObject {
//  @Published var favouriteNumber: Int = 42
//
//  private var defaults = UserDefaults.standard
//  private let favouriteNumberKey = "favouriteNumber"
//  private var cancellables = Set<AnyCancellable>()
//
//  init() {
//    if let number = defaults.object(forKey: favouriteNumberKey) as? Int {
//      favouriteNumber = number
//    }
//    $favouriteNumber
//      .sink { number in
//        self.defaults.set(number, forKey: self.favouriteNumberKey)
//        Analytics.logEvent("stepper", parameters: ["value" : number])
//      }
//      .store(in: &cancellables)
//  }
//}

struct addExpenseView: View {
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
                expenses.append(Expense(name: newExpenseName, price: newExpensePrice))
                newExpenseName = ""
                newExpensePrice = 0
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
    
    @StateObject var viewModel = ExpensesViewModel()
    
    @State private var selectedDate: Date = .now
//    @State public var expenses: [Expense] = [Expense(name: "asd", price: 12.3),
//                                      Expense(name: "asddd", price: 4.1),
//                                      Expense(name: "asd", price: 22.3)]
//
//
    
     
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
              
              NavigationLink(destination: addExpenseView(expenses: self.$expenses)) {

                  Button(action: addItem) {
                      Label("Adaugă", systemImage: "plus")
                  }
              }
             
          }
          
          .onAppear(){
              self.viewModel.subscribe()
              self.expenses = viewModel.expenses
          }
          .navigationTitle("Cheltuieli:")
          .background(Color(UIColor.systemBackground))
      }

      
  }
    func delete (indexSet: IndexSet){
        expenses.remove(atOffsets: indexSet)
    }
    
    func addItem(){
    }

}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
        ContentView()
    }
  }
}
