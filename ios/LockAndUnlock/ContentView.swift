//
//  ContentView.swift
//  LockAndUnlock
//
//  Created by Khazan Gu on 2020/9/19.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
   
    @ObservedObject var bluetoothControler = BluetoothControler.sharedInstance
        
    func search() -> Void {
        bluetoothControler.startScan()
    }
    
    var body: some View {
        
        if (bluetoothControler.infos.count == 0) {
        
            Color.white
                .ignoresSafeArea()
                .overlay(
                
                    VStack {
                        
                        Spacer()

                        Spacer()
                        
                        Spacer()
                        
                        ZStack {

                            Circle()
                                .stroke()
                                .frame(width: 120, height: 120, alignment: .center)
                                .foregroundColor(.blue)
                                .scaleEffect(showOuterWave ? 3 : 1)
                                .opacity(showOuterWave ? 0.5 : 1)
                                .animation(Animation.easeInOut(duration: 1).delay(1).repeatForever(autoreverses: false).delay(0))
                                .onAppear() {
                                    self.showOuterWave.toggle()
                                }
                            
                            Circle()
                                .stroke()
                                .frame(width: 120, height: 120, alignment: .center)
                                .foregroundColor(.blue)
                                .scaleEffect(showMiddleWave ? 2.75 : 1)
                                .opacity(showMiddleWave ? 0.5 : 1)
                                .animation(Animation.easeInOut(duration: 1).delay(1).repeatForever(autoreverses: false).delay(0.2))
                                .onAppear() {
                                    self.showMiddleWave.toggle()
                                }
                            
                            Circle()
                                .stroke()
                                .frame(width: 120, height: 120, alignment: .center)
                                .foregroundColor(.blue)
                                .scaleEffect(innerOuterWave ? 2.5 : 1)
                                .opacity(innerOuterWave ? 0.5 : 1)
                                .animation(Animation.easeInOut(duration: 1).delay(1).repeatForever(autoreverses: false).delay(0.4))
                                .onAppear() {
                                    self.innerOuterWave.toggle()
                                }
                            
                            Circle()
                                .frame(width: 200, height: 200, alignment: .center)
                                .foregroundColor(.blue)
                                .opacity(0.5)
                            
                            Circle()
                                .frame(width: 120, height: 120, alignment: .center)
                                .foregroundColor(.blue)
                                .opacity(0.5)
                            
                            Image("bluetooth")

                        }
                        
                        Spacer()
                        
                        Spacer()

                        Button("Search") {
                            search()
                        }
                        .frame(width: 240, height: 54)
                        .background(Color.orange)
                        .cornerRadius(3.0)
                        
                        Spacer()

                        Spacer()
                        
                        Spacer()
                                            
                    }
                    
                )

        } else {
            
            Color.white
                .ignoresSafeArea()
                .overlay(

                    List(bluetoothControler.infos, id: \.deviceName) { peripheral in

                        HStack{

                            Text(peripheral.deviceName)

                            Text(peripheral.rssi.stringValue)

                            Text(peripheral.userName)

                        }

                    }

                )

        }

    }
    
    init(){
        UITableView.appearance().backgroundColor = .white
    }
    
    @State private var showOuterWave = false
    
    @State private var showMiddleWave = false

    @State private var innerOuterWave = false

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
