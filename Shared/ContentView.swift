//
//  ContentView.swift
//  Shared
//
//  Created by Jakub Konka on 12/02/2022.
//

import SwiftUI
import Contacts

struct Contact: Identifiable {
    let id = UUID()
    let givenName: String
    let familyName: String
}

struct ContactRow: View {
    var contact: Contact
    
    var body: some View {
        Text("\(contact.givenName) \(contact.familyName)")
    }
}

struct ContentView: View {
    @State private var showingAlert = false
    @State private var hasResults = false
    @State private var results: [CNContact] = []
    @State private var contacts: [Contact] = []

    var body: some View {
        Text("Hi! We will migrate your Exchange contacts in a minute.")
            .padding()
        
        Button(action: {
            do {
                let store = CNContactStore()
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let allContainers = try store.containers(matching: nil)
                
                for cont in allContainers {
                    if cont.type != CNContainerType.exchange {continue}
                    
                    print(cont)
                    
                    let pred = CNContact.predicateForContactsInContainer(withIdentifier: cont.identifier)
                    let partial = try store.unifiedContacts(matching: pred, keysToFetch: keysToFetch)
                    results.append(contentsOf: partial)
                    
                    for res in results {
                        contacts.append(Contact(givenName: res.givenName, familyName: res.familyName))
                    }
                }
                
                if !results.isEmpty {
                    hasResults.toggle()
                    let saveRequest = CNSaveRequest()
                    
                    for res in results {
                        let contact = CNMutableContact()
                        contact.givenName = res.givenName
                        contact.familyName = res.familyName
                        contact.phoneNumbers = res.phoneNumbers
                        contact.emailAddresses = res.emailAddresses
                        saveRequest.add(contact, toContainerWithIdentifier: nil)
                    }
                    
                    try store.execute(saveRequest)
                } else {
                    print("uhm, got nothing!")
                }
            } catch {
                print("error occurred \(error)")
                showingAlert = true
                _ = alert("Error occurred", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {}
                }
            }
        }) {
            Text("Migrate contacts").padding()
        }
        
        if hasResults {
            List(contacts) { res in
                ContactRow(contact: res)
            }
        } else {
            Text("No contacts found")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
