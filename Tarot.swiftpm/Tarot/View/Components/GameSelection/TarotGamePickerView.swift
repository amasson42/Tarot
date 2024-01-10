import SwiftUI

struct TarotGamePickerView: View {
    
    let gameManager: any TarotGameManagerProtocol
    
    var pickAction: ((TarotGame) -> ())? = nil
    
    @State var loadedHeaders: [TarotGame.Header] = []
    
    var body: some View {
        VStack {
            List {
                ForEach(loadedHeaders) { header in
                    Button {
                        Task {
                            do {
                                let game = try await gameManager.load(header: header)
                                pickAction?(game)
                            } catch {
                                print("error loading game \(header.name): \(error.localizedDescription)")
                            }
                        }
                        
                    } label: {
                        TarotGameHeaderView(header: header)
                    }
                }
                .onDelete { indices in
                    for index in indices {
                        Task {
                            do {
                                try await gameManager.delete(header: loadedHeaders[index])
                            } catch {
                                print("error deleting game \(loadedHeaders[index]): \(error.localizedDescription)")
                            }
                        }
                    }
                    loadedHeaders.remove(atOffsets: indices)
                }
            }
            .onAppear {
                Task {
                    loadedHeaders = await gameManager.getAllHeaders()
                }
            }
            
            Text("Loaded games: \(loadedHeaders.count)")
                .fontWeight(.ultraLight)
                .font(.footnote)
        }
    }
}

#Preview {
    TarotGamePickerView(gameManager: TarotGameManager_Mock())
}

