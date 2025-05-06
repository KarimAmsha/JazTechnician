//
//  SuccessSubmissionView.swift
//  FreelanceApp
//
//  Created by Karim OTHMAN on 6.05.2025.
//

import SwiftUI

struct SuccessSubmissionView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "hourglass")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(Color.primary())

                Text("لقد تم تقديم طلبك بنجاح!")
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primaryBlack())

                Text("نفخر بمجهودك، لقد قمنا باستلام طلبك وهو الآن قيد المراجعة من الإدارة. سنقوم بإرسال رسالة تفيد بقبول أو رفض حسابك.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding()
            .background(Color(hex: "FFF3D9"))
            .cornerRadius(16)

            Spacer()
        }
        .padding()
        .background(Color(hex: "FFF3D9"))
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    SuccessSubmissionView()
}
