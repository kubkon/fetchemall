//
//  ContentView.swift
//  Shared
//
//  Created by Jakub Konka on 12/02/2022.
//

import SwiftUI
import Contacts

struct ContentView: View {
    @State private var showingAlert = false

    var body: some View {
        Text("Hi! We will migrate your Exchange contacts in a minute.")
            .padding()
        
        Button(action: {
            do {
                let store = CNContactStore()
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let contPred = CNContainer.predicateForContainers(withIdentifiers: ["exchange"]);
                let allContainers = try store.containers(matching: contPred)
//                let allContainers = try store.containers(matching: nil)
//                let request = CNContactFetchRequest(keysToFetch: keysToFetch)
                
                var results: [CNContact] = []
                for cont in allContainers {
                    let pred = CNContact.predicateForContactsInContainer(withIdentifier: cont.identifier)
                    let partial = try store.unifiedContacts(matching: pred, keysToFetch: keysToFetch)
                    results.append(contentsOf: partial)
                }

                for res in results {
                    print(res)
                }
            } catch {
                showingAlert = true
                _ = alert("Error occurred", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }) {
            Text("Migrate contacts").padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
