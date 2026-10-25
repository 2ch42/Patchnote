//
//  SearchResultRow.swift
//  Patchnote
//
//  Created by 이창현 on 10/26/26.
//

import SwiftUI

struct SearchResultRow: View {
    let item: AppItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: item.artworkUrl100) { image in
                image.resizable()
            } placeholder: {
                Color(.systemFill)
            }
            .frame(width: 56, height: 56)
            .clipShape(.rect(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.trackName)
                    .font(.headline)
                    .lineLimit(1)
                Text(item.sellerName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                ratingLabel
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var ratingLabel: some View {
        if let rating = item.averageUserRating, let count = item.userRatingCount {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color("Rating"))
                Text("\(rating.formatted(.number.precision(.fractionLength(1)))) · \(count.formatted(.number.notation(.compactName)))")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        } else {
            Text("평가 없음")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
