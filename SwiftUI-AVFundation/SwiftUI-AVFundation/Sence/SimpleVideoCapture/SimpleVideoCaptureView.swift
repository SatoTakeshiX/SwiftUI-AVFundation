//
//  SimpleVideoCaptureView.swift
//  SwiftUI-AVFundation
//
//  Created by satoutakeshi on 2020/06/13.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import SwiftUI

struct SimpleVideoCaptureView: View {
    @ObservedObject var presenter: SimpleVideoCapturePresenter
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct SimpleVideoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleVideoCaptureView()
    }
}
