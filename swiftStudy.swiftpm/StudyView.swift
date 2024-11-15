//
//  StudyView.swift
//  swiftStudy
//
//  Created by kimtaein on 11/11/24.
//

import SwiftUI

/**
 @State: 뷰 내에서만 상태를 관리.
 @Binding: 부모 뷰에서 자식 뷰로 상태를 전달하고 자식에서 수정.
 @ObservedObject: 외부 데이터 모델을 관찰하고 변경 시 뷰를 리렌더링.
 @StateObject: 뷰에서 객체를 생성하고 소유, 상태 관리.
 @EnvironmentObject: 전역 상태를 관리하고 여러 뷰에서 공유.
 */

struct StudyView: View {
//    @StateObject var studyVM = StudyViewModel()
    var body: some View {
        NavigationView {
            TabView {
                Forum()
                    .tabItem {
                        Image(systemName: "bubble.right")
                    }
                
                Text("home")
                    .tabItem {
                        Image(systemName: "bubble.right")
                    }
                
            }.navigationTitle("Study Test")
        }
//        .environmentObject(studyVM)
    }
}

struct Forum: View {
    @State private var list: [Study] = Study.list
    @State private var showAddView: Bool = false
    
//    @EnvironmentObject var studyVM : StudyViewModel // binding 으로 넘겨줘야함
    @State private var newStudy = Study(username: "", content: "")
    
    var body: some View {
        ScrollView {
            LazyVStack{
                ForEach($list) { $study in
                    NavigationLink {
                        StudyDetail(study: $study)
                    } label: {
                        StudyRow(study: study)
                    }
                    .tint(.primary)
                }
            }
        }
        .refreshable {}
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            Button {
                showAddView = true
            } label: {
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .padding()
                    .background(Circle().fill(.white).shadow(radius: 4))
            }
            .padding()
        }
        .sheet(isPresented: $showAddView) {
            NavigationView {
                StudyAdd(editingStudy: $newStudy)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("취소") {
                                newStudy = Study(username: "", content: "")
                                showAddView = false
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("완료") {
                                list.insert(newStudy, at: 0)
                                showAddView = false
                                newStudy = Study(username: "", content: "")
                            }
                        }
                    }
            }
        }
    }
}

//class StudyViewModel: ObservableObject {
//    @Published var list: [Study] = Study.list
//
//    func addStudy(text: String) {
//        let newStudy = Study(username: "", content: text)
//        list.insert(newStudy, at: 0)
//    }
//}

struct StudyAdd: View {
    @FocusState private var focused: Bool
    @Binding var editingStudy: Study
    
//    @Environment(\.dismiss) private var dismiss
//    @State private var text: String
    
    //ViewModel 사용
    //let action: (_ study: Study) -> ()
    
    //StateObject 에서 넘겨받을 수 있도록
    //EnvironmentObject 는 body 가 호출 될 때의 시점
//    @EnvironmentObject var studyVM : StudyViewModel
    
/**
 https://developer.apple.com/documentation/swiftui/stateobject/init(wrappedvalue:)
 You typically don’t call this initializer directly
 
    init(study: Study? = nil) {
        _text = State(wrappedValue: study?.content ?? "") // init말고 wrapped 를 사용하자(최신)
    }
 */
    
    var body: some View {
        VStack {
            TextField("유저명", text: $editingStudy.username)
                .font(.largeTitle)
                .padding()
                .padding(.top)
            TextEditor(text: $editingStudy.content)
                .font(.title)
                .padding()
                .focused($focused)
                .onAppear{ focused = true }
            Spacer()
        }
        .navigationTitle(editingStudy.username.isEmpty ? "추가" : "수정") // 수정된 부분
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StudyDetail: View {
    @State private var showEditView: Bool = false
//    let study : Study
    @Binding var study: Study
    @State private var editingStudy = Study(username: "", content: "")
    
    var body: some View {
        VStack(spacing: 20){
            Text(study.username)
            Text(study.content)
                .font(.largeTitle)
            Button {
                editingStudy = study
                showEditView = true
            } label: {
                Image(systemName: "pencil")
                Text("수정")
            }
            .fullScreenCover(isPresented: $showEditView) {
                NavigationStack {
                    StudyAdd(editingStudy: $editingStudy)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("취소"){
                                    showEditView = false
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing){
                                Button("수정"){
                                    // ViewModel 적용
                                    //let newStudy = Study(username: "", content: "")
                                    //                        action(newStudy)
                                    
                                    //binding 으로 처리
                                    //studyVM.addStudy(text: text)
                                    study = editingStudy
                                    showEditView = false
                                }
                            }
                        }
                }
            }
        }
    }
}

struct StudyRow: View {
    let study: Study
    let colors: [Color] = [
        Color.orange, Color.pink, Color.purple, Color.blue, Color.gray, Color.green, Color.cyan, Color.mint, Color.indigo, Color.brown
    ]
    var body: some View {
        HStack {
            Circle()
                .fill(colors.randomElement() ?? Color.teal)
                .frame(width: 38)
            
            VStack(alignment: .leading) {
                Text(study.username)
                Text(study.content)
                    .font(.title)
            }
            Spacer()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder()
        }
        .padding( )
    }
}

struct Study: Identifiable {
    let id = UUID()
    var username: String
    var content: String
}

extension Study {
    static let list: [Study] = [
        Study(username: "이름1", content: "내용1"),
        Study(username: "이름2", content: "내용2"),
        Study(username: "이름3", content: "내용3"),
        Study(username: "이름4", content: "내용4"),
        Study(username: "이름5", content: "내용5"),
        Study(username: "이름6", content: "내용6")
    ]
}

#Preview {
    //        StudyRow(study: Study(username: "test", content: "test content"))
    //
    //        StudyDetail(study: Study(username: "test", content: "test content"))
    //
    //        StudyAdd() { study in
    //
    //        }
    //
    //    NavigationView{
    //        Forum()
    //    }
    StudyView()
}
